import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String caption;

  const LoadingWidget({super.key, this.caption = 'Lade ...'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              child: CircularProgressIndicator(strokeWidth: 8.0),
              height: 60,
              width: 60,
            ),
            const SizedBox(height: 24),
            Text(caption, style: Theme.of(context).textTheme.headline5)
          ]
        )
      ),
    );
  }
}