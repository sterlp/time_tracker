
import 'package:flutter/material.dart';

Widget deleteDismissableBackground(BuildContext context) {
  return Container(color: Colors.red,
    child: Row(children: [
      Expanded(child: Container()),
      const Icon(Icons.delete),
      Container(width: 32,)
    ],),
    alignment: Alignment.centerRight,);
}