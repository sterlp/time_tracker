
class ExportField {
  final String name;
  final String value;

  ExportField(this.name, this.value);
}

class ExportFields {
  final fields = <ExportField>[
    ExportField("Leer", "leer"),
    ExportField("Kalender Woche", "KW")
  ];
}
