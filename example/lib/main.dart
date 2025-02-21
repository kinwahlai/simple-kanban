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
    // Example of initial items with mixed column limits
    final initialItems = {
      'To Do': [
        KanbanItem(
          id: '1',
          title: 'Design User Interface',
          subtitle: 'Create wireframes and mockups',
        ),
        KanbanItem(
          id: '2',
          title: 'Setup CI/CD Pipeline',
          subtitle: 'Configure automated builds and tests',
        ),
        KanbanItem(
          id: '3',
          title: 'User Authentication',
          subtitle: 'Implement login and registration',
        ),
        KanbanItem(
          id: '4',
          title: 'Database Schema',
          subtitle: 'Design initial data structure',
        ),
      ],
      'In Progress': [
        KanbanItem(
          id: '5',
          title: 'API Integration',
          subtitle: 'Connect to backend services',
        ),
        KanbanItem(
          id: '6',
          title: 'Unit Tests',
          subtitle: 'Write test cases for core features',
        ),
      ],
      'Done': [
        KanbanItem(
          id: '7',
          title: 'Project Setup',
          subtitle: 'Initialize repository and dependencies',
        ),
        KanbanItem(
          id: '8',
          title: 'Requirements Doc',
          subtitle: 'Document project specifications',
        ),
        KanbanItem(
          id: '9',
          title: 'Tech Stack Decision',
          subtitle: 'Choose frameworks and tools',
        ),
      ],
    };

    // Example of mixed column limits
    final columnLimits = {
      // No limit for To Do (backlog)
      'In Progress': 3, // Limit work in progress to 3 items
      // No limit for Done
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
          columnsWithFooter: const {'To Do'},
        ),
      ),
    );
  }
}
