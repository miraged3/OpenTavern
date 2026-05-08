import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppStorage {
  AppStorage._(this._database, this._values);
  AppStorage.memory([Map<String, Object?>? values])
    : _database = null,
      _values = Map<String, Object?>.from(values ?? const {});

  static const _directoryName = 'OpenTavern';
  static const _databaseName = 'opentavern.sqlite';
  static const _tableName = 'app_storage';

  final Database? _database;
  final Map<String, Object?> _values;
  Future<void> _pendingWrite = Future<void>.value();

  static Future<AppStorage> create() async {
    sqfliteFfiInit();
    final directory = await openTavernDirectory();
    final database = await databaseFactoryFfi.openDatabase(
      _joinPath(directory.path, _databaseName),
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) => _createSchema(db),
        onOpen: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
          await db.execute('PRAGMA journal_mode = WAL');
        },
      ),
    );
    final values = await _readValues(database);
    return AppStorage._(database, values);
  }

  static Future<Directory> openTavernDirectory() async {
    final directory = Directory(
      _joinPath(await _baseDirectoryPath(), _directoryName),
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  static Future<String> _baseDirectoryPath() async {
    if (Platform.isWindows) {
      return Platform.environment['APPDATA'] ??
          _joinPath(
            Platform.environment['USERPROFILE'] ?? '.',
            'AppData',
            'Roaming',
          );
    }
    if (Platform.isMacOS) {
      return _joinPath(
        Platform.environment['HOME'] ?? '.',
        'Library',
        'Application Support',
      );
    }
    if (Platform.isLinux) {
      return Platform.environment['XDG_DATA_HOME'] ??
          _joinPath(Platform.environment['HOME'] ?? '.', '.local', 'share');
    }
    return (await getApplicationSupportDirectory()).path;
  }

  static Future<void> _createSchema(Database db) {
    return db.execute('''
CREATE TABLE $_tableName (
  key TEXT PRIMARY KEY NOT NULL,
  value TEXT NOT NULL
)
''');
  }

  static Future<Map<String, Object?>> _readValues(Database database) async {
    final rows = await database.query(_tableName);
    final values = <String, Object?>{};
    for (final row in rows) {
      final key = row['key'];
      final value = row['value'];
      if (key is String && value is String) {
        try {
          values[key] = jsonDecode(value);
        } catch (_) {
          values[key] = null;
        }
      }
    }
    return values;
  }

  List<Map<String, dynamic>> readJsonList(String key) {
    final rawValue = _values[key];
    if (rawValue is! List) {
      return const <Map<String, dynamic>>[];
    }

    return [
      for (final item in rawValue)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }

  Future<void> writeJsonList(String key, List<Map<String, dynamic>> value) {
    _values[key] = value;
    return _persist(key, value);
  }

  String? readString(String key) {
    final rawValue = _values[key];
    if (rawValue is! String) {
      return null;
    }
    if (rawValue.isEmpty) {
      return null;
    }
    return rawValue;
  }

  Future<void> writeString(String key, String value) async {
    _values[key] = value;
    await _persist(key, value);
  }

  bool? readBool(String key) {
    final rawValue = _values[key];
    return rawValue is bool ? rawValue : null;
  }

  Future<void> writeBool(String key, bool value) async {
    _values[key] = value;
    await _persist(key, value);
  }

  Future<void> _persist(String key, Object? value) {
    final database = _database;
    if (database == null) {
      return Future<void>.value();
    }
    _pendingWrite = _pendingWrite.catchError((_) {}).then((_) async {
      await database.insert(_tableName, {
        'key': key,
        'value': jsonEncode(value),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
    return _pendingWrite;
  }

  static String _joinPath(String first, String second, [String? third]) {
    final separator = Platform.pathSeparator;
    final parts = [first, second, ?third];
    return parts
        .where((part) => part.isNotEmpty)
        .map((part) => part.replaceAll(RegExp(r'[\/\\]+$'), ''))
        .join(separator);
  }
}
