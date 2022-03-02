import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_entities/converter/date_util.dart';

class DateTimeFormField extends StatelessWidget {
  final DateTime? dateTime;
  final DateTime? firstDateTime;
  final DateTime? lastDateTime;
  final ValueChanged<DateTime> onChanged;
  final InputDecoration decoration;
  final FormFieldValidator<DateTime?>? validator;
  final _controller = TextEditingController();

  DateTimeFormField(this.dateTime, this.onChanged,
      {Key? key,
        this.decoration = const InputDecoration(),
        this.firstDateTime,
        this.lastDateTime,
        this.validator,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dateTime != null) {
      _controller.text = DateTimeUtil.formatWithString(dateTime,
          'EEEE, dd.MM.yyyy, HH:mm') + ' Uhr';
    }
    return TextFormField(
      controller: _controller,
      readOnly: true,
      onTap: () => Feedback.wrapForTap(() => _pickNewDate(context), context) ,
      decoration: decoration,
      validator: _validate,
    );
  }

  String? _validate(String? v) {
    if (validator != null) return validator!(dateTime);
    else return null;
  }

  Future<void> _pickNewDate(BuildContext context) async {
    final currentDate = dateTime ?? firstDateTime ?? DateTime.now();
    var newDate = await showDatePicker(context: context,
      initialDate: currentDate,
      firstDate: firstDateTime ?? currentDate.add(const Duration(days: -30)),
      lastDate: lastDateTime ?? currentDate.add(const Duration(days: 30)),
      confirmText: 'UHRZEIT WÄHLEN'
    );
    if (newDate != null) {
      final newTime = await showTimePicker(context: context,
        initialTime: TimeOfDay(hour: currentDate.hour, minute: currentDate.minute),
      );
      if (newTime != null) {
        newDate = DateTimeUtil.asDateTime(newDate, newTime);
        _controller.text = DateTimeUtil.formatWithString(newDate,
            'EEEE, dd.MM.yyyy, HH:mm', null) + ' Uhr';
        onChanged(newDate);
      }
    }
  }
}
