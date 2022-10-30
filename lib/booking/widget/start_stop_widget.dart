import 'dart:math';

import 'package:flutter/material.dart';
import 'package:time_tracker/common/feedback.dart';

const _sizeFactor = 2.5;

class StartAndStopWidget extends StatelessWidget {

  final Duration _workTime;
  final Duration _targetWorkTime;
  final bool _showStart;
  final Function() _startPress;

  const StartAndStopWidget(this._showStart,
      this._workTime, this._targetWorkTime, this._startPress,
      {Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final color = _showStart ? Colors.lightGreen : Colors.amber;

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        _buildDailyProgress(context, color),
        _buildStartButton(context, color),
      ],
    );
  }

  SizedBox _buildDailyProgress(BuildContext context, MaterialColor color) {
    final size = min(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height,) / _sizeFactor;
    final stroke = size / 10;

    final progress = _workTime.inSeconds / _targetWorkTime.inSeconds;
    return SizedBox(
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: stroke,
        color: color,
      ),
      height: size + stroke * 2,
      width: size + stroke * 2,
    );
  }

  Widget _buildStartButton(BuildContext context, MaterialColor color) {
    Widget text;
    if (_showStart) {
      text = Text('Start',
        style: Theme.of(context).textTheme.headline4,);
    } else {
      text = Text('Stopp',
        style: Theme.of(context).textTheme.headline4,);
    }
    final size = min(MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height,) / _sizeFactor;

    return ElevatedButton(
      onPressed: FeedbackFixed.wrapTouch(_startPress, context),
      child: FittedBox(child: text),
      style: ElevatedButton.styleFrom(
        enableFeedback: true,
        shape: const CircleBorder(),
        elevation: 6.0,
        fixedSize: Size(size, size),
        primary: color,
      ),
    );
  }
}
