import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/kanban_item.dart';
import '../models/kanban_column.dart';
import 'kanban_column.dart';

class KanbanBoard extends StatefulWidget {
  const KanbanBoard({super.key});

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  final _uuid = const Uuid();
  final Map<String, KanbanItem> _items = {};
  final List<KanbanColumn> _columns = [
    KanbanColumn(
      title: 'To Do',
      itemIds: [],
      limit: 5,
    ),
    KanbanColumn(
      title: 'In Progress',
      itemIds: [],
      limit: 3,
    ),
    KanbanColumn(
      title: 'Done',
      itemIds: [],
      limit: 5,
    ),
  ];

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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
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
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
