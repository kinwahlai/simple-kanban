import 'package:flutter/material.dart';
import '../models/kanban_item.dart';

class KanbanCard extends StatelessWidget {
  final KanbanItem item;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onMoveLeft;
  final VoidCallback? onMoveRight;

  const KanbanCard({
    super.key,
    required this.item,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE0E0E0),
    this.onMoveUp,
    this.onMoveDown,
    this.onMoveLeft,
    this.onMoveRight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
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
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
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
          // Control buttons
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
                  icon: Icons.arrow_upward,
                  onPressed: onMoveUp,
                  tooltip: 'Move Up',
                ),
                _buildControlButton(
                  icon: Icons.arrow_downward,
                  onPressed: onMoveDown,
                  tooltip: 'Move Down',
                ),
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
