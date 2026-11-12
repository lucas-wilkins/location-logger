import 'package:uuid/uuid.dart';
import 'package:citizen_science_app/models/dataset.dart';
import 'package:citizen_science_app/models/observation.dart';

// Temporary in-memory data. Replaced by SQLite in a later stage.
class MemoryStore {
  static final MemoryStore instance = MemoryStore._();
  MemoryStore._() {
    final id = const Uuid().v4();
    datasets.add(Dataset(
      id: id,
      name: 'Glowworm Survey - Sample',
      projectType: 'glowworm_survey',
      contributorName: 'Volunteer 01',
      createdAt: DateTime.now(),
    ));
    _obs[id] = [];
  }

  final List<Dataset> datasets = [];
  final Map<String, List<Observation>> _obs = {};

  List<Observation> observationsFor(String datasetId) =>
      _obs[datasetId] ?? [];

  void addDataset(Dataset d) {
    datasets.insert(0, d);
    _obs[d.id] = [];
  }

  void addObservation(Observation o) =>
      _obs[o.datasetId]!.insert(0, o);

  void setValid(Observation o, bool valid) {
    final list = _obs[o.datasetId]!;
    final i = list.indexWhere((x) => x.id == o.id);
    list[i] = Observation(
      id: o.id,
      datasetId: o.datasetId,
      timestamp: o.timestamp,
      latitude: o.latitude,
      longitude: o.longitude,
      gpsAccuracy: o.gpsAccuracy,
      locationStatus: o.locationStatus,
      isValid: valid,
    );
  }
}