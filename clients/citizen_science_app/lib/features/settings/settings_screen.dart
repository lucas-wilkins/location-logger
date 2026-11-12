import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _name = TextEditingController(text: 'Volunteer 01');
  final _server = TextEditingController();
  final _password = TextEditingController();
  bool _fieldMode = false;

  @override
  void dispose() {
    _name.dispose();
    _server.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
                labelText: 'Contributor name',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _server,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
                labelText: 'Server address',
                hintText: 'Provided by the project lead',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: 'Password', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Field mode (screen lock)'),
            subtitle: const Text('Behaviour to be agreed with the project lead'),
            value: _fieldMode,
            onChanged: (v) => setState(() => _fieldMode = v),
          ),
        ],
      ),
    );
  }
}