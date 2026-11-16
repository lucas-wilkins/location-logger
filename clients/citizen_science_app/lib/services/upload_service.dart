import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/dataset.dart';

enum UploadResult { success, rejected, notSent, ambiguous }

class UploadService {
  final _db = DatabaseHelper.instance;
  final _uuid = const Uuid();

  Future<UploadResult> upload(
    Dataset ds, {
    required String url,
    required String password,
  }) async {
    final submissionId = _uuid.v4();
    final obs = await _db.getObservations(ds.id);

    final payload = {
      'password': password,
      'user': ds.contributorName,
      'submission_id': submissionId,
      'dataset_id': ds.id,
      'dataset_name': ds.name,
      'project': ds.projectType,
      'observations': obs.map((o) => o.toUploadJson()).toList(),
    };

    await _db.setUploadStatus(ds.id, 'uploading');
    try {
      final res = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      Map<String, dynamic>? body;
      try {
        body = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}

      if (res.statusCode == 200 && body?['success'] == true) {
        await _db.setUploadStatus(ds.id, 'uploaded', confirmed: true);
        await _db.addUploadRecord(
          _uuid.v4(),
          ds.id,
          submissionId,
          'success',
          body?['message'] as String?,
        );
        return UploadResult.success;
      }
      // Server answered but did not confirm success
      await _db.setUploadStatus(ds.id, 'failed');
      await _db.addUploadRecord(
        _uuid.v4(),
        ds.id,
        submissionId,
        'failed',
        body?['message'] as String? ?? 'HTTP ${res.statusCode}',
      );
      return UploadResult.rejected;
    } on TimeoutException {
      // Request may have reached the server. Do not blind retry.
      await _db.setUploadStatus(ds.id, 'ambiguous');
      await _db.addUploadRecord(
        _uuid.v4(),
        ds.id,
        submissionId,
        'ambiguous',
        'Timeout',
      );
      return UploadResult.ambiguous;
    } catch (e) {
      // Connection failed before a response (e.g. offline)
      await _db.setUploadStatus(ds.id, 'failed');
      await _db.addUploadRecord(
        _uuid.v4(),
        ds.id,
        submissionId,
        'failed',
        e.toString(),
      );
      return UploadResult.notSent;
    }
  }
}
