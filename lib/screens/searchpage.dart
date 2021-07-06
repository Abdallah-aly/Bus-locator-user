import 'package:flutter/material.dart';
import 'package:uber/datamodels/prediction.dart';
import 'package:uber/dataprovider/appdata.dart';
import 'package:provider/provider.dart';
import 'package:uber/helpers/requesthelper.dart';
import 'package:uber/widgets/predictiontile.dart';
import 'package:uber/widgets/progressDialog.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var pickupController = TextEditingController();
  var destinationController = TextEditingController(text: 'el-shrouk academy');
  var foucsDest = FocusNode();
  bool focused = false;

  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(foucsDest);
      focused = true;
    }
  }

  List<Prediction> destinationPredictionList = [];

  void searchPlace(String placeName) async {
    if (placeName.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=AIzaSyAlZs2dXoqS-I9PN1RDxsajKi9TGdDVw3s&sessiontoken=1234567890&components=country:eg';
      var response = await RequestHelper.getRequest(url);

      if (response == 'failed') {
        return;
      }
      if (response['status'] == 'OK') {
        var predictionJson = response['predictions'];
        var thisList = (predictionJson as List)
            .map((e) => Prediction.fromJson(e))
            .toList();
        setState(() {
          destinationPredictionList = thisList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // setFocus();
    String address =
        Provider.of<AppData>(context).pickupAddress.placeName ?? '';
    pickupController.text = address;
    // String addressTo =
    //     Provider.of<AppData>(context).destinationAddress.placeName =;
    // destinationController.text = addressTo;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7))
              ]),
              child: SafeArea(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 24, top: 10, right: 24, bottom: 20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Stack(
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.arrow_back)),
                          Center(
                            child: Text(
                              'Confirm Pickup',
                              style: TextStyle(
                                  fontSize: 20, fontFamily: 'Brand-Bold'),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 18.0,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'images/pickicon.png',
                            height: 16,
                            width: 16,
                          ),
                          SizedBox(
                            width: 18,
                          ),
                          Expanded(
                              child: TextField(
                            controller: pickupController,
                            decoration: InputDecoration(
                              hintText: 'Pickup Location',
                              fillColor: Colors.grey[200],
                              filled: true,
                            ),
                          ))
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'images/desticon.png',
                            height: 18,
                            width: 18,
                          ),
                          SizedBox(
                            width: 18,
                          ),
                          Expanded(
                              child: TextField(
                            onChanged: (value) {
                              searchPlace(value = 'El-shrouk academy');
                            },
                            focusNode: foucsDest,
                            controller: destinationController,
                            decoration: InputDecoration(
                              hintText: 'El-shrouk academy',
                              fillColor: Colors.grey[200],
                              filled: true,
                            ),
                          ))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            (destinationPredictionList.length > 0)
                ? ListView.separated(
                    physics: ScrollPhysics(),
                    padding: EdgeInsets.all(5),
                    itemBuilder: (context, index) {
                      return PredictionTile(
                        prediction: destinationPredictionList[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(
                      height: 1,
                      color: Color(0xFFe2e2e2),
                      thickness: 1.0,
                    ),
                    itemCount: 1,
                    shrinkWrap: true,
                  )
                : Container(
                    child: Text(''),
                  )
          ],
        ),
      ),
    );
  }
}
