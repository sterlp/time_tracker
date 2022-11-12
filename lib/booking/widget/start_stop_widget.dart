import 'dart:math';

import 'package:flutter/material.dart';
import 'package:time_tracker/common/feedback.dart';
import 'package:time_tracker/common/logger.dart';

class StartAndStopWidget extends StatelessWidget {
  final Duration _workTime;
  final Duration _targetWorkTime;
  final bool _showStart;
  final Function() _startPress;

  const StartAndStopWidget(this._showStart,
      this._workTime, this._targetWorkTime, this._startPress,
      {Key? key,}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final color = _showStart ? Colors.lightGreen : Colors.amber;
    final size = _size(context);
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        // ensure the full widget size, as the progress indicator wont
        SizedBox(width: size, height: size),
        _buildDailyProgress(context, Colors.deepOrange),
        _buildStartButton(context, color),
      ],
    );
  }

  double _size(BuildContext context) {
    return min(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height,) / 2;
  }
  double _strokeSize(BuildContext context) {
    return max(10.0, _size(context) / 15);
  }

  Widget _buildDailyProgress(BuildContext context, MaterialColor color) {
    final stroke = _strokeSize(context);
    final size = _size(context) - stroke;

    final progress = _workTime.inSeconds / _targetWorkTime.inSeconds;
    return SizedBox(
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: stroke,
        color: color,
      ),
      height: size,
      width: size,
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
    final size = _size(context) - _strokeSize(context) * 4;

    return ElevatedButton(
      onPressed: FeedbackFixed.wrapTouch(_startPress, context),
      child: FittedBox(child: text),
      style: ElevatedButton.styleFrom(
        enableFeedback: true,
        shape: const CircleBorder(),
        elevation: 8.0,
        fixedSize: Size(size, size),
        backgroundColor: color,
      ),
    );
  }
}
