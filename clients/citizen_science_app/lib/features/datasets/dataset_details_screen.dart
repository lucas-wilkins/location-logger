import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:citizen_science_app/database/database_helper.dart';
import 'package:citizen_science_app/models/dataset.dart';
import 'package:citizen_science_app/models/observation.dart';

class DatasetDetailsScreen extends StatefulWidget {
  final Dataset dataset;
  const DatasetDetailsScreen({super.key, required this.dataset});

  @override
  State<DatasetDetailsScreen> createState() => _DatasetDetailsScreenState();
}

class _DatasetDetailsScreenState extends State<DatasetDetailsScreen> {
  final _db = DatabaseHelper.instance;
  List<Observation> _obs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _db.getObservations(widget.dataset.id);
    if (!mounted) return;
    setState(() => _obs = list);
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _time(DateTime t) {
    final l = t.toLocal();
    return '${_two(l.hour)}:${_two(l.minute)}:${_two(l.second)}';
  }

Future<void> _record() async {
  try {
    await _db.insertObservation(Observation(
      id: const Uuid().v4(),
      datasetId: widget.dataset.id,
      timestamp: DateTime.now(),
      locationStatus: 'unavailable',
    ));
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sighting saved'),
        duration: Duration(seconds: 1),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not save: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final validCount = _obs.where((o) => o.isValid).length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.dataset.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Text('$validCount',
                    style: const TextStyle(
                        fontSize: 56, fontWeight: FontWeight.bold)),
                Text('valid of ${_obs.length} recorded'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: FilledButton(
                    onPressed: _record,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('RECORD SIGHTING',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _obs.length,
              itemBuilder: (context, i) {
                final o = _obs[i];
                return ListTile(
                  title: Text(
                    _time(o.timestamp),
                    style: TextStyle(
                      fontSize: 18,
                      decoration:
                          o.isValid ? null : TextDecoration.lineThrough,
                      color: o.isValid ? null : Colors.grey,
                    ),
                  ),
                  subtitle: Text(
                    '${o.locationStatus == 'available' ? 'Location available' : 'Location unavailable'}'
                    ' | ${o.isValid ? 'Valid' : 'Invalid'}',
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      await _db.setValid(o.id, !o.isValid);
                      await _load();
                    },
                    child: Text(o.isValid ? 'Mark invalid' : 'Undo'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}