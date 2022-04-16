import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String caption;

  const LoadingWidget({Key? key, this.caption = 'Lade ...'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(padding: const EdgeInsets.all(32),
              child: OrientationBuilder(
                builder: (context, o) {
                  return AspectRatio(
                    aspectRatio: o == Orientation.portrait ? 2 / 1 : 5 / 1,
                    child: const Image(image: AssetImage('assets/icon/time_tracker_icon.png')),
                  );
                },
              ),
            ),
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