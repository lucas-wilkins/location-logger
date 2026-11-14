import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:citizen_science_app/database/database_helper.dart';
import 'package:citizen_science_app/models/dataset.dart';
import 'package:citizen_science_app/widgets/upload_status_badge.dart';
import 'package:citizen_science_app/features/datasets/dataset_details_screen.dart';
import 'package:citizen_science_app/features/settings/settings_screen.dart';

class DatasetListScreen extends StatefulWidget {
  const DatasetListScreen({super.key});

  @override
  State<DatasetListScreen> createState() => _DatasetListScreenState();
}

class _DatasetListScreenState extends State<DatasetListScreen> {
  final _db = DatabaseHelper.instance;
  List<Dataset> _datasets = [];
  bool _loading = true;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _db.getDatasets();
    if (!mounted) return;
    setState(() {
      _datasets = list;
      _loading = false;
    });
  }

  Future<void> _createDataset() async {
    final now = DateTime.now();
    await _db.insertDataset(Dataset(
      id: const Uuid().v4(),
      name: 'Glowworm Survey - ${now.day} ${_months[now.month - 1]}',
      projectType: 'glowworm_survey',
      contributorName: 'Volunteer 01',
      createdAt: now,
    ));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Survey'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createDataset,
        icon: const Icon(Icons.add),
        label: const Text('New dataset'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _datasets.isEmpty
              ? const Center(child: Text('No datasets yet. Tap New dataset.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _datasets.length,
                  itemBuilder: (context, i) {
                    final d = _datasets[i];
                    return Card(
                      color: const Color(0xFF14181C),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(d.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                              'Contributor: ${d.contributorName}\nObservations: ${d.observationCount}'),
                        ),
                        trailing: UploadStatusBadge(status: d.uploadStatus),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    DatasetDetailsScreen(dataset: d)),
                          );
                          _load();
                        },
                      ),
                    );
                  },
                ),
    );
  }
}