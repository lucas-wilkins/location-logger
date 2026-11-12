import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:citizen_science_app/models/dataset.dart';
import 'package:citizen_science_app/services/memory_store.dart';
import 'package:citizen_science_app/widgets/upload_status_badge.dart';
import 'package:citizen_science_app/features/datasets/dataset_details_screen.dart';
import 'package:citizen_science_app/features/settings/settings_screen.dart';

class DatasetListScreen extends StatefulWidget {
  const DatasetListScreen({super.key});

  @override
  State<DatasetListScreen> createState() => _DatasetListScreenState();
}

class _DatasetListScreenState extends State<DatasetListScreen> {
  final store = MemoryStore.instance;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  void _createDataset() {
    final now = DateTime.now();
    store.addDataset(Dataset(
      id: const Uuid().v4(),
      name: 'Glowworm Survey - ${now.day} ${_months[now.month - 1]}',
      projectType: 'glowworm_survey',
      contributorName: 'Volunteer 01',
      createdAt: now,
    ));
    setState(() {});
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
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: store.datasets.length,
        itemBuilder: (context, i) {
          final d = store.datasets[i];
          final count = store.observationsFor(d.id).length;
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
                    'Contributor: ${d.contributorName}\nObservations: $count'),
              ),
              trailing: UploadStatusBadge(status: d.uploadStatus),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DatasetDetailsScreen(dataset: d)),
                );
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }
}