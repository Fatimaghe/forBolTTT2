import 'package:flutter/material.dart';

class TimesheetsScreen extends StatelessWidget {
  const TimesheetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timesheets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add timesheet screen
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Timesheets Screen - Coming Soon'),
      ),
    );
  }
}