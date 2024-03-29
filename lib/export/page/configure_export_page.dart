
import 'dart:ffi';

import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/common/feedback.dart';
import 'package:time_tracker/config/dao/config_dao.dart';
import 'package:time_tracker/config/entity/config_entity.dart';
import 'package:time_tracker/export/entity/export_field.dart';
import 'package:time_tracker/home/widget/loading_widget.dart';

Future<Void?> showConfigureExportPage(
    BuildContext context,
    AppContainer container,) {
  return Navigator.push<Void>(
    context,
    MaterialPageRoute(builder: (context) => ConfigureExportPage(container)),
  );
}

class ConfigureExportPage extends StatefulWidget {
  final AppContainer container;
  const ConfigureExportPage(this.container, {super.key});

  @override
  State<ConfigureExportPage> createState() => _ConfigureExportPageState();
}

class _ConfigureExportPageState extends State<ConfigureExportPage> {

  final ExportFields fields = ExportFields();
  bool _changed = false;

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    widget.container.get<TimeTrackerConfig>().getExportCsvConfig().then((cfg) {
        if (cfg != null && cfg.isNotEmpty) {
          setState(() => fields.selectedValuesString = cfg);
        }
    });
  }

  Future<void> _doSaveConfigAndExit() async {
    await widget.container.get<TimeTrackerConfig>().setExportCsvConfig(
        fields.selectedValuesString);

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Exporteinstellungen gespeichert.')));
      Navigator.pop(context);
    }
  }

  List<Widget> _selectedFields() {
    return _toChips(
      fields.selectedValues, const Icon(Icons.remove),
      (field) => setState(() {
        fields.remove(field);
        _changed = true;
      }),
      Theme.of(context).primaryColorLight,);
  }

  List<Widget> _availableFields() {
    return _toChips(
      fields.availableValues, const Icon(Icons.add),
      (field) => setState(() {
        fields.add(field);
        _changed = true;
      }),
      Theme.of(context).secondaryHeaderColor,);
  }

  List<Widget> _toChips(List<ExportField> fields,
      Icon icon,
      Function(ExportField field)? fn,
      Color? backgroundColor,) {
    final result = <Widget>[];
    for (final field in fields) {
      result.add(Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
          child: Chip(
            label: Text(field.name),
            deleteIcon: icon,
            onDeleted: fn == null ? null : () => fn(field),
            backgroundColor: backgroundColor,
          ),
        ),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Export konfigurieren"),
        actions: [
          IconButton(
            onPressed: _changed ? FeedbackFixed.wrapTouch(_doSaveConfigAndExit, context) : null,
            icon: const Icon(Icons.done),),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(child: Text("Exportierte Felder", style: Theme.of(context).textTheme.headlineSmall,)),
              const Divider(thickness: 1,),
              Wrap(
                children: _selectedFields(),
              ),
              const Divider(thickness: 2,),
              Center(child: Text("Mögliche Felder", style: Theme.of(context).textTheme.headlineSmall,)),
              const Divider(thickness: 1,),
              Wrap(
                children: _availableFields(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
