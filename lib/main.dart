import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber/dataprovider/appdata.dart';
import 'package:uber/globalVars.dart';
import 'package:uber/screens/loginpage.dart';
import 'package:uber/screens/registrationpage.dart';
import 'screens/mainpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: Platform.isIOS || Platform.isMacOS
        ? FirebaseOptions(
            appId: '1:258088443921:ios:4404b8c7db6c4894f4d1b0',
            apiKey: 'AIzaSyD_shO5mfO9lhy2TVWhfo1VUmARKlG4suk',
            projectId: 'flutter-firebase-plugins',
            messagingSenderId: '258088443921',
            databaseURL: 'https://geetaxi-dad9c-default-rtdb.firebaseio.com',
          )
        : FirebaseOptions(
            appId: '1:258088443921:android:740e3531df862fccf4d1b0',
            apiKey: 'AIzaSyAlZs2dXoqS-I9PN1RDxsajKi9TGdDVw3s',
            messagingSenderId: '297855924061',
            projectId: 'flutter-firebase-plugins',
            databaseURL: 'https://geetaxi-dad9c-default-rtdb.firebaseio.com',
          ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User currentUser = FirebaseAuth.instance.currentUser;
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme:
            ThemeData(primarySwatch: Colors.blue, fontFamily: 'Brand-Regular'),
        initialRoute: (currentUser != null) ? MainPage.id : RegistrationPage.id,
        routes: {
          RegistrationPage.id: (context) => RegistrationPage(),
          LoginPage.id: (context) => LoginPage(),
          MainPage.id: (context) => MainPage(),
        },
      ),
    );
  }
}
