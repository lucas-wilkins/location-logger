import 'package:flutter/material.dart';

class UploadStatusBadge extends StatelessWidget {
  final String status;
  const UploadStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late String label;
    late Color color;
    switch (status) {
      case 'uploaded':
        label = 'Uploaded';
        color = Colors.greenAccent;
        break;
      case 'uploading':
        label = 'Uploading';
        color = Colors.lightBlueAccent;
        break;
      case 'failed':
        label = 'Failed';
        color = Colors.redAccent;
        break;
      case 'ambiguous':
        label = 'Check needed';
        color = Colors.deepOrangeAccent;
        break;
      default:
        label = 'Not uploaded';
        color = Colors.amberAccent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 13)),
    );
  }
}