
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite_entities/entity/query.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/export/export_service.dart';

void showExportDialogWidget(BuildContext context, AppContainer container) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Daten Export'),
      content: ExportDataWidget(container),
    ),
  );
}

class ExportDataWidget extends AlertDialog {
  final AppContainer _container;
  final ValueNotifier<bool> _isExporting = ValueNotifier(false);
  ExportDataWidget(this._container, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: _isExporting,
        builder: (context, value, child) {
          if (value) return _exporting(context);
          else return _exportOptions(context);
        }
    );
    _exporting(context); // _exportOptions(context);
  }
  Widget _exporting(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CircularProgressIndicator(),
        Text('Exportiere Daten ...')
      ],
    );
  }
  Widget _exportOptions(BuildContext context) {
    return SingleChildScrollView(
      child: ListBody(
        children: [
          SimpleDialogOption(
            // padding: EdgeInsets,
            child: Text('Alle Daten exportieren (Datensicherung)'),
            onPressed: () => _export(context),
          ),
          SimpleDialogOption(
            // padding: EdgeInsets,
            child: Text('Export nach Monat'),
            onPressed: () => _exportMonth(context),
          ),
        ],
      ),
    );
  }
  Future<void> _exportMonth(BuildContext context) async {
    _isExporting.value = true;
    final bookings = await _container.get<BookingService>().all(order: SortOrder.ASC);
    final csvData = _container.get<ExportService>().toMonthCsvData(bookings);
    final f = await _container.get<ExportService>().writeToFile(csvData, fileName: 'Monats Export.csv');

    await Share.shareFiles(
      [f.path],
      subject: 'Monats Export.csv', mimeTypes: ['text/csv'],);

    _isExporting.value = false;
    Navigator.pop(context);
  }
  Future<void> _export(BuildContext context) async {
    _isExporting.value = true;
    final f = await _container.get<ExportService>().exportAllToFile();
    await Share.shareFiles(
      [f.path],
      subject: 'Datenexport.csv', mimeTypes: ['text/csv'],);
    await f.delete();

    _isExporting.value = false;
    Navigator.pop(context);
  }
}
