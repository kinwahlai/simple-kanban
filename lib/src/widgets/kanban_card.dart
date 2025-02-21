import 'package:flutter/material.dart';
import '../models/kanban_item.dart';

class KanbanCard extends StatelessWidget {
  final KanbanItem item;
  final Color backgroundColor;
  final Color borderColor;

  const KanbanCard({
    super.key,
    required this.item,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<String>(
      data: item.id,
      feedback: Material(
        elevation: 4.0,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: _buildCard(),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildCard(),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    return Card(
      elevation: 2.0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
            Icon(
              Icons.drag_indicator,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
