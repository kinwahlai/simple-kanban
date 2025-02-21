import 'package:flutter/material.dart';
import '../models/kanban_item.dart';

class KanbanCard extends StatelessWidget {
  final KanbanItem item;
  final VoidCallback? onTap;

  const KanbanCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: item.id,
      feedback: Material(
        elevation: 4.0,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.3,
          child: _buildCard(),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildCard(),
      ),
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
      ),
    );
  }
}
