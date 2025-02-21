import 'package:flutter/material.dart';
import 'package:simple_kanban/simple_kanban.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Kanban Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example of initial items
    final initialItems = {
      'To Do': [
        KanbanItem(
          id: '1',
          title: 'Design UI',
          subtitle: 'Create wireframes and mockups',
        ),
        KanbanItem(
          id: '2',
          title: 'Implement Backend',
          subtitle: 'Set up API endpoints',
        ),
      ],
      'In Progress': [
        KanbanItem(
          id: '3',
          title: 'Write Tests',
          subtitle: 'Unit and integration tests',
        ),
      ],
      'Done': [
        KanbanItem(
          id: '4',
          title: 'Project Setup',
          subtitle: 'Initialize repository and dependencies',
        ),
      ],
    };

    // Example of custom column limits
    final columnLimits = {
      'To Do': 6,
      'In Progress': 4,
      'Done': 8,
    };

    // Example of custom theme
    final customTheme = KanbanBoardTheme(
      backgroundColor: Colors.grey.shade100,
      columnColor: Colors.white,
      cardColor: Colors.blue.shade50,
      cardBorderColor: Colors.blue.shade200,
      headerColor: Colors.blue.shade500,
      footerColor: Colors.white,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Simple Kanban Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: KanbanBoard(
          initialItems: initialItems,
          columnLimits: columnLimits,
          theme: customTheme,
          columnTitles: const ['To Do', 'In Progress', 'Done'],
        ),
      ),
    );
  }
}
