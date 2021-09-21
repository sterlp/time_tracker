
import 'package:flutter/material.dart';

List<Widget> expandWidgets(List<Widget> widgets) {
  final results = <Widget>[];
  for (final w in widgets) results.add(Expanded(child: w));
  return results;
}