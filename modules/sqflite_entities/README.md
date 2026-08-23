# sqflite entities

A simple Flutter SQLite entity framework without code generation. Provides base classes for entities, DAOs, and database migrations.

## Features

-   **AbstractEntity**: Base class for entities with ID-based equality
-   **AbstractDao**: Generic CRUD operations for entities
-   **AttachedEntity**: ValueNotifier wrapper for reactive entity updates
-   **DbProvider**: Database initialization and migration management
-   **DbUpdate**: Versioned database migration system
-   **Converters**: Utilities for DateTime and Enum serialization

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
    sqflite_entities:
        path: modules/sqflite_entities
```

## Usage

### 1. Define an Entity

Extend `AbstractEntity` and implement serialization methods:

```dart
import 'package:sqflite_entities/entity/abstract_entity.dart';
import 'package:sqflite_entities/converter/sqlite_converter.dart';

class TimeBooking extends AbstractEntity {
  DateTime start;
  DateTime? end;

  TimeBooking(this.start, {this.end});

  Map<String, dynamic> asMap() {
    return {
      'id': id,
      'start_date': dateTimeToInt(start),
      'end_date': dateTimeToInt(end),
    };
  }

  void setMap(Map<String, dynamic> values) {
    id = values['id'] as int?;
    start = parseDateTime(values['start_date'])!;
    end = parseDateTime(values['end_date']);
  }
}
```

### 2. Create a DAO

Extend `AbstractDao` and implement `fromMap` and `toMap`:

```dart
import 'package:sqflite_entities/dao/abstract_dao.dart';

class TimeBookingDao extends AbstractDao<TimeBooking> {
  TimeBookingDao(Database db) : super(db, 'TIME_BOOKING');

  @override
  TimeBooking fromMap(Map<String, dynamic> values) {
    final result = TimeBooking(parseDateTime(values['start_date'])!);
    result.setMap(values);
    return result;
  }

  @override
  Map<String, dynamic> toMap(TimeBooking value) {
    return value.asMap();
  }

  // Add custom queries
  Future<List<TimeBooking>> loadByDay(String day) {
    return loadAll(
      where: "day = ?",
      whereArgs: [day],
      orderBy: "start_date DESC",
    );
  }
}
```

### 3. Define Database Migrations

Create versioned migration classes extending `DbUpdate`:

```dart
import 'package:sqflite_entities/service/db_update.dart';

class DbConfigV1 extends DbUpdate {
  static const String table = 'CONFIG';

  DbConfigV1() : super(1);  // Version 1

  @override
  Future<void> update(Database db) {
    return db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        id varchar(16) PRIMARY KEY,
        value text
      );
    ''');
  }
}

class DbBookingTableV2 extends DbUpdate {
  static const String table = 'TIME_BOOKING';

  DbBookingTableV2() : super(2);  // Version 2

  @override
  Future<void> update(Database db) {
    return db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        id integer PRIMARY KEY AUTOINCREMENT,
        day varchar(10),
        start_date int NOT NULL,
        end_date int
      );
    ''');
  }
}
```

### 4. Initialize the Database

Use `DbProvider` to manage database initialization:

```dart
import 'package:sqflite_entities/service/db_provider.dart';

final _dbUpdates = [
  DbConfigV1(),
  DbBookingTableV2(),
];

Future<DbProvider> initDb() async {
  final provider = DbProvider('my_app.db', _dbUpdates);
  return provider;
}

// In your app initialization
void main() async {
  final dbProvider = await initDb();
  final db = await dbProvider.init();

  final bookingDao = TimeBookingDao(db);

  // Use the DAO
  final booking = TimeBooking(DateTime.now());
  await bookingDao.save(booking);  // Insert

  final all = await bookingDao.loadAll();
  final byId = await bookingDao.getById(1);

  await bookingDao.delete(booking.id);
}
```

### 5. Using AttachedEntity for Reactive Updates

`AttachedEntity` wraps an entity in a `ValueNotifier` for Flutter widget rebuilds:

```dart
final attached = bookingDao.attach(booking);

// Use in a widget
ValueListenableBuilder<TimeBooking>(
  valueListenable: attached,
  builder: (context, booking, child) {
    return Text('Start: ${booking.start}');
  },
);

// Save changes - listeners are notified
await attached.save();

// Reload from database
await attached.reload();

// Delete
await attached.delete();
```

## Converters

### DateTime Conversion

```dart
import 'package:sqflite_entities/converter/sqlite_converter.dart';

// Store DateTime as milliseconds
int? millis = dateTimeToInt(DateTime.now());

// Parse back to DateTime
DateTime? date = parseDateTime(millis);
```

### Enum Conversion

```dart
enum Status { active, inactive }

// To string
String? str = enumToString(Status.active);  // "active"

// From string
Status? status = parseEnum("active", Status.values);

// With default
Status status = parseEnumWithDefault("unknown", Status.inactive, Status.values);
```

### Date Utilities

```dart
import 'package:sqflite_entities/converter/date_util.dart';

// Extensions
DateTime.now().toIsoDateString();  // "2024-01-15"
DateTime.now().addDays(7);
Duration(hours: 2).toDecimal();    // 2.0

// Utilities
DateTimeUtil.clearTime(dateTime);      // Remove time component
DateTimeUtil.midnight(dateTime);       // Set to 23:59:59
DateTimeUtil.precisionMinutes(now);    // Truncate to minutes
```

## API Reference

### AbstractDao Methods

| Method                 | Description                    |
| ---------------------- | ------------------------------ |
| `save(entity)`         | Insert or update based on ID   |
| `insert(entity)`       | Insert new entity              |
| `update(entity)`       | Update existing entity         |
| `getById(id)`          | Get entity by ID               |
| `loadAll(...)`         | Query with optional filters    |
| `delete(id)`           | Delete by ID                   |
| `deleteEntity(entity)` | Delete entity and clear its ID |
| `deleteAll()`          | Delete all records             |
| `countAll()`           | Count all records              |
| `attach(entity)`       | Wrap in AttachedEntity         |
| `getAttached(id)`      | Get as AttachedEntity          |

### AbstractMapDao

For simple key-value storage:

```dart
class ConfigDao extends AbstractMapDao {
  ConfigDao(Database db) : super(db, 'CONFIG');
}

final dao = ConfigDao(db);
await dao.setValue('theme', 'dark');
String? theme = await dao.getValue('theme');
String theme = await dao.getValueWithDefault('theme', 'light');
Map<String, String?> all = await dao.loadAll();
```

## Testing

Use `DbProvider.withDb` for in-memory test databases:

```dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('DAO test', () async {
    final testDb = databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );

    final provider = DbProvider.withDb(testDb, _dbUpdates);
    final db = await provider.init();

    final dao = TimeBookingDao(db);
    // ... test your DAO
  });
}
```

## License

Part of the [time_tracker](../../) project.
