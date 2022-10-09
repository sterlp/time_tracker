
import 'dart:io';

import 'package:dependency_container/dependency_container.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:sqflite_entities/entity/query.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/config/entity/config_entity.dart';
import 'package:time_tracker/export/service/export_service.dart';
import 'package:time_tracker/util/time_util.dart';

class ExportDataWidget extends StatefulWidget {
  final AppContainer _container;
  const ExportDataWidget(this._container, {Key? key}) : super(key: key);

  @override
  State<ExportDataWidget> createState() => _ExportDataWidgetState();
}

class _ExportDataWidgetState extends State<ExportDataWidget> {
  @override
  Widget build(BuildContext context) {
    return _exportOptions(context);
  }

  Widget _exportOptions(BuildContext context) {
    final config = widget._container.get<TimeTrackerConfig>();
    return SingleChildScrollView(
      child: ListBody(
        children: [
          DrawerHeader(
              child: Text('Menü', style: Theme.of(context).textTheme.headline4,)),
          ListTile(
            leading: const Icon(Icons.hourglass_bottom),
            title: const Text('Tagesarbeitszeit'),
            subtitle: Text(toDurationHoursAndMinutes(config.getDailyWorkHours())),
            onTap: () => _updateWorkTime(context),
          ),
          ListTile(
            leading: const Icon(Icons.download_sharp),
            title: const Text('Alle Daten exportieren'),
            subtitle: const Text('(Datensicherung)'),
            onTap: () => _export(context),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Übersicht nach Monat'),
            onTap: () => _exportMonth(context),
          ),
          ListTile(
            leading: const Icon(Icons.upload_sharp),
            title: const Text('Datensicherung importieren'),
            onTap: () => _importBackup(context),
          ),
        ],
      ),
    );
  }

  Future<void> _updateWorkTime(BuildContext context) async {
    final config = widget._container.get<TimeTrackerConfig>();
    var workTime = config.getDailyWorkHours();
    final newTime = await showTimePicker(context: context,
      initialTime: TimeOfDay(
        hour: workTime.inHours,
        minute: workTime.inMinutes- (workTime.inHours * 60),
      ),
    );
    if (newTime != null) {
      workTime = Duration(hours: newTime.hour, minutes: newTime.minute);
      config.setDailyWorkHours(workTime);
      setState(() {});
    }
  }

  Future<void> _exportMonth(BuildContext context) async {
    final exportFileName = 'Monats Export ${DateTimeUtil.formatWithString(DateTime.now(), "MM.y")}.csv';
    final bookings = await widget._container.get<BookingService>().all(order: SortOrder.ASC);
    final csvData = widget._container.get<ExportService>().toMonthCsvData(bookings);
    final f = await widget._container.get<ExportService>().writeToFile(csvData, fileName: exportFileName);

    await Share.shareFiles(
      [f.path],
      subject: exportFileName, mimeTypes: ['text/csv'],);
    f.delete();
  }
  Future<void> _export(BuildContext context) async {
    final f = await widget._container.get<ExportService>().exportAllToFile();
    await Share.shareFiles(
      [f.path],
      subject: 'Datenexport.csv', mimeTypes: ['text/csv'],);
    f.delete();
  }

  Future<void> _importBackup(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Daten Export CSV auswählen',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      SnackBar message;
      try {
        final csvData = await File(result.files.single.path!).readAsString();
        final imported = await widget._container.get<ExportService>().importBackup(csvData);
        message = SnackBar(
          content: Text('${imported.length} Buchungen importiert.'),);
      } on Exception catch (e) {
        message = SnackBar(
          content: Text('Fehler: $e'),);
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(message);
    }
  }
}
