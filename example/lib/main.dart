import 'package:flutter/material.dart';
import 'package:simple_kanban/simple_kanban.dart';

void main() {
  // Setup service locator for advanced configuration
  final storageLogger = KanbanStorageLogger();
  KanbanServiceLocator.instance.register<KanbanStorageLogger>(storageLogger);

  runApp(const MyApp());
}

/// Simple logger plugin for Kanban board
class KanbanStorageLogger implements KanbanPlugin {
  @override
  void onBoardInitialized(KanbanController controller) {
    print(
        'Kanban board initialized with ${controller.storage.columns.length} columns');
  }

  @override
  void onItemAdded(KanbanItem item, String columnTitle) {
    print('Item added: ${item.title} to $columnTitle');
  }

  @override
  void onItemMoved(KanbanItem item, String fromColumn, String toColumn) {
    print('Item moved: ${item.title} from $fromColumn to $toColumn');
  }

  @override
  void onBoardDisposed() {
    print('Kanban board disposed');
  }
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
  // Create a controller with initial data
  late KanbanController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Try to load previous board state first
    _initializeBoard();
  }

  Future<void> _initializeBoard() async {
    try {
      // Attempt to load previous board state
      final controller = await KanbanController.loadFromPrefs(
        'kanban_board',
        onBoardChanged: () => setState(() {}),
      );

      setState(() {
        _controller = controller;
        _isLoading = false;
      });

      // Register the plugin with the controller
      final logger = KanbanServiceLocator.instance.get<KanbanStorageLogger>();
      logger.onBoardInitialized(_controller);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Previous board loaded')),
      );
    } catch (e) {
      // No previous state found, create a new board with example items
      _initializeWithExampleData();
    }
  }

  void _initializeWithExampleData() {
    // Initialize with example items
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

    // Setup columns configuration
    final columns = [
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
    ];

    // Create controller with callbacks
    _controller = KanbanController(
      columns: columns,
      onBoardChanged: () {
        // Called when board state changes
        setState(() {});
      },
    );

    // Register the plugin with the controller
    final logger = KanbanServiceLocator.instance.get<KanbanStorageLogger>();
    logger.onBoardInitialized(_controller);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    // Clean up plugin
    final logger = KanbanServiceLocator.instance.get<KanbanStorageLogger>();
    logger.onBoardDisposed();
    super.dispose();
  }

  // Example of persistence
  Future<void> _saveBoard() async {
    try {
      await _controller.saveToPrefs('kanban_board');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Board saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving board: $e')),
      );
    }
  }

  Future<void> _loadBoard() async {
    try {
      final controller = await KanbanController.loadFromPrefs(
        'kanban_board',
        onBoardChanged: () => setState(() {}),
      );
      setState(() {
        // Update the controller
        _controller = controller;
      });

      // Register the plugin with the loaded controller
      final logger = KanbanServiceLocator.instance.get<KanbanStorageLogger>();
      logger.onBoardInitialized(_controller);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Board loaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading board: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Simple Kanban Example'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme that adapts to light/dark mode
    final customTheme = KanbanBoardTheme(
      // Background colors
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
      columnColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
      cardColor: isDark ? const Color(0xFF3D3D3D) : Colors.blue.shade50,
      cardBorderColor: isDark ? const Color(0xFF505050) : Colors.blue.shade200,
      headerColor: isDark ? const Color(0xFF0D47A1) : Colors.blue.shade500,

      // Text colors
      headerTextColor: Colors.white,
      cardTitleColor: isDark ? Colors.white : Colors.black87,
      cardSubtitleColor: isDark ? Colors.grey.shade300 : Colors.black54,
      countTextColor: isDark ? Colors.grey.shade300 : Colors.black87,
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : null,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Simple Kanban Example'),
        actions: [
          // Reset button to clear state and load example data
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () {
              _initializeWithExampleData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Loaded example data')),
              );
            },
            tooltip: 'Reset to example data',
          ),
          // Save & Load buttons for persistence demo
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveBoard,
            tooltip: 'Save board state',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBoard,
            tooltip: 'Load board state',
          ),
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
          controller: _controller,
          theme: customTheme,
          onItemMoved: (item, fromColumn, toColumn) {
            // Hook for item moved event
            final logger =
                KanbanServiceLocator.instance.get<KanbanStorageLogger>();
            logger.onItemMoved(item, fromColumn, toColumn);
          },
          onItemAdded: (item, column) {
            // Hook for item added event
            final logger =
                KanbanServiceLocator.instance.get<KanbanStorageLogger>();
            logger.onItemAdded(item, column);
          },
        ),
      ),
    );
  }
}
