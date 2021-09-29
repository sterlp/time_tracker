
import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';

class DateTimeFormField extends StatefulWidget {
  final DateTime? initialDateTime;
  final DateTime? firstDateTime;
  final ValueChanged<DateTime> onChanged;
  final InputDecoration decoration;

  const DateTimeFormField(this.initialDateTime, this.onChanged,
      {Key? key,
        this.decoration = const InputDecoration(),
        this.firstDateTime,
      }) : super(key: key);

  @override
  _DateTimeFormFieldState createState() => _DateTimeFormFieldState();
}

class _DateTimeFormFieldState extends State<DateTimeFormField> {
  final _controller = TextEditingController();
  DateTime? _dateTime;

  @override
  Widget build(BuildContext context) {
    final d = _dateTime ?? widget.initialDateTime;
    if (d == null) {
      _controller.text = '';
    } else {
      _controller.text = DateTimeUtil.formatWithString(d, 'EEEE, dd.MM.yyyy, HH:mm', null)
          + ' Uhr';
    }
    return TextFormField(
      readOnly: true,
      controller: _controller,
      onTap: _pickNewDate,
      decoration: widget.decoration,
    );
  }

  Future<void> _pickNewDate() async {
    final currentDate = _dateTime ?? widget.initialDateTime ?? DateTime.now();
    var newDate = await showDatePicker(context: context,
      initialDate: currentDate,
      firstDate: currentDate.add(const Duration(days: -1)),
      lastDate: currentDate.add(const Duration(days: 1)),
      confirmText: 'UHRZEIT WÄHLEN'
    );
    if (newDate != null) {
      final newTime = await showTimePicker(context: context,
          initialTime: TimeOfDay(hour: currentDate.hour, minute: currentDate.minute)
      );
      if (newTime != null) {
        newDate = DateTimeUtil.asDateTime(newDate, newTime);
        widget.onChanged(newDate);
        setState(() => _dateTime = newDate);
      }
    }
  }
}
