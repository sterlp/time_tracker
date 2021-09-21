import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';

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
            title: TextFormField(
              decoration: InputDecoration(hintText: 'Start', label: Text('Start')),
            ),
          )
        ],
      )
    );
  }

  void _save() {

  }
}
