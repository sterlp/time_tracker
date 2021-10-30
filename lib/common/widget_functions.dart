
import 'package:flutter/material.dart';

List<Widget> expandWidgets(List<Widget> widgets) {
  final results = <Widget>[];
  for (final w in widgets) results.add(Expanded(child: w));
  return results;
}

Widget paddingRow({List<Widget> children = const [], EdgeInsets padding = const EdgeInsets.fromLTRB(8, 8, 4, 8)}) {
  return Row(
    children: children.map((e) => Padding(padding: padding, child: e,)).toList(),
  );
}