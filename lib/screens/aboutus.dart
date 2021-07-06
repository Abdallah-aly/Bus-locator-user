import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  static const String id = 'aboutus';
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HII'),
            Text('this is about us page'),
          ],
        ),
      ),
    );
  }
}
