
import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/log/logger.dart';

class DateTimeFormField extends StatefulWidget {
  DateTime? dateTime;
  final DateTime? firstDateTime;
  final DateTime? lastDateTime;
  final ValueChanged<DateTime> onChanged;
  final InputDecoration decoration;
  final FormFieldValidator<DateTime?>? validator;

  DateTimeFormField(this.dateTime, this.onChanged,
      {Key? key,
        this.decoration = const InputDecoration(),
        this.firstDateTime,
        this.lastDateTime,
        this.validator,
      }) : super(key: key);

  @override
  _DateTimeFormFieldState createState() => _DateTimeFormFieldState();
}

class _DateTimeFormFieldState extends State<DateTimeFormField> {
  final _controller = TextEditingController();
  final _log = LoggerFactory.get<DateTimeFormField>();

  @override
  Widget build(BuildContext context) {
    final dateTime = widget.dateTime;
    if (dateTime != null) {
      _controller.text = DateTimeUtil.formatWithString(dateTime,
          'EEEE, dd.MM.yyyy, HH:mm', null) + ' Uhr';
    }
    return TextFormField(
      controller: _controller,
      readOnly: true,
      onTap: () => _pickNewDate(context),
      decoration: widget.decoration,
      validator: _validate,
    );
  }

  String? _validate(String? v) {
    _log.debug('validate ${widget.dateTime}');
    if (widget.validator != null) return widget.validator!(widget.dateTime);
    else return null;
  }

  Future<void> _pickNewDate(BuildContext context) async {
    final currentDate = widget.dateTime ?? DateTime.now();
    var newDate = await showDatePicker(context: context,
      initialDate: currentDate,
      firstDate: widget.firstDateTime ?? currentDate.add(const Duration(days: -30)),
      lastDate: widget.lastDateTime ?? currentDate.add(const Duration(days: 30)),
      confirmText: 'UHRZEIT WÄHLEN'
    );
    if (newDate != null) {
      final newTime = await showTimePicker(context: context,
          initialTime: TimeOfDay(hour: currentDate.hour, minute: currentDate.minute)
      );
      if (newTime != null) {
        newDate = DateTimeUtil.asDateTime(newDate, newTime);
        widget.dateTime = newDate;
        _controller.text = DateTimeUtil.formatWithString(newDate,
            'EEEE, dd.MM.yyyy, HH:mm', null) + ' Uhr';
        widget.onChanged(newDate);
      }
    }
  }
}
