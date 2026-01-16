import 'package:flutter/material.dart';

class LabeledCardWidget extends StatelessWidget {
  final String head;
  final Widget child;
  final GestureLongPressCallback? onLongPress;
  const LabeledCardWidget(this.head, this.child, {super.key, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final headStyle = Theme.of(context).textTheme.titleLarge;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      elevation: 8,
      child: InkWell(
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Text(head, style: headStyle),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
