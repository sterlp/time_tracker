
import 'dart:ffi';

import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';

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


  List<Widget> _selectedFields() {
    final result = <Widget>[];
    for(int i = 0; i < 10; i++) {
      result.add(Chip(
        label: Text("fooo $i"),
        deleteIcon: const Icon(Icons.close),
        onDeleted: () => {},
        backgroundColor: Theme.of(context).primaryColor.withAlpha(80),),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Export konfigurieren")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(child: Text("Exportierte Felder", style: Theme.of(context).textTheme.headlineSmall,)),
            const Divider(),
            Wrap(
              children: _selectedFields(),
            ),
            Divider(thickness: 2,),
            Center(child: Text("Mögliche Felder", style: Theme.of(context).textTheme.headlineSmall,)),
            const Divider(),
            Wrap(
              children: [
                Chip(label: Text("fooo 1")),
                Chip(label: Text("fooo 2")),
                Chip(label: Text("fooo 3")),
                Chip(label: Text("fooo 4")),
                Chip(label: Text("fooo 4")),
                Chip(label: Text("fooo 4")),
                Chip(label: Text("fooo 4")),
                Chip(label: Text("fooo 4")),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
