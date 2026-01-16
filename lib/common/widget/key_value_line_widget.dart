import 'package:flutter/material.dart';

///
/// Expands the space between the given widgets.
class KeyValueLineWidget extends StatelessWidget {
  final Widget label;
  final Widget value;

  const KeyValueLineWidget(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      label,
      Expanded(child: Container()),
      value
    ],);
  }
}
