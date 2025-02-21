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
    final backlogItems = [
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
    ];

    final inProgressItems = [
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
    ];

    final doneItems = [
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
    ];

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
        // Using the new standard factory constructor
        child: KanbanBoard.standard(
          theme: customTheme,
          backlogItems: backlogItems,
          inProgressItems: inProgressItems,
          doneItems: doneItems,
          backlogLimit: 10, // Limit backlog to 10 items
          workInProgressLimit: 3, // Limit WIP to 3 items
        ),
      ),
    );
  }
}
