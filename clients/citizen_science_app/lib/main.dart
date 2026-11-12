import 'package:flutter/material.dart';
import 'package:citizen_science_app/app/theme.dart';
import 'package:citizen_science_app/features/datasets/dataset_list_screen.dart';

void main() => runApp(const SurveyApp());

class SurveyApp extends StatelessWidget {
  const SurveyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Survey',
      theme: buildNightTheme(),
      debugShowCheckedModeBanner: false,
      home: const DatasetListScreen(),
    );
  }
}