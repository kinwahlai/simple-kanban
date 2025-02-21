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
        subtitle: 'github.com/org/repo/issues/123',
      ),
      KanbanItem(
        id: '2',
        title: 'Setup CI/CD Pipeline',
        subtitle: 'Link to Jenkins configuration',
      ),
    ];

    final inProgressItems = [
      KanbanItem(
        id: '3',
        title: 'User Authentication',
        subtitle: 'PR: github.com/org/repo/pull/456',
      ),
    ];

    final reviewItems = [
      KanbanItem(
        id: '4',
        title: 'API Integration',
        subtitle: 'Pending review: github.com/org/repo/pull/789',
      ),
    ];

    final doneItems = [
      KanbanItem(
        id: '5',
        title: 'Project Setup',
        subtitle: 'Completed on 2024-01-20',
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
        child: KanbanBoard(
          theme: customTheme,
          columns: [
            KanbanColumnConfig(
              title: 'Backlog',
              initialItems: backlogItems,
              canAddItems: true,
            ),
            KanbanColumnConfig(
              title: 'In Progress',
              initialItems: inProgressItems,
              limit: 2,
              canAddItems: true,
            ),
            KanbanColumnConfig(
              title: 'Review',
              initialItems: reviewItems,
              limit: 3,
            ),
            KanbanColumnConfig(
              title: 'Done',
              initialItems: doneItems,
              canAddItems: true,
            ),
          ],
        ),
      ),
    );
  }
}
