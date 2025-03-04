import 'package:flutter/material.dart';
import '../models/kanban_item.dart';
import '../models/kanban_column.dart';
import '../models/kanban_column_config.dart';
import 'kanban_column.dart';
import '../models/kanban_storage.dart';
import 'add_item_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

/// Defines how the Kanban board should be laid out
enum KanbanLayoutMode {
  /// Horizontal scrolling layout for desktop/tablet
  horizontal,

  /// Vertical stacked layout for mobile
  vertical
}

class KanbanBoardTheme {
  final Color backgroundColor;
  final Color columnColor;
  final Color cardColor;
  final Color cardBorderColor;
  final Color headerColor;
  final Color headerTextColor;
  final Color cardTitleColor;
  final Color cardSubtitleColor;
  final Color countTextColor;

  const KanbanBoardTheme({
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.columnColor = const Color(0xFFF5F5F5),
    this.cardColor = Colors.white,
    this.cardBorderColor = const Color(0xFFE0E0E0),
    this.headerColor = Colors.white,
    this.headerTextColor = Colors.black87,
    this.cardTitleColor = Colors.black87,
    this.cardSubtitleColor = Colors.black54,
    this.countTextColor = Colors.black87,
  });
}

class KanbanController {
  final KanbanStorage storage;
  final VoidCallback? onBoardChanged;

  // Add listener support for state management
  final List<VoidCallback> _listeners = [];

  // Add plugin management
  final List<KanbanPlugin> _plugins = [];

  KanbanController({
    KanbanStorage? storage,
    List<KanbanColumnConfig>? columns,
    this.onBoardChanged,
  }) : storage = storage ?? _initializeStorage(columns ?? []);

  static KanbanStorage _initializeStorage(List<KanbanColumnConfig> columns) {
    final items = <String, KanbanItem>{};

    // Initialize items from configurations
    for (var config in columns) {
      for (var item in config.initialItems) {
        items[item.id] = item;
      }
    }

    // Initialize columns from configurations
    final storageColumns = columns.map((config) {
      return KanbanColumn(
        title: config.title,
        itemIds: config.initialItems.map((item) => item.id).toList(),
        limit: config.limit,
      );
    }).toList();

    return KanbanStorage(
      initialItems: items,
      initialColumns: storageColumns,
    );
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
    onBoardChanged?.call();
  }

  void _handleError(String operation, dynamic error) {
    print('Kanban operation "$operation" failed: $error');
    // Could forward to an error reporting service
  }

  bool addItem(String columnTitle, String title, String subtitle) {
    try {
      final columnIndex =
          storage.columns.indexWhere((col) => col.title == columnTitle);
      if (columnIndex == -1) return false;

      final column = storage.columns[columnIndex];
      if (!column.canAddItem()) return false;

      // Add the item
      storage.addItem(columnTitle, title, subtitle);

      // Get the newly added item - it will be the last one in the column
      final column2 = storage.columns[columnIndex];
      if (column2.itemIds.isEmpty) return false;
      final lastItemId = column2.itemIds.last;
      final newItem = storage.items[lastItemId];

      if (newItem != null) {
        // Notify plugins about the added item
        _notifyPluginsItemAdded(newItem, columnTitle);
      }

      // Check column limit
      _checkAndNotifyColumnLimit(columnTitle);

      _notifyListeners();
      return true;
    } catch (e) {
      _handleError('addItem', e);
      return false;
    }
  }

  void moveToColumn(String itemId, String direction) {
    // Store information before the move
    String? fromColumnTitle;
    for (final column in storage.columns) {
      if (column.itemIds.contains(itemId)) {
        fromColumnTitle = column.title;
        break;
      }
    }

    final item = storage.items[itemId];

    // Perform the operation
    storage.moveToColumn(itemId, direction);

    // Find the new column for the notification
    String? toColumnTitle;
    for (final column in storage.columns) {
      if (column.itemIds.contains(itemId)) {
        toColumnTitle = column.title;
        break;
      }
    }

    if (item != null && fromColumnTitle != null && toColumnTitle != null) {
      _notifyPluginsItemMoved(item, fromColumnTitle, toColumnTitle);
      _checkAndNotifyColumnLimit(toColumnTitle);
    }

    _notifyListeners();
  }

  void reorderItem(String itemId, int newIndex) {
    try {
      // Find original position for notification
      String? columnTitle;
      int? oldIndex;

      for (final column in storage.columns) {
        oldIndex = column.itemIds.indexOf(itemId);
        if (oldIndex != -1) {
          columnTitle = column.title;
          break;
        }
      }

      if (columnTitle != null && oldIndex != null) {
        final item = storage.items[itemId];

        // Perform the operation
        storage.reorderItem(itemId, newIndex);

        // Notify plugins
        if (item != null) {
          _notifyPluginsItemReordered(item, oldIndex, newIndex, columnTitle);
        }

        _notifyListeners();
      }
    } catch (e) {
      _handleError('reorderItem', e);
    }
  }

  List<KanbanItem> getItemsForColumn(KanbanColumn column) {
    return storage.getItemsForColumn(column);
  }

  // Add serialization methods
  Map<String, dynamic> toJson() {
    return {
      'items': _mapItemsToJson(),
      'columns': _mapColumnsToJson(),
    };
  }

  Map<String, dynamic> _mapItemsToJson() {
    return storage.items.map((id, item) => MapEntry(id, {
          'id': item.id,
          'title': item.title,
          'subtitle': item.subtitle,
        }));
  }

  List<Map<String, dynamic>> _mapColumnsToJson() {
    return storage.columns
        .map((column) => {
              'title': column.title,
              'itemIds': column.itemIds,
              'limit': column.limit,
            })
        .toList();
  }

  static KanbanController fromJson(Map<String, dynamic> json,
      {VoidCallback? onBoardChanged}) {
    // Parse items
    final itemsJson = json['items'] as Map<String, dynamic>;
    final items = <String, KanbanItem>{};

    itemsJson.forEach((id, itemData) {
      items[id] = KanbanItem(
        id: itemData['id'],
        title: itemData['title'],
        subtitle: itemData['subtitle'],
      );
    });

    // Parse columns
    final columnsJson = json['columns'] as List;
    final columns = columnsJson.map((columnData) {
      return KanbanColumn(
        title: columnData['title'],
        itemIds: List<String>.from(columnData['itemIds']),
        limit: columnData['limit'],
      );
    }).toList();

    // Create storage with parsed data
    final storage = KanbanStorage(
      initialItems: items,
      initialColumns: columns,
    );

    return KanbanController(
      storage: storage,
      onBoardChanged: onBoardChanged,
    );
  }

  // Add persistence helpers
  Future<void> saveToPrefs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(toJson());
      await prefs.setString(key, jsonData);

      // Notify plugins
      for (final plugin in _plugins) {
        plugin.onBoardPersisted("preferences:$key");
      }
    } catch (e) {
      _handleError('saveToPrefs', e);
      rethrow;
    }
  }

  static Future<KanbanController> loadFromPrefs(
    String key, {
    VoidCallback? onBoardChanged,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(key);
      if (jsonData == null) {
        throw Exception('No saved Kanban board found with key: $key');
      }

      final json = jsonDecode(jsonData);
      final controller = fromJson(json, onBoardChanged: onBoardChanged);

      // Notify plugins
      for (final plugin in controller._plugins) {
        plugin.onBoardLoaded("preferences:$key");
      }

      return controller;
    } catch (e) {
      print('Error loading Kanban board: $e');
      rethrow;
    }
  }

  // File-based persistence
  Future<void> saveToFile(String path) async {
    try {
      final file = File(path);
      final jsonData = jsonEncode(toJson());
      await file.writeAsString(jsonData);

      // Notify plugins
      for (final plugin in _plugins) {
        plugin.onBoardPersisted("file:$path");
      }
    } catch (e) {
      _handleError('saveToFile', e);
      rethrow;
    }
  }

  static Future<KanbanController> loadFromFile(
    String path, {
    VoidCallback? onBoardChanged,
  }) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('File not found: $path');
      }

      final jsonData = await file.readAsString();
      final json = jsonDecode(jsonData);
      final controller = fromJson(json, onBoardChanged: onBoardChanged);

      // Notify plugins
      for (final plugin in controller._plugins) {
        plugin.onBoardLoaded("file:$path");
      }

      return controller;
    } catch (e) {
      print('Error loading Kanban board: $e');
      rethrow;
    }
  }

  void registerPlugin(KanbanPlugin plugin) {
    _plugins.add(plugin);
    plugin.onBoardInitialized(this);
  }

  void unregisterPlugin(KanbanPlugin plugin) {
    _plugins.remove(plugin);
    plugin.onBoardDisposed();
  }

  void _notifyPluginsItemMoved(
      KanbanItem item, String fromColumn, String toColumn) {
    for (final plugin in _plugins) {
      plugin.onItemMoved(item, fromColumn, toColumn);
    }
  }

  void _notifyPluginsItemAdded(KanbanItem item, String columnTitle) {
    for (final plugin in _plugins) {
      plugin.onItemAdded(item, columnTitle);
    }
  }

  void _notifyPluginsItemReordered(
      KanbanItem item, int oldIndex, int newIndex, String columnTitle) {
    for (final plugin in _plugins) {
      plugin.onItemReordered(item, oldIndex, newIndex, columnTitle);
    }
  }

  void _checkAndNotifyColumnLimit(String columnTitle) {
    final columnIndex =
        storage.columns.indexWhere((col) => col.title == columnTitle);
    if (columnIndex == -1) return;

    final column = storage.columns[columnIndex];
    if (column.limit != null && column.itemIds.length >= column.limit!) {
      _notifyPluginsColumnLimitReached(columnTitle, column.limit!);
    }
  }

  void _notifyPluginsColumnLimitReached(String columnTitle, int limit) {
    for (final plugin in _plugins) {
      plugin.onColumnLimitReached(columnTitle, limit);
    }
  }
}

class KanbanColumnProvider {
  final List<KanbanColumnConfig> configs;
  final KanbanStorage storage;

  KanbanColumnProvider({
    required this.configs,
    required this.storage,
  });

  factory KanbanColumnProvider.fromStorage(KanbanStorage storage) {
    return KanbanColumnProvider(
      configs: KanbanBoard.columnsFromStorage(storage),
      storage: storage,
    );
  }

  KanbanColumnConfig getConfig(int index) {
    if (index >= 0 && index < configs.length) {
      return configs[index];
    }

    // Fallback to generating a config from storage if available
    if (index >= 0 && index < storage.columns.length) {
      final column = storage.columns[index];
      final items = storage.getItemsForColumn(column);

      return KanbanColumnConfig(
        title: column.title,
        initialItems: items,
        limit: column.limit,
        canAddItems: true,
      );
    }

    throw Exception('Column index out of bounds: $index');
  }

  bool canAddItemsToColumn(int index) {
    try {
      final config = getConfig(index);
      return config.canAddItems;
    } catch (e) {
      return false;
    }
  }
}

class KanbanBoard extends StatefulWidget {
  /// List of column configurations that define the board layout
  final List<KanbanColumnConfig>? columns;

  /// Optional direct storage instance for advanced usage
  final KanbanStorage? storage;

  /// Optional controller for managing the board state
  final KanbanController? controller;

  /// Optional theme for customizing the board's appearance
  final KanbanBoardTheme? theme;

  /// Controls how the board is laid out
  final KanbanLayoutMode? layoutMode;

  /// Event callbacks
  final void Function(KanbanItem item, String fromColumn, String toColumn)?
      onItemMoved;
  final void Function(KanbanItem item, String column)? onItemAdded;
  final void Function(KanbanItem item, int oldIndex, int newIndex)?
      onItemReordered;

  /// Width threshold below which the board switches to vertical layout
  static const double _mobileBreakpoint = 600;

  /// Custom item builder
  final Widget Function(BuildContext, KanbanItem)? itemBuilder;

  /// Custom column header builder
  final Widget Function(BuildContext, String, int, int?)? columnHeaderBuilder;

  /// Custom pagination builder
  final Widget Function(BuildContext, int currentPage, int totalPages)?
      paginationBuilder;

  KanbanBoard({
    super.key,
    this.columns,
    this.storage,
    this.controller,
    this.theme,
    this.layoutMode,
    this.onItemMoved,
    this.onItemAdded,
    this.onItemReordered,
    this.itemBuilder,
    this.columnHeaderBuilder,
    this.paginationBuilder,
  }) : assert((columns != null) || (storage != null) || (controller != null),
            'Either columns, storage, or controller must be provided');

  /// Creates a Kanban board from an existing storage instance
  factory KanbanBoard.fromStorage({
    required KanbanStorage storage,
    KanbanBoardTheme? theme,
    KanbanLayoutMode? layoutMode,
  }) {
    return KanbanBoard(
      storage: storage,
      theme: theme,
      layoutMode: layoutMode,
    );
  }

  /// Creates a standard three-column board with typical settings
  factory KanbanBoard.standard({
    KanbanBoardTheme? theme,
    List<KanbanItem>? backlogItems,
    List<KanbanItem>? inProgressItems,
    List<KanbanItem>? doneItems,
    int? backlogLimit,
    int? workInProgressLimit = 3,
    int? doneLimit,
  }) {
    return KanbanBoard(
      theme: theme,
      columns: [
        KanbanColumnConfig.backlog(
          initialItems: backlogItems ?? [],
          limit: backlogLimit,
        ),
        KanbanColumnConfig.workInProgress(
          limit: workInProgressLimit ?? 3,
          initialItems: inProgressItems ?? [],
        ),
        KanbanColumnConfig.done(
          initialItems: doneItems ?? [],
          limit: doneLimit,
        ),
      ],
    );
  }

  // Helper to derive column configs from storage
  static List<KanbanColumnConfig> columnsFromStorage(KanbanStorage storage) {
    return storage.columns.map((column) {
      final items = storage.getItemsForColumn(column);
      final isWIP = column.limit != null;

      if (isWIP) {
        return KanbanColumnConfig.workInProgress(
          title: column.title,
          initialItems: items,
          limit: column.limit ?? 3,
        );
      } else {
        return KanbanColumnConfig(
          title: column.title,
          initialItems: items,
          limit: column.limit,
          canAddItems: true, // Default to true for flexibility
        );
      }
    }).toList();
  }

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();

  static KanbanController of(BuildContext context) {
    final state = context.findAncestorStateOfType<_KanbanBoardState>();
    if (state == null) {
      throw FlutterError(
          'KanbanBoard.of() called with a context that does not contain a KanbanBoard.');
    }
    return state._controller;
  }
}

class _KanbanBoardState extends State<KanbanBoard>
    with SingleTickerProviderStateMixin {
  late final KanbanController _controller;
  late final KanbanColumnProvider _columnProvider;
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _initializeColumnProvider();
    _pageController = PageController();

    // Register for controller events
    _controller.addListener(_handleControllerUpdate);
  }

  @override
  void dispose() {
    // Clean up controller
    _controller.removeListener(_handleControllerUpdate);
    super.dispose();
  }

  void _handleControllerUpdate() {
    setState(() {});
  }

  void _initializeController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else if (widget.storage != null) {
      _controller = KanbanController(storage: widget.storage);
    } else if (widget.columns != null) {
      _controller = KanbanController(columns: widget.columns);
    } else {
      _controller = KanbanController(columns: []);
    }
  }

  void _initializeColumnProvider() {
    if (widget.columns != null) {
      _columnProvider = KanbanColumnProvider(
        configs: widget.columns!,
        storage: _controller.storage,
      );
    } else {
      _columnProvider = KanbanColumnProvider.fromStorage(_controller.storage);
    }
  }

  void _addItem(String columnTitle, String title, String subtitle) {
    setState(() {
      _controller.addItem(columnTitle, title, subtitle);

      // Find the added item and trigger callback
      final column = _controller.storage.columns
          .firstWhere((col) => col.title == columnTitle);
      final addedItemId = column.itemIds.last;
      final addedItem = _controller.storage.items[addedItemId]!;

      widget.onItemAdded?.call(addedItem, columnTitle);
    });
  }

  void _moveToColumn(String itemId, String direction) {
    // Store the item and its current column before moving
    final item = _controller.storage.items[itemId];
    if (item == null) return;

    // Find the current column
    String? fromColumnTitle;
    for (final column in _controller.storage.columns) {
      if (column.itemIds.contains(itemId)) {
        fromColumnTitle = column.title;
        break;
      }
    }

    if (fromColumnTitle == null) return;

    // Find the target column
    int currentIndex = _controller.storage.columns
        .indexWhere((column) => column.title == fromColumnTitle);

    int targetIndex;
    if (direction == 'left') {
      targetIndex = currentIndex - 1;
    } else {
      targetIndex = currentIndex + 1;
    }

    if (targetIndex < 0 || targetIndex >= _controller.storage.columns.length)
      return;

    String toColumnTitle = _controller.storage.columns[targetIndex].title;

    // Move the item
    setState(() {
      _controller.moveToColumn(itemId, direction);

      // Notify about the move
      widget.onItemMoved?.call(item, fromColumnTitle!, toColumnTitle);
    });
  }

  void _reorderItem(String itemId, int newIndex) {
    // Get the item that's being reordered
    final item = _controller.storage.items[itemId];
    if (item == null) return;

    // Find which column contains this item
    String? columnTitle;
    int? oldIndex;
    for (final column in _controller.storage.columns) {
      oldIndex = column.itemIds.indexOf(itemId);
      if (oldIndex != -1) {
        columnTitle = column.title;
        break;
      }
    }

    if (columnTitle == null || oldIndex == null) return;

    setState(() {
      // Perform the reordering
      _controller.reorderItem(itemId, newIndex);

      // Call the callback - use ! to assert non-nullability
      widget.onItemReordered?.call(item, oldIndex!, newIndex);

      // Log the reordering
      print(
          'Item reordered: ${item.title} in $columnTitle from position $oldIndex to $newIndex');
    });
  }

  List<KanbanItem> _getItemsForColumn(KanbanColumn column) {
    return _controller.getItemsForColumn(column);
  }

  Widget _buildPageIndicator(KanbanBoardTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_controller.storage.columns.length, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentPage
                ? theme.headerColor
                : theme.headerColor.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }

  Widget _buildMobileLayout(KanbanBoardTheme theme) {
    return Column(
      children: [
        Container(
          height: 64.0,
          decoration: BoxDecoration(
            color: theme.headerColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    color: theme.headerTextColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          // Title and count grouped together
                          Row(
                            children: [
                              Text(
                                _controller.storage.columns[_currentPage].title,
                                style: TextStyle(
                                  color: theme.headerTextColor,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.columnColor.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  _controller.storage.columns[_currentPage]
                                              .limit !=
                                          null
                                      ? '${_controller.storage.getItemsForColumn(_controller.storage.columns[_currentPage]).length}/${_controller.storage.columns[_currentPage].limit}'
                                      : '${_controller.storage.getItemsForColumn(_controller.storage.columns[_currentPage]).length}',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                    color: theme.countTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Add button on the right with spacing
                          if (_columnProvider
                              .canAddItemsToColumn(_currentPage)) ...[
                            const SizedBox(
                                width:
                                    16.0), // Increased spacing before add button
                            Container(
                              height: 32.0,
                              width: 32.0,
                              decoration: BoxDecoration(
                                color: _controller.storage.columns[_currentPage]
                                        .canAddItem()
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.add_rounded, size: 20.0),
                                padding: EdgeInsets.zero,
                                color: _controller.storage.columns[_currentPage]
                                        .canAddItem()
                                    ? Colors.white
                                    : Colors.grey.shade500,
                                tooltip: _controller
                                        .storage.columns[_currentPage]
                                        .canAddItem()
                                    ? 'Add New Item'
                                    : 'Column is at capacity',
                                onPressed: _controller
                                        .storage.columns[_currentPage]
                                        .canAddItem()
                                    ? () => _showAddItemDialog(_currentPage)
                                    : null,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                        _currentPage < _controller.storage.columns.length - 1
                            ? () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                    color: theme.headerTextColor,
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              _buildPageIndicator(theme),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < -1000 &&
                  _currentPage < _controller.storage.columns.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else if (details.primaryVelocity! > 1000 && _currentPage > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _controller.storage.columns.length,
              itemBuilder: (context, index) {
                final column = _controller.storage.columns[index];
                final config = _columnProvider.getConfig(index);

                final leftHasSpace = index > 0
                    ? _controller.storage.columns[index - 1].canAddItem()
                    : false;
                final rightHasSpace =
                    index < _controller.storage.columns.length - 1
                        ? _controller.storage.columns[index + 1].canAddItem()
                        : false;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: theme.columnColor,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: KanbanColumnWidget(
                    column: column,
                    items: _getItemsForColumn(column),
                    onAddItem: config.canAddItems
                        ? (title, subtitle) =>
                            _addItem(column.title, title, subtitle)
                        : null,
                    onMoveToColumn: _moveToColumn,
                    onReorderItem: _reorderItem,
                    canMoveLeft: index > 0,
                    canMoveRight:
                        index < _controller.storage.columns.length - 1,
                    targetLeftHasSpace: leftHasSpace,
                    targetRightHasSpace: rightHasSpace,
                    theme: theme,
                    hideHeader: true,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddItemDialog(int columnIndex) async {
    try {
      final column = _controller.storage.columns[columnIndex];
      if (!column.canAddItem()) {
        // Show limit reached notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Column "${column.title}" has reached its limit')),
        );
        return;
      }

      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => AddItemDialog(
          onAdd: (title, subtitle) {
            _addItem(column.title, title, subtitle);
          },
        ),
      );
    } catch (e) {
      print('Error showing add item dialog: $e');
    }
  }

  Widget _buildHorizontalLayout(KanbanBoardTheme theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _controller.storage.columns.asMap().entries.map((entry) {
        final index = entry.key;
        final column = entry.value;
        final config = _columnProvider.getConfig(index);

        // Check if adjacent columns have space
        final leftHasSpace = index > 0
            ? _controller.storage.columns[index - 1].canAddItem()
            : false;
        final rightHasSpace = index < _controller.storage.columns.length - 1
            ? _controller.storage.columns[index + 1].canAddItem()
            : false;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: KanbanColumnWidget(
              column: column,
              items: _getItemsForColumn(column),
              onAddItem: config.canAddItems
                  ? (title, subtitle) => _addItem(column.title, title, subtitle)
                  : null,
              onMoveToColumn: _moveToColumn,
              onReorderItem: _reorderItem,
              canMoveLeft: index > 0,
              canMoveRight: index < _controller.storage.columns.length - 1,
              targetLeftHasSpace: leftHasSpace,
              targetRightHasSpace: rightHasSpace,
              theme: theme,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? const KanbanBoardTheme();
    final screenWidth = MediaQuery.of(context).size.width;
    final useVerticalLayout = widget.layoutMode == KanbanLayoutMode.vertical ||
        (widget.layoutMode == null &&
            screenWidth < KanbanBoard._mobileBreakpoint);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: useVerticalLayout
          ? _buildMobileLayout(theme)
          : _buildHorizontalLayout(theme),
    );
  }
}

// Create a service locator
class KanbanServiceLocator {
  static final KanbanServiceLocator instance = KanbanServiceLocator._();

  KanbanServiceLocator._();

  final _services = <Type, Object>{};

  void register<T extends Object>(T service) {
    _services[T] = service;
  }

  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not registered');
    }
    return service as T;
  }
}

// Use it for storage, analytics, etc.

abstract class KanbanPlugin {
  void onBoardInitialized(KanbanController controller);
  void onItemAdded(KanbanItem item, String columnTitle);
  void onItemMoved(KanbanItem item, String fromColumn, String toColumn);
  void onBoardDisposed();
  void onItemReordered(
      KanbanItem item, int oldIndex, int newIndex, String columnTitle);
  void onColumnLimitReached(String columnTitle, int limit);
  void onBoardPersisted(String location);
  void onBoardLoaded(String location);
}
