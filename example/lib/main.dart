import 'package:flutter/material.dart';
import 'package:simple_kanban/simple_kanban.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Kanban Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: ExamplePage(onThemeToggle: _toggleTheme),
    );
  }
}

class ExamplePage extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const ExamplePage({
    super.key,
    required this.onThemeToggle,
  });

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  // Example of initial items
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // Theme that adapts to light/dark mode
    final customTheme = KanbanBoardTheme(
      // Background colors
      backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.grey.shade100,
      columnColor: isDark ? Color(0xFF2D2D2D) : Colors.white,
      cardColor: isDark ? Color(0xFF3D3D3D) : Colors.blue.shade50,
      cardBorderColor: isDark ? Color(0xFF505050) : Colors.blue.shade200,
      headerColor: isDark ? Color(0xFF0D47A1) : Colors.blue.shade500,
      footerColor: isDark ? Color(0xFF2D2D2D) : Colors.white,

      // Text colors
      headerTextColor: Colors.white,
      cardTitleColor: isDark ? Colors.white : Colors.black87,
      cardSubtitleColor: isDark ? Colors.grey.shade300 : Colors.black54,
      countTextColor: isDark ? Colors.grey.shade300 : Colors.black87,
    );

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF121212) : null,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Simple Kanban Example'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
            tooltip: '${isDark ? "Light" : "Dark"} mode',
          ),
        ],
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
