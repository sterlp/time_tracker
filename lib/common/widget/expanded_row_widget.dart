import 'package:flutter/material.dart';
import 'package:time_tracker/common/widget_functions.dart';

class ExpandedRowWidget extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;

  const ExpandedRowWidget({super.key,
    this.children = const <Widget>[],
    this.padding = const EdgeInsets.fromLTRB(4, 8, 4, 0)
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: expandWidgets(children),
      ),
    );
  }
}
