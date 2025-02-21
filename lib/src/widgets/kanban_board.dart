import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/kanban_item.dart';
import '../models/kanban_column.dart';
import 'kanban_column.dart';

class KanbanBoardTheme {
  final Color backgroundColor;
  final Color columnColor;
  final Color cardColor;
  final Color cardBorderColor;
  final Color headerColor;
  final Color footerColor;

  const KanbanBoardTheme({
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.columnColor = const Color(0xFFF5F5F5),
    this.cardColor = Colors.white,
    this.cardBorderColor = const Color(0xFFE0E0E0),
    this.headerColor = Colors.white,
    this.footerColor = Colors.white,
  });
}

class KanbanBoard extends StatefulWidget {
  final Map<String, List<KanbanItem>>? initialItems;
  final Map<String, int>? columnLimits;
  final KanbanBoardTheme? theme;
  final List<String> columnTitles;

  const KanbanBoard({
    super.key,
    this.initialItems,
    this.columnLimits,
    this.theme,
    this.columnTitles = const ['To Do', 'In Progress', 'Done'],
  });

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

    // Initialize items from the provided initial items
    widget.initialItems?.forEach((columnTitle, items) {
      for (var item in items) {
        _items[item.id] = item;
      }
    });

    // Initialize columns with provided limits and items
    _columns = widget.columnTitles.map((title) {
      final limit = widget.columnLimits?[title] ?? _getDefaultLimit(title);
      final columnItems = widget.initialItems?[title] ?? [];
      return KanbanColumn(
        title: title,
        itemIds: columnItems.map((item) => item.id).toList(),
        limit: limit,
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

  void _addItem(String columnTitle, String title) {
    final columnIndex = _columns.indexWhere((col) => col.title == columnTitle);
    if (columnIndex == -1) return;

    final column = _columns[columnIndex];
    if (!column.canAddItem()) return;

    final itemId = _uuid.v4();
    final item = KanbanItem(
      id: itemId,
      title: title,
      subtitle: 'Added to $columnTitle',
    );

    setState(() {
      _items[itemId] = item;
      _columns[columnIndex] = column.copyWith(
        itemIds: [...column.itemIds, itemId],
      );
    });
  }

  void _moveItem(String itemId, String targetColumnTitle) {
    final sourceColumnIndex = _columns.indexWhere(
      (col) => col.itemIds.contains(itemId),
    );
    final targetColumnIndex = _columns.indexWhere(
      (col) => col.title == targetColumnTitle,
    );

    if (sourceColumnIndex == -1 || targetColumnIndex == -1) return;

    final sourceColumn = _columns[sourceColumnIndex];
    final targetColumn = _columns[targetColumnIndex];

    if (!targetColumn.canAddItem()) return;

    setState(() {
      _columns[sourceColumnIndex] = sourceColumn.copyWith(
        itemIds: sourceColumn.itemIds.where((id) => id != itemId).toList(),
      );
      _columns[targetColumnIndex] = targetColumn.copyWith(
        itemIds: [...targetColumn.itemIds, itemId],
      );
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
        children: _columns.map((column) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: KanbanColumnWidget(
                column: column,
                items: _getItemsForColumn(column),
                onAddItem: (title) => _addItem(column.title, title),
                onMoveItem: _moveItem,
                theme: theme,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
