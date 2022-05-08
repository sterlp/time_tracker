
import 'dart:io';
import 'package:dependency_container/dependency_container.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite_entities/entity/query.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/export/service/export_service.dart';

class ExportDataWidget extends StatelessWidget {
  final AppContainer _container;

  const ExportDataWidget(this._container, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _exportOptions(context);
  }

  Widget _exportOptions(BuildContext context) {
    return SingleChildScrollView(
      child: ListBody(
        children: [
          DrawerHeader(
            child: Text('Menü', style: Theme.of(context).textTheme.headline4,)),
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
  Future<void> _exportMonth(BuildContext context) async {
    final bookings = await _container.get<BookingService>().all(order: SortOrder.ASC);
    final csvData = _container.get<ExportService>().toMonthCsvData(bookings);
    final f = await _container.get<ExportService>().writeToFile(csvData, fileName: 'Monats Export.csv');

    await Share.shareFiles(
      [f.path],
      subject: 'Monats Export.csv', mimeTypes: ['text/csv'],);
    f.delete();
  }
  Future<void> _export(BuildContext context) async {
    final f = await _container.get<ExportService>().exportAllToFile();
    await Share.shareFiles(
      [f.path],
      subject: 'Datenexport.csv', mimeTypes: ['text/csv'],);
    f.delete();
  }

  Future<void> _importBackup(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Daten Export CSV auswählen',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      SnackBar message;
      try {
        final csvData = await File(result.files.single.path!).readAsString();
        final imported = await _container.get<ExportService>().importBackup(csvData);
        message = SnackBar(
            content: Text('${imported.length} Buchungen importiert.'),);
      } on Exception catch (e) {
        message = SnackBar(
            content: Text('Fehler: $e'),);
      }
      ScaffoldMessenger.of(context).showSnackBar(message);
    }
  }
}
