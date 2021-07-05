import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:uber/screens/loginpage.dart';
import 'package:uber/screens/mainpage.dart';
import 'package:uber/widgets/taxibutton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity/connectivity.dart';
import 'package:uber/widgets/progressDialog.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'registration';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(
        content: Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 15.0),
    ));
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  final fullNameController = TextEditingController();

  final emailController = TextEditingController();

  final phoneController = TextEditingController();

  final passwordController = TextEditingController();

  void registerUser() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Registering you ..',
      ),
    );

    UserCredential user;
    try {
      user = await auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'weak-password') {
        showSnackBar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showSnackBar('The account already exists for that email.');
      }
    }

    if (user != null) {
      DatabaseReference newUserRef =
          FirebaseDatabase.instance.reference().child('users/${user.user.uid}');
      Map userMap = {
        'fullname': fullNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
      };
      newUserRef.set(userMap);
      Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Image(
                        image: AssetImage('images/logo.png'),
                        alignment: Alignment.center,
                        height: 100.0,
                        width: 100.0,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'Create a Rider\'s Account',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 15.0, fontFamily: 'Brand-Bold'),
                      ),
                      //fullname
                      TextField(
                        controller: fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Full name',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0)),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(height: 5.0),
                      //email
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'E-mail address',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0)),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(height: 5.0),
                      //phone
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Phone number',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0)),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(height: 5.0),
                      //password
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 10.0)),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(height: 20),
                      TaxiButton(
                        text: "REGISTER",
                        color: Colors.yellow[700],
                        onPressed: () async {
                          //check connectivity
                          var connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar('You are Offline');
                            return;
                          }

                          if (fullNameController.text.length < 3) {
                            showSnackBar('Please provide a valid full name');
                            return;
                          }
                          if (!emailController.text.contains('@')) {
                            showSnackBar('Please provide a valid E-mail');
                            return;
                          }
                          if (phoneController.text.length < 10 ||
                              phoneController.text.length > 12) {
                            showSnackBar('Please provide a valid phone number');
                            return;
                          }
                          if (passwordController.text.isEmpty) {
                            showSnackBar('Please Add Password');
                            return;
                          } else if (passwordController.text.length < 9) {
                            showSnackBar('Week Password');
                            return;
                          }
                          registerUser();
                        },
                      ),
                      SizedBox(height: 15),
                      FlatButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, LoginPage.id, (route) => false);
                        },
                        child: Text(
                          'Already have a RIDER account? Log in',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 70.0),
            ClipPath(
              clipper: WaveClipperTwo(flip: true, reverse: true),
              child: Container(
                height: 145,
                color: Colors.yellow[700],
                child: Center(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
