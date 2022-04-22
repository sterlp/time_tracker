import 'package:flutter/material.dart';

class LabeledCardWidget extends StatelessWidget {
  final String head;
  final Widget body;
  final GestureLongPressCallback? onLongPress;
  const LabeledCardWidget(this.head, this.body, {Key? key, this.onLongPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headStyle = Theme.of(context).textTheme.headline6;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      elevation: 8,
      child: InkWell(
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(head, style: headStyle,),
              body,
            ],
          ),
        ),
      ),
    );
  }
}
