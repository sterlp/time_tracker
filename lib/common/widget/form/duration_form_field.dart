import 'package:flutter/material.dart';
import 'package:time_tracker/common/feedback.dart';
import 'package:time_tracker/util/time_util.dart';

class DurationFormField extends StatelessWidget {
  final ValueChanged<Duration>? onChanged;
  final InputDecoration decoration;
  final FormFieldValidator<Duration>? validator;
  Duration duration;
  final _controller = TextEditingController();

  DurationFormField(
      {Key? key,
        this.duration = Duration.zero,
        this.decoration = const InputDecoration(),
        this.onChanged,
        this.validator,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _controller.text = toDurationHoursAndMinutes(duration);
    final result = TextFormField(
      controller: _controller,
      readOnly: true,
      onTap: onChanged == null ? null : FeedbackFixed.wrapTouch(() =>  _pickTime(context), context),
      decoration: decoration,
      validator: validator == null ? null : _validate,
    );
    return result;
  }

  String? _validate(String? v) {
    if (validator != null) return validator!(duration);
    else return null;
  }

  Future<void> _pickTime(BuildContext context) async {
    final newTime = await showTimePicker(context: context,
      helpText: 'Zeit wählen',
      initialTime: TimeOfDay(
        hour: duration.inHours,
        minute: duration.inMinutes - duration.inHours * 60,
      ),
    );
    if (newTime != null && onChanged != null) {
      duration = Duration(hours: newTime.hour, minutes: newTime.minute);
      onChanged!(duration);
    }
  }
}
