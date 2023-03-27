
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/common/time_util.dart';
import 'package:time_tracker/export/entity/export_day_statistic.dart';

class ExportField {
  final String name;
  final String key;
  final String Function(ExportDailyStats) extract;

  ExportField._(this.name, this.key, this.extract);

  static final empty = ExportField._("Leer", "empty", (_) => "");
  static final cw = ExportField._("Kalenderwoche", "cw", (s) => s.day.weekOfYear.toString());

  static final day = ExportField._("Tag", "day", (s) => dayName.format(s.day));
  static final date = ExportField._("Datum", "date", (s) => dateFormat.format(s.day));
  static final startTime = ExportField._("Arbeitsbeginn", "startTime", (s) => s.startTime);
  static final endTime = ExportField._("Arbeitsende", "endTime", (s) => s.endTime);
  static final workedTime = ExportField._("Arbeitszeit", "workedTime", (s) => s.workedTime);
  static final planedWorkTime = ExportField._("Soll", "planedWorkTime", (s) => s.planedWorkTime);

  static final startFirstBreak = ExportField._("Pause 1 Start", "startFirstBreak", (s) => s.startFirstBreak);
  static final endFirstBreak = ExportField._("Pause 1 Ende", "endFirstBreak", (s) => s.endFirstBreak);
  static final startSecondBreak = ExportField._("Pause 2 Start", "startSecondBreak", (s) => s.startSecondBreak);
  static final endSecondBreak = ExportField._("Pause 2 Ende", "endSecondBreak", (s) => s.endSecondBreak);
  static final startRemainingBreak = ExportField._("Pause Rest Start", "startRemainingBreak", (s) => s.startRemainingBreak);
  static final endRemainingBreak = ExportField._("Pause Rest Ende", "endRemainingBreak", (s) => s.endRemainingBreak);
  static final breakTime = ExportField._("Pausenzeit", "breakTime", (s) => s.breakTime);
}

final dateFormat = DateTimeUtil.getFormat('dd.MM.yyyy');
final dayName = DateTimeUtil.getFormat('EEEE');
const valueSeparator = ";";

class ExportFields {
  final availableValues = <ExportField>[
    ExportField.empty,
    ExportField.cw,
    ExportField.day,
    ExportField.date,
    ExportField.startTime,
    ExportField.endTime,
    ExportField.workedTime,
    ExportField.planedWorkTime,
    ExportField.breakTime,

    ExportField.startFirstBreak,
    ExportField.endFirstBreak,
    ExportField.startSecondBreak,
    ExportField.endSecondBreak,
    ExportField.startRemainingBreak,
    ExportField.endRemainingBreak,
  ];

  /*
'Datum', 'Tag', 'Soll',
      'Arbeitsbeginn', 'Arbeitsende', 'Arbeitszeit',
      'Pause 1 Start', 'Pause 1 Ende',
      'Pause 2 Start', 'Pause 2 Ende',
      'Pause Rest Start', 'Pause Rest Ende',
      'Pausenzeit'
 */
  final selectedValues = <ExportField>[
    ExportField.date,
    ExportField.day,
    ExportField.planedWorkTime,

    ExportField.startTime,
    ExportField.endTime,
    ExportField.workedTime,

    ExportField.startFirstBreak,
    ExportField.endFirstBreak,

    ExportField.startSecondBreak,
    ExportField.endSecondBreak,

    ExportField.startRemainingBreak,
    ExportField.endRemainingBreak,

    ExportField.breakTime
  ];

  List<String> get selectedHeaders {
    return selectedValues.map((e) => e.name).toList();
  }

  String get selectedValuesString {
    return selectedValues.map((e) => e.key).join(valueSeparator);
  }

  set selectedValuesString(String values) {
    selectedValues.clear();
    if (values.isNotEmpty) {
      for (final key in  values.split(valueSeparator)) {
        selectedValues.add(availableValues.firstWhere((e) => e.key == key));
      }
    }
  }

  void selectValues(List<ExportField> fields) {
    clear();
    selectedValues.addAll(fields);
  }

  List<String> exportWith(ExportDailyStats stats) {
    final result = <String>[];
    for (final f in selectedValues) result.add(f.extract(stats));
    return result;
  }

  void clear() {
    selectedValues.clear();
  }
  void add(ExportField field) {
    selectedValues.add(field);
  }
  void remove(ExportField field) {
    selectedValues.remove(field);
  }
}
