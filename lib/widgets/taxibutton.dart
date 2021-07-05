import 'package:flutter/material.dart';

class TaxiButton extends StatelessWidget {
  final String text;
  final Color color;
  final Function onPressed;

  TaxiButton({this.text, this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: color,
      textColor: Colors.white,
      padding: EdgeInsets.all(15),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 18),
        ),
      ),
    );
  }
}
