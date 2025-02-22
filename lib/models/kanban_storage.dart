import 'package:uuid/uuid.dart';
import 'kanban_item.dart';
import 'kanban_column.dart';

class KanbanStorage {
  final _uuid = const Uuid();
  final Map<String, KanbanItem> items;
  List<KanbanColumn> get columns => _columns;
  final List<KanbanColumn> _columns;

  KanbanStorage({
    Map<String, KanbanItem>? initialItems,
    List<KanbanColumn>? initialColumns,
  })  : items = initialItems ?? {},
        _columns = initialColumns ?? [];

  void addItem(String columnTitle, String title, String subtitle) {
    final columnIndex = columns.indexWhere((col) => col.title == columnTitle);
    if (columnIndex == -1) return;

    final column = columns[columnIndex];
    if (!column.canAddItem()) return;

    final itemId = _uuid.v4();
    final item = KanbanItem(
      id: itemId,
      title: title,
      subtitle: subtitle,
    );

    items[itemId] = item;
    columns[columnIndex] = column.copyWith(
      itemIds: [...column.itemIds, itemId],
    );
  }

  void moveToColumn(String itemId, String direction) {
    final currentColumnIndex = columns.indexWhere(
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

    if (targetColumnIndex < 0 || targetColumnIndex >= columns.length) return;

    final sourceColumn = columns[currentColumnIndex];
    final targetColumn = columns[targetColumnIndex];

    if (!targetColumn.canAddItem()) return;

    columns[currentColumnIndex] = sourceColumn.copyWith(
      itemIds: sourceColumn.itemIds.where((id) => id != itemId).toList(),
    );
    columns[targetColumnIndex] = targetColumn.copyWith(
      itemIds: [...targetColumn.itemIds, itemId],
    );
  }

  void reorderItem(String itemId, int newIndex) {
    final columnIndex = columns.indexWhere(
      (col) => col.itemIds.contains(itemId),
    );
    if (columnIndex == -1) return;

    final column = columns[columnIndex];
    final currentIndex = column.itemIds.indexOf(itemId);
    if (currentIndex == -1 || currentIndex == newIndex) return;

    final newItemIds = List<String>.from(column.itemIds);
    newItemIds.removeAt(currentIndex);
    newItemIds.insert(newIndex, itemId);
    columns[columnIndex] = column.copyWith(itemIds: newItemIds);
  }

  List<KanbanItem> getItemsForColumn(KanbanColumn column) {
    return column.itemIds
        .map((id) => items[id])
        .whereType<KanbanItem>()
        .toList();
  }
}
