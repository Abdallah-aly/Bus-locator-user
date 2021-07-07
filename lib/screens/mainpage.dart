// import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uber/brand_colors.dart';
import 'package:uber/datamodels/directiondetails.dart';
import 'package:uber/datamodels/nearbyDriver.dart';
import 'package:uber/datamodels/user.dart';
import 'package:uber/dataprovider/appdata.dart';
import 'package:uber/globalVars.dart';
import 'package:uber/helpers/firehelper.dart';
import 'package:uber/helpers/helpermethods.dart';
import 'package:uber/screens/aboutus.dart';
import 'package:uber/screens/loginpage.dart';
import 'package:uber/screens/registrationpage.dart';
import 'package:uber/screens/searchpage.dart';
import 'package:uber/widgets/progressDialog.dart';
import 'package:uber/widgets/taxibutton.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:uber/widgets/NoDriverDialog.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottomPadding = 0;
  double rideDetailsHight = 0;
  double requestSheetHeight = 0;

  List<LatLng> polylineCoordinate = [];
  Set<Polyline> _polyline = {};

  Set<Marker> _marker = {};
  Set<Circle> _circle = {};

  BitmapDescriptor nearbyIcon;

  var geolocator = Geolocator();
  Position currentPosition;

  List<NearbyDriver> availableDrivers;

  DirectionDetails tripDriectionDetails;

  DatabaseReference rideRef;

  bool nearbyDriverKeyLoaded = false;

  void setupPositionLocator() async {
    Position position = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = CameraPosition(target: pos, zoom: 18);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
    String address = await HelperMethod.findCordinateAddress(position, context);
    print(address);
    startGeoFireListenr();
  }

  void showSnackBar(String title) {
    final snackbar = SnackBar(
        content: Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 15.0),
    ));
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  bool drawerCanOpen = true;

  static final CameraPosition _kLake =
      CameraPosition(target: LatLng(30.104218, 31.376181), zoom: 18);

  void showDetailsSheet() async {
    await getDirection();
    setState(() {
      mapBottomPadding = MediaQuery.of(context).size.height / 3;
      rideDetailsHight = MediaQuery.of(context).size.height / 3;
      drawerCanOpen = false;
    });
  }

  void showRequestingSheet() {
    setState(() {
      mapBottomPadding = MediaQuery.of(context).size.height / 3;
      rideDetailsHight = 0;
      requestSheetHeight = MediaQuery.of(context).size.height / 3;
      drawerCanOpen = true;
    });
    createRideRequest();
  }

  void createMarker() {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(4, 4));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'images/car_android.png')
          .then((icon) => nearbyIcon = icon);
    }
  }

  @override
  void initState() {
    super.initState();
    HelperMethod.getCurrentUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Container(
              height: 160,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Image.asset(
                      'images/user_icon.png',
                      height: 60,
                      width: 60,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Text('Abdallah'),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'View Profile',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500]),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Divider(
              height: 1.0,
              color: Color(0xFFe2e2e2),
              thickness: 1.0,
            ),
            SizedBox(
              height: 10,
            ),
            // ListTile(
            //   //free rides
            //   leading: Icon(Icons.location_history),
            //   title: Text(
            //     'Your line',
            //     style: TextStyle(fontSize: 16),
            //   ),
            //   onTap: () {},
            // ),
            // Divider(
            //   height: 1.0,
            //   color: Color(0xFFe2e2e2),
            //   thickness: 1.0,
            // ),
            ListTile(
              //support
              leading: Icon(Icons.contact_support_outlined),
              title: Text(
                'About us',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, AboutUs.id);
              },
            ),
            Divider(
              height: 1.0,
              color: Color(0xFFe2e2e2),
              thickness: 1.0,
            ),
            ListTile(
              //Logout
              leading: Icon(Icons.exit_to_app),
              title: Text(
                'Log Out',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginPage.id, (route) => false);
              },
            ),
            SizedBox(height: 250.0),
            ClipPath(
              clipper: WaveClipperTwo(flip: true, reverse: true),
              child: Container(
                height: 320,
                color: Colors.yellow[700],
                child: Center(),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.fromLTRB(0, 60, 0, 200),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kLake,
            myLocationEnabled: true,
            zoomGesturesEnabled: false,
            zoomControlsEnabled: false,
            polylines: _polyline,
            markers: _marker,
            circles: _circle,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;

              setState(() {
                mapBottomPadding = MediaQuery.of(context).size.height / 3;
              });

              setupPositionLocator();
            },
          ),
          //menu button
          Positioned(
            left: 30,
            top: 70,
            child: GestureDetector(
              onTap: () {
                if (drawerCanOpen == true) {
                  scaffoldKey.currentState.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                            0.7,
                            0.7,
                          ))
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(
                    (drawerCanOpen == true) ? Icons.menu : Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          //search panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: MediaQuery.of(context).size.height / 4,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7))
                    ]),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nice to see you again',
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 30),
                          child: TaxiButton(
                            text: "Get Your bus",
                            color: Colors.yellow[700],
                            onPressed: () async {
                              var connectivityResult =
                                  await (Connectivity().checkConnectivity());
                              if (connectivityResult !=
                                      ConnectivityResult.mobile &&
                                  connectivityResult !=
                                      ConnectivityResult.wifi) {
                                showSnackBar('You are Offline');
                                return;
                              }
                              var response = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchPage()));
                              if (response == 'getDirection') {
                                showDetailsSheet();
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          //ride request panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              child: Container(
                padding: EdgeInsets.only(top: 16),
                height: rideDetailsHight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                            0.7,
                            0.7,
                          ))
                    ]),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                      color: Colors.yellow[400],
                      child: Row(
                        children: [
                          Image.asset(
                            'images/taxi.png',
                            height: 70,
                            width: 70,
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Driver Name',
                                style: TextStyle(
                                    fontSize: 16, fontFamily: 'Brand-Bold'),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Car number',
                                style: TextStyle(
                                    fontSize: 16, fontFamily: 'Brand-Bold'),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Your Distance',
                                style: TextStyle(
                                    fontSize: 16, fontFamily: 'Brand-Bold'),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Estimated time',
                                style: TextStyle(
                                    fontSize: 16, fontFamily: 'Brand-Bold'),
                              ),
                            ],
                          ),
                          Expanded(child: Container()),
                          Column(
                            children: [
                              Text(
                                'Ahmed mohamed',
                                style: TextStyle(
                                    fontSize: 16, fontFamily: 'Brand-Bold'),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'س ل ص 2 1 5',
                                style: TextStyle(
                                    fontSize: 16, fontFamily: 'Brand-Bold'),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                (tripDriectionDetails != null)
                                    ? tripDriectionDetails.distanceText
                                    : '',
                                style: TextStyle(
                                    fontSize: 18, fontFamily: 'Brand-Bold'),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                (tripDriectionDetails != null)
                                    ? "About ${tripDriectionDetails.durationText}"
                                    : '',
                                style: TextStyle(
                                    fontSize: 16, fontFamily: 'Brand-Bold'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Container(
                    //   padding:
                    //       EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    //   child: Row(
                    //     children: [
                    //       Icon(
                    //         FontAwesomeIcons.moneyBillAlt,
                    //         size: 18,
                    //         color: BrandColors.colorTextLight,
                    //       ),
                    //       SizedBox(
                    //         width: 10,
                    //       ),
                    //       Text('Cash'),
                    //       SizedBox(
                    //         width: 10,
                    //       ),
                    //       Icon(
                    //         Icons.keyboard_arrow_down,
                    //         color: BrandColors.colorTextLight,
                    //         size: 16,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TaxiButton(
                        text: 'REQUEST BUS',
                        color: Colors.yellow[700],
                        onPressed: () {
                          showRequestingSheet();

                          availableDrivers = FireHelper.nearbyDriverList;
                          findDriver();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          //Request load panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                  padding: EdgeInsets.only(top: 16),
                  height: requestSheetHeight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15.0,
                            spreadRadius: 0.5,
                            offset: Offset(
                              0.7,
                              0.7,
                            ))
                      ]),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      children: [
                        // SizedBox(
                        //   height: 10,
                        // ),
                        Text(
                          'Requesting The bus...',
                          style: TextStyle(
                            color: BrandColors.colorText,
                            fontSize: 22.0,
                            fontFamily: 'Brand-Bold',
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            cancelRequest();
                            resetApp();
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  width: 1.0,
                                  color: BrandColors.colorLightGrayFair),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 25,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          child: Text(
                            'Cancel ride',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatLng = LatLng(30.119493, 31.605977);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              status: 'Please wait...',
            ));
    var thisDetails =
        await HelperMethod.getDirectionDetails(pickLatLng, destinationLatLng);

    setState(() {
      tripDriectionDetails = thisDetails;
    });

    Navigator.pop(context);
    print(thisDetails.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);
    polylineCoordinate.clear();
    if (result.isNotEmpty) {
      result.forEach((PointLatLng points) {
        polylineCoordinate.add(LatLng(points.latitude, points.longitude));
      });
    }
    _polyline.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Colors.black,
        points: polylineCoordinate,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      _polyline.add(polyline);
    });

    LatLngBounds bounds;
    if (pickLatLng.latitude > destinationLatLng.latitude &&
        pickLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
    } else if (pickLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickLatLng.longitude));
    } else if (pickLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickLatLng, northeast: destinationLatLng);
    }

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 90));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My Location'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: destination.placeName, snippet: 'Destination'),
    );
    setState(() {
      _marker.add(pickupMarker);
      _marker.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.blueAccent,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: Colors.blue,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: Colors.redAccent,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: Colors.redAccent,
    );
    setState(() {
      _circle.add(pickupCircle);
      _circle.add(destinationCircle);
    });
  }

  void createRideRequest() {
    rideRef = FirebaseDatabase.instance.reference().child('rideRequest').push();

    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    Map pickupMap = {
      'latitude': pickup.latitude.toString(),
      'longitude': pickup.longitude.toString()
    };

    Map destinationMap = {
      'latitude': destination.latitude.toString(),
      'longitude': destination.longitude.toString()
    };

    Map rideMap = {
      'created_at': DateTime.now().toString(),
      'ride_name': currentUserInfo.fullName,
      'rider_phone': currentUserInfo.phone,
      'pickup_address': pickup.placeName,
      'destination_address': destination.placeName,
      'location': pickupMap,
      'destination': destinationMap,
      'payment_method': 'card',
      'driver_id': 'waiting',
    };
    rideRef.set(rideMap);
  }

  void startGeoFireListenr() {
    Geofire.initialize('driversAvailable');

    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 20)
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];
            FireHelper.nearbyDriverList.add(nearbyDriver);

            if (nearbyDriverKeyLoaded) {
              updateDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            FireHelper.removeFromList(map['key']);
            updateDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];
            FireHelper.nearbyDriverList.add(nearbyDriver);

            FireHelper.updateNearbyLocation(nearbyDriver);
            updateDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            nearbyDriverKeyLoaded = true;
            print('FireHelper length : ${FireHelper.nearbyDriverList.length}');

            break;
        }
      }
    });
  }

  void cancelRequest() {
    rideRef.remove();
  }

  void updateDriversOnMap() {
    setState(() {
      _marker.clear();
    });
    Set<Marker> tempMarkers = Set<Marker>();
    for (NearbyDriver driver in FireHelper.nearbyDriverList) {
      LatLng driverPosition = LatLng(driver.latitude, driver.longitude);
      Marker thisMarker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverPosition,
        icon: nearbyIcon,
        rotation: HelperMethod.generateRandomNumber(360),
      );
      tempMarkers.add(thisMarker);
    }

    setState(() {
      _marker = tempMarkers;
    });
  }

  resetApp() {
    setState(() {
      polylineCoordinate.clear();
      _polyline.clear();
      _marker.clear();
      _circle.clear();
      rideDetailsHight = 0;
      requestSheetHeight = 0;
      drawerCanOpen = true;

      setupPositionLocator();
    });
  }

  void noDriverFound() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NoDriverDialog());
  }

  void findDriver() {
    if (availableDrivers.length == 0) {
      cancelRequest();
      resetApp();
      noDriverFound();
      return;
    }
    var driver = availableDrivers[0];
    notifyDriver(driver);
    print("the key : " + driver.key);
  }

  void notifyDriver(NearbyDriver driver) {
    DatabaseReference driverTripRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${driver.key}/newtrip');
    driverTripRef.set(rideRef.key);

    DatabaseReference tokenRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${driver.key}/token');
    tokenRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        String token = snapshot.value.toString();

        HelperMethod.sentNotification(token, context, rideRef.key);
      }
    });
  }
}
