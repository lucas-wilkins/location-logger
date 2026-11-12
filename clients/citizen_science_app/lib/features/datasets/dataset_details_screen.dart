import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:citizen_science_app/models/dataset.dart';
import 'package:citizen_science_app/models/observation.dart';
import 'package:citizen_science_app/services/memory_store.dart';

class DatasetDetailsScreen extends StatefulWidget {
  final Dataset dataset;
  const DatasetDetailsScreen({super.key, required this.dataset});

  @override
  State<DatasetDetailsScreen> createState() => _DatasetDetailsScreenState();
}

class _DatasetDetailsScreenState extends State<DatasetDetailsScreen> {
  final store = MemoryStore.instance;

  String _two(int n) => n.toString().padLeft(2, '0');

  String _time(DateTime t) {
    final l = t.toLocal();
    return '${_two(l.hour)}:${_two(l.minute)}:${_two(l.second)}';
  }

  void _record() {
    // GPS comes in a later stage. For now location is marked unavailable.
    store.addObservation(Observation(
      id: const Uuid().v4(),
      datasetId: widget.dataset.id,
      timestamp: DateTime.now(),
      locationStatus: 'unavailable',
    ));
    setState(() {});
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sighting saved'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final obs = store.observationsFor(widget.dataset.id);
    final validCount = obs.where((o) => o.isValid).length;

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
                Text('valid of ${obs.length} recorded'),
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
              itemCount: obs.length,
              itemBuilder: (context, i) {
                final o = obs[i];
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
                    onPressed: () {
                      store.setValid(o, !o.isValid);
                      setState(() {});
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