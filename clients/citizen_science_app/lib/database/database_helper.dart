import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/dataset.dart';
import '../models/observation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();
  Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'survey.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
      onCreate: (d, _) async {
        await d.execute(
          '''
          CREATE TABLE datasets(
            id TEXT PRIMARY KEY, name TEXT NOT NULL, project_type TEXT NOT NULL,
            contributor_name TEXT NOT NULL, created_at TEXT NOT NULL,
            upload_status TEXT NOT NULL, last_upload_attempt TEXT, uploaded_at TEXT)''',
        );
        await d.execute('''
          CREATE TABLE observations(
            id TEXT PRIMARY KEY,
            dataset_id TEXT NOT NULL REFERENCES datasets(id),
            timestamp TEXT NOT NULL, latitude REAL, longitude REAL,
            gps_accuracy REAL, location_status TEXT NOT NULL,
            is_valid INTEGER NOT NULL DEFAULT 1)''');
        await d.execute('''
          CREATE TABLE upload_records(
            id TEXT PRIMARY KEY,
            dataset_id TEXT NOT NULL REFERENCES datasets(id),
            submission_id TEXT NOT NULL, attempted_at TEXT NOT NULL,
            status TEXT NOT NULL, response_message TEXT)''');
        await d.execute(
          'CREATE INDEX idx_obs_dataset ON observations(dataset_id)',
        );
      },
    );
  }

  Future<void> insertDataset(Dataset ds) async =>
      (await db).insert('datasets', ds.toMap());

  Future<List<Dataset>> getDatasets() async {
    final rows = await (await db).rawQuery('''
      SELECT d.*, (SELECT COUNT(*) FROM observations o WHERE o.dataset_id = d.id) AS obs_count
      FROM datasets d ORDER BY d.created_at DESC''');
    return rows.map(Dataset.fromMap).toList();
  }

  Future<void> insertObservation(Observation o) async =>
      (await db).insert('observations', o.toMap());

  Future<List<Observation>> getObservations(String datasetId) async {
    final rows = await (await db).query(
      'observations',
      where: 'dataset_id = ?',
      whereArgs: [datasetId],
      orderBy: 'timestamp DESC',
    );
    return rows.map(Observation.fromMap).toList();
  }

  Future<void> setValid(String obsId, bool valid) async => (await db).update(
    'observations',
    {'is_valid': valid ? 1 : 0},
    where: 'id = ?',
    whereArgs: [obsId],
  );

  Future<void> setUploadStatus(
    String datasetId,
    String status, {
    bool confirmed = false,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await (await db).update(
      'datasets',
      {
        'upload_status': status,
        'last_upload_attempt': now,
        if (confirmed) 'uploaded_at': now,
      },
      where: 'id = ?',
      whereArgs: [datasetId],
    );
  }

  Future<void> addUploadRecord(
    String id,
    String datasetId,
    String submissionId,
    String status,
    String? message,
  ) async => (await db).insert('upload_records', {
    'id': id,
    'dataset_id': datasetId,
    'submission_id': submissionId,
    'attempted_at': DateTime.now().toUtc().toIso8601String(),
    'status': status,
    'response_message': message,
  });
}
