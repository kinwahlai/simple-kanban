import 'package:flutter/material.dart';
import '../models/kanban_item.dart';
import '../models/kanban_column.dart';
import '../models/kanban_column_config.dart';
import 'kanban_column.dart';
import '../models/kanban_storage.dart';
import 'add_item_dialog.dart';

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

class KanbanBoard extends StatefulWidget {
  /// List of column configurations that define the board layout
  final List<KanbanColumnConfig> columns;

  /// Optional theme for customizing the board's appearance
  final KanbanBoardTheme? theme;

  /// Controls how the board is laid out. If not specified,
  /// it will be determined based on screen width.
  final KanbanLayoutMode? layoutMode;

  /// Width threshold below which the board switches to vertical layout
  static const double _mobileBreakpoint = 600;

  /// Default column configuration for a standard board
  static final List<KanbanColumnConfig> _defaultColumns = [
    KanbanColumnConfig.backlog(),
    KanbanColumnConfig.workInProgress(limit: 3),
    KanbanColumnConfig.done(),
  ];

  KanbanBoard({
    super.key,
    List<KanbanColumnConfig>? columns,
    this.theme,
    this.layoutMode,
  }) : columns = columns ?? _defaultColumns;

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

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard>
    with SingleTickerProviderStateMixin {
  late final KanbanStorage _storage;
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
    _pageController = PageController();
  }

  void _initializeBoard() {
    final items = <String, KanbanItem>{};

    // Initialize items from the configurations
    for (var config in widget.columns) {
      for (var item in config.initialItems) {
        items[item.id] = item;
      }
    }

    // Initialize columns from configurations
    final columns = widget.columns.map((config) {
      return KanbanColumn(
        title: config.title,
        itemIds: config.initialItems.map((item) => item.id).toList(),
        limit: config.limit,
      );
    }).toList();

    _storage = KanbanStorage(
      initialItems: items,
      initialColumns: columns,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _addItem(String columnTitle, String title, String subtitle) {
    setState(() {
      _storage.addItem(columnTitle, title, subtitle);
    });
  }

  void _moveToColumn(String itemId, String direction) {
    setState(() {
      _storage.moveToColumn(itemId, direction);
    });
  }

  void _reorderItem(String itemId, int newIndex) {
    setState(() {
      _storage.reorderItem(itemId, newIndex);
    });
  }

  List<KanbanItem> _getItemsForColumn(KanbanColumn column) {
    return _storage.getItemsForColumn(column);
  }

  Widget _buildPageIndicator(KanbanBoardTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_storage.columns.length, (index) {
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
                                _storage.columns[_currentPage].title,
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
                                  _storage.columns[_currentPage].limit != null
                                      ? '${_storage.getItemsForColumn(_storage.columns[_currentPage]).length}/${_storage.columns[_currentPage].limit}'
                                      : '${_storage.getItemsForColumn(_storage.columns[_currentPage]).length}',
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
                          if (widget.columns[_currentPage].canAddItems) ...[
                            const SizedBox(
                                width:
                                    16.0), // Increased spacing before add button
                            Container(
                              height: 32.0,
                              width: 32.0,
                              decoration: BoxDecoration(
                                color:
                                    _storage.columns[_currentPage].canAddItem()
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.add_rounded, size: 20.0),
                                padding: EdgeInsets.zero,
                                color:
                                    _storage.columns[_currentPage].canAddItem()
                                        ? Colors.white
                                        : Colors.grey.shade500,
                                tooltip:
                                    _storage.columns[_currentPage].canAddItem()
                                        ? 'Add New Item'
                                        : 'Column is at capacity',
                                onPressed:
                                    _storage.columns[_currentPage].canAddItem()
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
                    onPressed: _currentPage < _storage.columns.length - 1
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
                  _currentPage < _storage.columns.length - 1) {
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
              itemCount: _storage.columns.length,
              itemBuilder: (context, index) {
                final column = _storage.columns[index];
                final config = widget.columns[index];

                final leftHasSpace = index > 0
                    ? _storage.columns[index - 1].canAddItem()
                    : false;
                final rightHasSpace = index < _storage.columns.length - 1
                    ? _storage.columns[index + 1].canAddItem()
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
                    canMoveRight: index < _storage.columns.length - 1,
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
    final column = _storage.columns[columnIndex];
    if (!column.canAddItem()) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AddItemDialog(
        onAdd: (title, subtitle) {
          _addItem(column.title, title, subtitle);
        },
      ),
    );
  }

  Widget _buildHorizontalLayout(KanbanBoardTheme theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _storage.columns.asMap().entries.map((entry) {
        final index = entry.key;
        final column = entry.value;
        final config = widget.columns[index];

        // Check if adjacent columns have space
        final leftHasSpace =
            index > 0 ? _storage.columns[index - 1].canAddItem() : false;
        final rightHasSpace = index < _storage.columns.length - 1
            ? _storage.columns[index + 1].canAddItem()
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
              canMoveRight: index < _storage.columns.length - 1,
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
