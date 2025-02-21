import 'package:flutter/material.dart';
import '../models/kanban_item.dart';

class KanbanCard extends StatelessWidget {
  final KanbanItem item;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onMoveLeft;
  final VoidCallback? onMoveRight;

  const KanbanCard({
    super.key,
    required this.item,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE0E0E0),
    this.onMoveLeft,
    this.onMoveRight,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: item.id,
      feedback: Material(
        elevation: 4.0,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: _buildCardContent(isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildCardContent(isDragging: false),
      ),
      child: _buildCardContent(isDragging: false),
    );
  }

  Widget _buildCardContent({required bool isDragging}) {
    return Card(
      elevation: isDragging ? 0 : 2.0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.drag_handle,
                      color: Colors.grey.shade400,
                      size: 20.0,
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Control buttons for column movement
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: borderColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.arrow_back,
                  onPressed: onMoveLeft,
                  tooltip: 'Move Left',
                ),
                _buildControlButton(
                  icon: Icons.arrow_forward,
                  onPressed: onMoveRight,
                  tooltip: 'Move Right',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    VoidCallback? onPressed,
    required String tooltip,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        size: 20.0,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
      constraints: const BoxConstraints(
        minWidth: 32.0,
        minHeight: 32.0,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      splashRadius: 20.0,
    );
  }
}
