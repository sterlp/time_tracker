import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/common/widget/date_time_form_field.dart';

class EditBookingPage extends StatelessWidget {
  final TimeBooking booking;
  final dateTimeFormat = DateFormat('EEEE dd.MM.yyy HH:mm');

  EditBookingPage(this.booking, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const bold = TextStyle(fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: AppBar(
        title: Text(booking.id == null ? 'Neue Buchung' : 'Buchung bearbeiten'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.done)),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: DateTimeFormField(
              booking.start,
              (d) {
                print('new date time selected $d');
              },
              decoration: const InputDecoration(hintText: 'Startzeit', label: Text('Startzeit')),
            ),
          ),
          ListTile(
            title: DateTimeFormField(
              booking.end,
                  (d) {
                print('new date time selected $d');
              },
              decoration: const InputDecoration(label: Text('Ende')),
            ),
          ),
          ListTile(
            title: TextFormField(
              initialValue: booking.end == null ? null : dateTimeFormat.format(booking.end!),
              decoration: const InputDecoration(hintText: 'Ende', label: Text('Ende')),
              onTap: () async {
                final date = booking.end ?? booking.start;
                final d = await showDatePicker(context: context,
                    initialDate: date,
                    firstDate: booking.start,
                    lastDate: date.add(const Duration(days: 1)));
                print('selected date '
                    + (d == null ? '-' : d.toString()));
                if (d != null) {
                  final d = booking.end ?? booking.start;
                  showTimePicker(context: context,
                      initialTime: TimeOfDay(hour: d.hour, minute: d.minute)
                  );
                }
              },
            ),
          ),
        ],
      )
    );
  }

  void _save() {

  }
}
