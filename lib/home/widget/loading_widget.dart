import 'package:flutter/material.dart';
import 'package:time_tracker/common/widget/loading_widget.dart';

class LoadingScaffoldWidget extends StatelessWidget {
  final String caption;

  const LoadingScaffoldWidget({super.key, this.caption = 'Lade ...'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingWidget(caption: caption)
    );
  }
}
