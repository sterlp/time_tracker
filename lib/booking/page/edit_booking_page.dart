import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/service/booking_service.dart';
import 'package:time_tracker/booking/entity/time_booking.dart';
import 'package:time_tracker/booking/widget/delete_booking_dialog.dart';
import 'package:time_tracker/common/feedback.dart';
import 'package:time_tracker/common/widget/date_time_form_field.dart';
import 'package:time_tracker/common/widget/form/duration_form_field.dart';
import 'package:time_tracker/common/time_util.dart';

Future<TimeBooking?> showEditBookingPage(
    BuildContext context,
    AppContainer container,
    {TimeBooking? booking,}) {
  final b = booking ?? TimeBooking.now();
  return Navigator.push<TimeBooking>(
    context,
    MaterialPageRoute(builder: (context) => EditBookingPage(container, b)),
  );
}

Future<void> showBookingPageWithCallback(
    BuildContext context,
    AppContainer container,
    VoidCallback? onChanged,
    {TimeBooking? booking,}) async {

  FeedbackFixed.touch(context);
  final r = await showEditBookingPage(context, container, booking: booking);
  if (r != null && onChanged != null) onChanged();
}

class EditBookingPage extends StatefulWidget {
  final AppContainer _container;
  final TimeBooking _booking;
  final dateTimeFormat = DateTimeUtil.getFormat('EEEE dd.MM.yyyy HH:mm');

  EditBookingPage(this._container, this._booking, {Key? key}) : super(key: key);

  @override
  _EditBookingPageState createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  final _formKey = GlobalKey<FormState>();
  TimeBooking _booking = TimeBooking.now();
  bool _valid = false;

  @override
  void initState() {
    super.initState();
    _booking.setMap(widget._booking.asMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_booking.id == null ? 'Neue Buchung' : 'Buchung bearbeiten'),
        actions: [
          IconButton(onPressed:
            _valid ? FeedbackFixed.wrapTouch(_save, context) : null,
            icon: const Icon(Icons.done),),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              DurationFormField(
                duration: _booking.targetWorkTime,
                decoration: const InputDecoration(label: Text('Tagessoll')),
                onChanged: _setWorkTime,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: ElevatedButton.icon(
                  onPressed: _booking.id == null ? null : _doDelete,
                  icon: const Icon(MdiIcons.delete),
                  label: const Text('Löschen'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size.fromHeight(40),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Future<void> _doDelete() async {
    final r = await showConfirmDeleteBookingDialog(context, _booking);
    if (r != null && r) {
      _booking = await widget._container.get<BookingService>().delete(_booking);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Buchung von ${toHoursWithMinutes(_booking.start)} Uhr gelöscht.'),
        ),);
        Navigator.pop(context, null);
      }
    }
  }

  void _setWorkTime(Duration workTime) {
    _booking.targetWorkTime = workTime;
    _validate();
  }
  void _setStart(DateTime newDate) {
    _booking.start = newDate;
    _validate();
  }
  void _setEnd(DateTime newDate) {
    _booking.end = newDate;
    _validate();
  }

  bool _validate() {
    final v = _formKey.currentState!.validate();
    setState(() => _valid = v);
    return v;
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      _booking = await widget._container.get<BookingService>().save(_booking);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Buchung gespeichert.')));
        Navigator.pop(context, _booking);
      }
    }
  }
}
