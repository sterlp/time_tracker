import 'package:flutter/material.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/common/feedback.dart';

class DateTimeFormField extends StatelessWidget {
  final DateTime? dateTime;
  final DateTime? firstDateTime;
  final DateTime? lastDateTime;
  final ValueChanged<DateTime?> onChanged;
  final InputDecoration decoration;
  final FormFieldValidator<DateTime?>? validator;
  final bool clearable;

  const DateTimeFormField(this.dateTime, this.onChanged,
      {super.key,
        this.decoration = const InputDecoration(),
        this.firstDateTime,
        this.lastDateTime,
        this.validator,
        this.clearable = false,
      });

  String get _displayText => dateTime != null
      ? "${DateTimeUtil.formatWithString(dateTime, 'EEEE, dd.MM.yyyy, HH:mm')} Uhr"
      : '';

  bool get _showClearButton => clearable && dateTime != null;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(dateTime),
      initialValue: _displayText,
      readOnly: true,
      onTap: FeedbackFixed.wrapTouch(() => _pickNewDate(context), context),
      decoration: decoration.copyWith(
        suffixIcon: _showClearButton
            ? IconButton(
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.clear),
                tooltip: 'Löschen',
              )
            : null,
      ),
      validator: validator == null ? null : (_) => validator!(dateTime),
    );
  }

  Future<void> _pickNewDate(BuildContext context) async {
    final now = DateTime.now();
    final currentDate = dateTime ?? firstDateTime ?? now;
    var newDate = await showDatePicker(context: context,
      initialDate: currentDate,
      firstDate: firstDateTime ?? currentDate.add(const Duration(days: -30)),
      lastDate: lastDateTime ?? currentDate.add(const Duration(days: 30)),
      confirmText: 'UHRZEIT WÄHLEN',
    );
    if (newDate != null && context.mounted) {
      // Use current time if no dateTime set and now is after firstDateTime
      final initialTime = dateTime != null
          ? TimeOfDay(hour: dateTime!.hour, minute: dateTime!.minute)
          : (firstDateTime != null && now.isAfter(firstDateTime!))
              ? TimeOfDay(hour: now.hour, minute: now.minute)
              : TimeOfDay(hour: currentDate.hour, minute: currentDate.minute);
      final newTime = await showTimePicker(context: context,
        initialTime: initialTime,
      );
      if (newTime != null) {
        newDate = DateTimeUtil.asDateTime(newDate, newTime);
        onChanged(newDate);
      }
    }
  }
}
