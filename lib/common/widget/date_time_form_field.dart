import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/common/feedback.dart';

class DateTimeFormField extends StatefulWidget {
  final DateTime? initialDateTime;
  final DateTime? firstDateTime;
  final DateTime? lastDateTime;
  final ValueChanged<DateTime> onChanged;
  final InputDecoration decoration;
  final FormFieldValidator<DateTime?>? validator;

  const DateTimeFormField(this.initialDateTime, this.onChanged,
      {super.key,
        this.decoration = const InputDecoration(),
        this.firstDateTime,
        this.lastDateTime,
        this.validator,
      });

  @override
  State<DateTimeFormField> createState() => _DateTimeFormFieldState();
}

class _DateTimeFormFieldState extends State<DateTimeFormField> {
  DateTime? _dateTime;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateTime = widget.initialDateTime;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_dateTime != null) {
      _controller.text =
        "${DateTimeUtil.formatWithString(_dateTime, 'EEEE, dd.MM.yyyy, HH:mm')} Uhr";
    }
    return TextFormField(
      controller: _controller,
      readOnly: true,
      onTap: FeedbackFixed.wrapTouch(() =>  _pickNewDate(context), context),
      decoration: widget.decoration,
      validator: widget.validator == null ? null : _validate,
    );
  }

  String? _validate(String? v) {
    if (widget.validator != null) return widget.validator!(_dateTime);
    else return null;
  }

  Future<void> _pickNewDate(BuildContext context) async {
    final currentDate = _dateTime ?? widget.firstDateTime ?? DateTime.now();
    var newDate = await showDatePicker(context: context,
      initialDate: currentDate,
      firstDate: widget.firstDateTime ?? currentDate.add(const Duration(days: -30)),
      lastDate: widget.lastDateTime ?? currentDate.add(const Duration(days: 30)),
      confirmText: 'UHRZEIT WÄHLEN',
    );
    if (newDate != null && mounted) {
      final newTime = await showTimePicker(context: context,
        initialTime: TimeOfDay(hour: currentDate.hour, minute: currentDate.minute),
      );
      if (newTime != null) {
        setState(() {
          _dateTime = newDate = DateTimeUtil.asDateTime(newDate!, newTime);
        });
        _controller.text = '${DateTimeUtil.formatWithString(newDate,
            'EEEE, dd.MM.yyyy, HH:mm', null)} Uhr';
        widget.onChanged(newDate!);
      }
    }
  }
}
