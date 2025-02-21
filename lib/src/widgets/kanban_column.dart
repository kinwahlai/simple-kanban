import 'package:flutter/material.dart';
import '../models/kanban_item.dart';
import '../models/kanban_column.dart' as models;
import 'kanban_board.dart';
import 'kanban_card.dart';

class KanbanColumnWidget extends StatefulWidget {
  final models.KanbanColumn column;
  final List<KanbanItem> items;

  /// Callback for adding new items. If null, the column won't support adding items.
  /// This should be null for columns that shouldn't allow new items to be added.
  final Function(String title, String subtitle)? onAddItem;
  final Function(String, String) onMoveToColumn;
  final Function(String, int) onReorderItem;
  final bool canMoveLeft;
  final bool canMoveRight;
  final bool targetLeftHasSpace;
  final bool targetRightHasSpace;
  final KanbanBoardTheme theme;

  /// Controls whether this column shows a footer with add item functionality.
  /// If false, no footer will be shown regardless of onAddItem callback.
  /// If true, footer will be shown only if onAddItem is also provided.
  final bool showFooter;

  const KanbanColumnWidget({
    super.key,
    required this.column,
    required this.items,
    this.onAddItem,
    required this.onMoveToColumn,
    required this.onReorderItem,
    required this.canMoveLeft,
    required this.canMoveRight,
    required this.targetLeftHasSpace,
    required this.targetRightHasSpace,
    required this.theme,
    this.showFooter = true,
  });

  @override
  State<KanbanColumnWidget> createState() => _KanbanColumnWidgetState();
}

class _KanbanColumnWidgetState extends State<KanbanColumnWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.theme.columnColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildItemList(),
          ),
          if (widget.showFooter && widget.onAddItem != null) _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: widget.theme.headerColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.column.title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              widget.column.limit != null
                  ? '${widget.items.length}/${widget.column.limit}'
                  : '${widget.items.length}',
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return _buildDraggableItem(item, index);
      },
    );
  }

  Widget _buildDraggableItem(KanbanItem item, int index) {
    return DragTarget<String>(
      onWillAccept: (data) {
        // Only accept items from the same column
        return data != null && widget.column.itemIds.contains(data);
      },
      onAccept: (data) {
        final draggedIndex = widget.items.indexWhere((item) => item.id == data);
        if (draggedIndex != -1 && draggedIndex != index) {
          widget.onReorderItem(data, index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: KanbanCard(
            item: item,
            backgroundColor: widget.theme.cardColor,
            borderColor: widget.theme.cardBorderColor,
            onMoveLeft: widget.canMoveLeft && widget.targetLeftHasSpace
                ? () => widget.onMoveToColumn(item.id, 'left')
                : null,
            onMoveRight: widget.canMoveRight && widget.targetRightHasSpace
                ? () => widget.onMoveToColumn(item.id, 'right')
                : null,
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: widget.theme.footerColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Item title...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
            textInputAction: TextInputAction.next,
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtitleController,
                  decoration: const InputDecoration(
                    hintText: 'Item description...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                  onSubmitted: (_) => _handleAddItem(
                    _titleController.text,
                    _subtitleController.text,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: widget.column.canAddItem()
                    ? () => _handleAddItem(
                        _titleController.text, _subtitleController.text)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleAddItem(String title, String subtitle) {
    if (title.isNotEmpty && widget.column.canAddItem()) {
      widget.onAddItem?.call(title, subtitle);
      _titleController.clear();
      _subtitleController.clear();
    }
  }
}
