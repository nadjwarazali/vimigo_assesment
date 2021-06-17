import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {

  final String titleText;

  const TitleWidget({Key key, this.titleText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: EdgeInsets.only(left: 20, top: 40),
        child: Text(
          titleText,
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
            fontSize: 40,
          ),
          textAlign: TextAlign.left,
        ));
  }
}
