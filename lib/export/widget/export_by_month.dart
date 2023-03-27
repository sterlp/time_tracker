
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite_entities/converter/date_util.dart';
import 'package:time_tracker/booking/service/booking_service.dart';
import 'package:time_tracker/config/entity/config_entity.dart';
import 'package:time_tracker/export/entity/export_field.dart';
import 'package:time_tracker/export/service/export_service.dart';

Future<void> exportBookingsByMonth(BuildContext context,
    TimeTrackerConfig config,
    ExportService exportService, BookingService bookingService) async {
  final now = DateTime.now();
  final monthSelector = now.day > 27 ? now.month : max(now.month - 1, 1);
  DateTime? exportDate = DateTime.now().copyWith(month: monthSelector, day: 1);

  exportDate = await showDatePicker(context: context,
    initialDate: exportDate,
    firstDate: now.copyWith(year: now.year - 20),
    lastDate: now,
    helpText: "START DATUM AUSWÄHLEN",
    confirmText: "EXPORTIEREN",
  );
  if (exportDate != null) {
    final exportFileName = 'Export von ${DateTimeUtil.formatWithString(exportDate, "dd.MM.y")} bis '
        '${DateTimeUtil.formatWithString(now, "dd.MM.y")}.csv';
    final bookings = await bookingService.fromTo(exportDate, now);

    final fields = ExportFields();
    final cfg = await config.getExportCsvConfig();
    if (cfg != null && cfg.isNotEmpty) {
      fields.selectedValuesString = cfg;
    }
    final csvData = exportService.exportUsingFields(fields, bookings);
    final f = await exportService.writeToFile(csvData, fileName: exportFileName);

    await Share.shareXFiles([XFile(f.path, mimeType: 'text/csv', name: exportFileName)],);
    f.delete();
  }
}
