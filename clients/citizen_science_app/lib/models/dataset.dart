class Dataset {
  final String id, name, projectType, contributorName;
  final DateTime createdAt;
  final String uploadStatus; // not_uploaded, uploading, uploaded, failed, ambiguous
  final DateTime? lastUploadAttempt, uploadedAt;
  final int observationCount;

  Dataset({
    required this.id,
    required this.name,
    required this.projectType,
    required this.contributorName,
    required this.createdAt,
    this.uploadStatus = 'not_uploaded',
    this.lastUploadAttempt,
    this.uploadedAt,
    this.observationCount = 0,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'project_type': projectType,
        'contributor_name': contributorName,
        'created_at': createdAt.toUtc().toIso8601String(),
        'upload_status': uploadStatus,
        'last_upload_attempt': lastUploadAttempt?.toUtc().toIso8601String(),
        'uploaded_at': uploadedAt?.toUtc().toIso8601String(),
      };

  factory Dataset.fromMap(Map<String, Object?> m) => Dataset(
        id: m['id'] as String,
        name: m['name'] as String,
        projectType: m['project_type'] as String,
        contributorName: m['contributor_name'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
        uploadStatus: m['upload_status'] as String,
        lastUploadAttempt: m['last_upload_attempt'] == null
            ? null
            : DateTime.parse(m['last_upload_attempt'] as String),
        uploadedAt: m['uploaded_at'] == null
            ? null
            : DateTime.parse(m['uploaded_at'] as String),
        observationCount: (m['obs_count'] as int?) ?? 0,
      );
}