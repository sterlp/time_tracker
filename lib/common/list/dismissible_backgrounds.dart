
import 'package:flutter/material.dart';

Widget deleteDismissibleBackground(BuildContext context) {
  return Container(color: Colors.red,
    child: Row(children: [
      Expanded(child: Container()),
      const Icon(Icons.delete),
      Container(width: 32,)
    ],),
    alignment: Alignment.centerRight,
  );
}

Widget editDismissibleBackground(BuildContext context) {
  return Container(color: Colors.green,
    child: Row(children: [
      Container(width: 32,),
      const Icon(Icons.create),
      Expanded(child: Container()),
    ],),
    alignment: Alignment.centerLeft,
  );
}