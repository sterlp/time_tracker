import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_entities/service/db_provider.dart';
import 'package:time_tracker/booking/bean/booking_service.dart';
import 'package:time_tracker/booking/bean/today_bean.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/config/dao/config_dao.dart';
import 'package:time_tracker/db/time_traker_db.dart';
import 'package:time_tracker/export/service/export_service.dart';
import 'package:time_tracker/home/page/home_page.dart';
import 'package:time_tracker/home/widget/loading_widget.dart';
import 'package:time_tracker/log/logger.dart';

Future<AppContainer> initContext({Future<DbProvider>? dbProvider}) async {
  final result = AppContainer();
  final db = await (await (dbProvider ??= initDb())).init();

  // CONFIG
  final configDao = ConfigDao(db);
  final config = await configDao.loadConfig();
  result.add(config);

  // TodayBean
  result.add<TimeBookingDao>(TimeBookingDao(db))
        .addFactory<BookingService>((c) => BookingService(c.get<TimeBookingDao>()))
        .addFactory<TodayBean>((c) => TodayBean(c.get<BookingService>()).init())
        .addFactory<ExportService>((c) => ExportService(c.get<BookingService>()))
  ;

  return result;
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Logger _log = LoggerFactory.get<MyApp>();
  final Future<AppContainer> _container;

  MyApp({Future<AppContainer>? c}) : _container = c ?? initContext();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zeiterfassung',
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      supportedLocales: const [
        Locale('de', '')
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      home: FutureBuilder<AppContainer>(
        future: _container,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            _log.error('Failed to load App', snapshot.error);
          }
          if (snapshot.hasData) {
            return HomePage(snapshot.data!);
          } else {
            return const LoadingWidget();
          }
        },
      ),
    );
  }
}
