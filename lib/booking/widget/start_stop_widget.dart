import 'dart:math';
import 'package:flutter/material.dart';
import 'package:time_tracker/common/feedback.dart';
import 'package:time_tracker/common/logger.dart';

class StartAndStopWidget extends StatelessWidget {
  static final _log = LoggerFactory.get<StartAndStopWidget>();
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
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final size = constraints.biggest;
          if (_isInvalidSize(size)) return Container();
          return Stack(
            alignment: AlignmentDirectional.center,
            children: [
              // ensure the full widget size, as the progress indicator wont
              SizedBox(width: _circleSize(size), height: _circleSize(size)),
              _buildDailyProgress(size, color),
              _buildStartButton(context, size, color),
            ],
          );
        },
    );
  }

  bool _isInvalidSize(Size size) {
    if (size.width < 0 || size.height < 0) return true;
    if (size.width == double.infinity && size.height  == double.infinity) return true;
    return false;
  }
  double _circleSize(Size size) {
    return min(size.height, size.width);
  }
  double _strokeSize(Size size) {
    return max(5.0, _circleSize(size) / 15);
  }

  Widget _buildDailyProgress(Size size, MaterialColor color) {
    final stroke = _strokeSize(size);
    final circleSize = _circleSize(size) - stroke;

    _log.debug('progress size $size width ${size.width} height ${size.height}');

    final progress = _workTime.inSeconds / _targetWorkTime.inSeconds;
    return SizedBox(
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: stroke,
        color: color,
      ),
      height: circleSize,
      width: circleSize,
    );
  }

  Widget _buildStartButton(BuildContext context, Size size, MaterialColor color) {
    Widget text;
    if (_showStart) {
      text = Text('Start',
        style: Theme.of(context).textTheme.headline4,);
    } else {
      text = Text('Stopp',
        style: Theme.of(context).textTheme.headline4,);
    }
    final widgetSize = _circleSize(size) - _strokeSize(size) * 3;

    return ElevatedButton(
      onPressed: FeedbackFixed.wrapTouch(_startPress, context),
      child: FittedBox(child: text),
      style: ElevatedButton.styleFrom(
        enableFeedback: true,
        shape: const CircleBorder(),
        elevation: 8.0,
        fixedSize: Size(widgetSize, widgetSize),
        backgroundColor: color,
      ),
    );
  }
}
