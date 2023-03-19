
import 'dart:io';

import 'package:dependency_container/dependency_container.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:time_tracker/booking/service/booking_service.dart';
import 'package:time_tracker/common/time_util.dart';
import 'package:time_tracker/config/entity/config_entity.dart';
import 'package:time_tracker/export/service/export_service.dart';
import 'package:time_tracker/export/widget/export_by_month.dart';

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
            child: Text('Menü', style: Theme.of(context).textTheme.headline4,),),
          ListTile(
            leading: const Icon(MdiIcons.wrenchClock),
            title: const Text('Tagesarbeitszeit'),
            subtitle: Text(toDurationHoursAndMinutes(config.getDailyWorkHours())),
            onTap: () => _updateWorkTime(context),
          ),
          ListTile(
            leading: const Icon(Icons.upload_sharp),
            title: const Text('Datensicherung importieren'),
            onTap: _importBackup,
          ),
          ListTile(
            leading: const Icon(Icons.download_sharp),
            title: const Text('Alle Daten exportieren'),
            subtitle: const Text('(Datensicherung)'),
            onTap: _createDataBackup,
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Übersicht nach Monat'),
            onTap: () => exportBookingsByMonth(context,
              widget._container.get<ExportService>(),
              widget._container.get<BookingService>(),),
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

  Future<void> _createDataBackup() async {
    final now = DateTime.now();
    final f = await widget._container.get<ExportService>().exportAllToFile(
        fileName: 'Datensicherung ${now.month}-${now.year}.csv',
    );
    await Share.shareXFiles([XFile(f.path, mimeType: 'text/csv')],);
    f.delete();
  }

  Future<void> _importBackup() async {
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
