import 'package:flutter/material.dart';
import '../models/kanban_item.dart';
import '../models/kanban_column.dart' as models;
import 'kanban_card.dart';

class KanbanColumnWidget extends StatefulWidget {
  final models.KanbanColumn column;
  final List<KanbanItem> items;
  final Function(String) onAddItem;
  final Function(String, String) onMoveItem;

  const KanbanColumnWidget({
    super.key,
    required this.column,
    required this.items,
    required this.onAddItem,
    required this.onMoveItem,
  });

  @override
  State<KanbanColumnWidget> createState() => _KanbanColumnWidgetState();
}

class _KanbanColumnWidgetState extends State<KanbanColumnWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildItemList(),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
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
              '${widget.items.length}/${widget.column.limit}',
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
    return DragTarget<String>(
      onWillAccept: (data) {
        return widget.column.canAddItem();
      },
      onAccept: (itemId) {
        widget.onMoveItem(itemId, widget.column.title);
      },
      builder: (context, candidateData, rejectedData) {
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: KanbanCard(item: widget.items[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Add new item...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty && widget.column.canAddItem()) {
                  widget.onAddItem(value);
                  _controller.clear();
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: widget.column.canAddItem()
                ? () {
                    if (_controller.text.isNotEmpty) {
                      widget.onAddItem(_controller.text);
                      _controller.clear();
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
