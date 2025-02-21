import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/kanban_item.dart';
import '../models/kanban_column.dart';
import '../models/kanban_column_config.dart';
import 'kanban_column.dart';

class KanbanBoardTheme {
  final Color backgroundColor;
  final Color columnColor;
  final Color cardColor;
  final Color cardBorderColor;
  final Color headerColor;
  final Color footerColor;
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
    this.footerColor = Colors.white,
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

class _KanbanBoardState extends State<KanbanBoard> {
  final _uuid = const Uuid();
  late final Map<String, KanbanItem> _items;
  late final List<KanbanColumn> _columns;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    _items = {};

    // Initialize items from the configurations
    for (var config in widget.columns) {
      for (var item in config.initialItems) {
        _items[item.id] = item;
      }
    }

    // Initialize columns from configurations
    _columns = widget.columns.map((config) {
      return KanbanColumn(
        title: config.title,
        itemIds: config.initialItems.map((item) => item.id).toList(),
        limit: config.limit,
      );
    }).toList();
  }

  int _getDefaultLimit(String columnTitle) {
    switch (columnTitle) {
      case 'In Progress':
        return 3;
      default:
        return 5;
    }
  }

  void _addItem(String columnTitle, String title, String subtitle) {
    final columnIndex = _columns.indexWhere((col) => col.title == columnTitle);
    if (columnIndex == -1) return;

    final column = _columns[columnIndex];
    if (!column.canAddItem()) return;

    final itemId = _uuid.v4();
    final item = KanbanItem(
      id: itemId,
      title: title,
      subtitle: subtitle,
    );

    setState(() {
      _items[itemId] = item;
      _columns[columnIndex] = column.copyWith(
        itemIds: [...column.itemIds, itemId],
      );
    });
  }

  void _moveToColumn(String itemId, String direction) {
    final currentColumnIndex = _columns.indexWhere(
      (col) => col.itemIds.contains(itemId),
    );
    if (currentColumnIndex == -1) return;

    int targetColumnIndex;
    if (direction == 'left') {
      targetColumnIndex = currentColumnIndex - 1;
    } else if (direction == 'right') {
      targetColumnIndex = currentColumnIndex + 1;
    } else {
      return;
    }

    if (targetColumnIndex < 0 || targetColumnIndex >= _columns.length) return;

    final sourceColumn = _columns[currentColumnIndex];
    final targetColumn = _columns[targetColumnIndex];

    // Check if target column has space
    if (!targetColumn.canAddItem()) return;

    setState(() {
      _columns[currentColumnIndex] = sourceColumn.copyWith(
        itemIds: sourceColumn.itemIds.where((id) => id != itemId).toList(),
      );
      _columns[targetColumnIndex] = targetColumn.copyWith(
        itemIds: [...targetColumn.itemIds, itemId],
      );
    });
  }

  void _reorderItem(String itemId, int newIndex) {
    final columnIndex = _columns.indexWhere(
      (col) => col.itemIds.contains(itemId),
    );
    if (columnIndex == -1) return;

    final column = _columns[columnIndex];
    final currentIndex = column.itemIds.indexOf(itemId);
    if (currentIndex == -1 || currentIndex == newIndex) return;

    setState(() {
      final newItemIds = List<String>.from(column.itemIds);
      newItemIds.removeAt(currentIndex);
      newItemIds.insert(newIndex, itemId);
      _columns[columnIndex] = column.copyWith(itemIds: newItemIds);
    });
  }

  List<KanbanItem> _getItemsForColumn(KanbanColumn column) {
    return column.itemIds
        .map((id) => _items[id])
        .whereType<KanbanItem>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? const KanbanBoardTheme();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _columns.asMap().entries.map((entry) {
          final index = entry.key;
          final column = entry.value;
          final config = widget.columns[index];

          // Check if adjacent columns have space
          final leftHasSpace =
              index > 0 ? _columns[index - 1].canAddItem() : false;
          final rightHasSpace = index < _columns.length - 1
              ? _columns[index + 1].canAddItem()
              : false;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                canMoveRight: index < _columns.length - 1,
                targetLeftHasSpace: leftHasSpace,
                targetRightHasSpace: rightHasSpace,
                theme: theme,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
