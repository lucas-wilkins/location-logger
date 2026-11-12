class Observation {
  final String id, datasetId, locationStatus; // available / unavailable
  final DateTime timestamp;
  final double? latitude, longitude, gpsAccuracy;
  final bool isValid;

  Observation({
    required this.id,
    required this.datasetId,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.gpsAccuracy,
    required this.locationStatus,
    this.isValid = true,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'dataset_id': datasetId,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'gps_accuracy': gpsAccuracy,
        'location_status': locationStatus,
        'is_valid': isValid ? 1 : 0,
      };

  factory Observation.fromMap(Map<String, Object?> m) => Observation(
        id: m['id'] as String,
        datasetId: m['dataset_id'] as String,
        timestamp: DateTime.parse(m['timestamp'] as String),
        latitude: m['latitude'] as double?,
        longitude: m['longitude'] as double?,
        gpsAccuracy: m['gps_accuracy'] as double?,
        locationStatus: m['location_status'] as String,
        isValid: (m['is_valid'] as int) == 1,
      );

  Map<String, Object?> toUploadJson() => {
        'observation_id': id,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'gps_accuracy': gpsAccuracy,
        'location_status': locationStatus,
        'valid': isValid,
      };
}