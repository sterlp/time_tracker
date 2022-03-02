import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/widget/time_account.dart';
import 'package:time_tracker/common/widget/date_time_form_field.dart';
import 'package:time_tracker/log/logger.dart';
import 'package:time_tracker/util/time_util.dart';

Future<TimeBooking?> showEditBookingPage(
    BuildContext context,
    {TimeBooking? booking}) {
  booking ??= TimeBooking.now();
  return Navigator.push<TimeBooking?>(
    context,
    MaterialPageRoute(builder: (context) => EditBookingPage(booking!)),
  );
}

class EditBookingPage extends StatefulWidget {
  final TimeBooking booking;
  final dateTimeFormat = DateTimeUtil.getFormat('EEEE dd.MM.yyyy HH:mm', 'de');

  EditBookingPage(this.booking, {Key? key}) : super(key: key);

  @override
  _EditBookingPageState createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  final _log = LoggerFactory.get<EditBookingPage>();
  final _formKey = GlobalKey<FormState>();
  final _booking = TimeBooking.now();
  bool valid = false;

  @override
  void initState() {
    _booking.setMap(widget.booking.asMap());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _log.debug('build ...');
    // const bold = TextStyle(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(
        title: Text(_booking.id == null ? 'Neue Buchung' : 'Buchung bearbeiten'),
        actions: [
          IconButton(onPressed:
            valid ? Feedback.wrapForTap(_save, context) : null,
            icon: const Icon(Icons.done)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: toDurationHoursAndMinutes(_booking.targetWorkTime),
                decoration: const InputDecoration(label: Text('Tagessoll')),
                readOnly: true,
              ),
              DateTimeFormField(
                _booking.start,
                _setStart,
                decoration: const InputDecoration(label: Text('Start')),
              ),
              DateTimeFormField(
                _booking.end,
                _setEnd,
                validator: (value) { // value is the last state of the widget
                  String? msg;
                  if (_booking.end == null) {
                    msg = null;
                  } else if (_booking.end!.isBefore(_booking.start)) {
                    msg = 'Endedatum muss vor dem Startdatum  liegen.';
                  }
                  return msg;
                },
                decoration: const InputDecoration(label: Text('Ende')),
                firstDateTime: _booking.start,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TimeAccount(_booking.targetWorkTime, _booking.workTime),
              )
            ],
          ),
        ),
      )
    );
  }

  void _setStart(DateTime newDate) {
    _booking.start = newDate;
    setState(() {
      valid = _formKey.currentState!.validate();
    });
  }
  void _setEnd(DateTime newDate) {
    _booking.end = newDate;
    setState(() {
      valid = _formKey.currentState!.validate();
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.booking.setMap(_booking.asMap());
      Navigator.pop(context, widget.booking);
    }
  }
}
