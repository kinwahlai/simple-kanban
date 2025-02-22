import 'package:flutter/material.dart';
import '../models/kanban_item.dart';

class KanbanCard extends StatelessWidget {
  final KanbanItem item;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback? onMoveLeft;
  final VoidCallback? onMoveRight;

  const KanbanCard({
    super.key,
    required this.item,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE0E0E0),
    this.titleColor = Colors.black87,
    this.subtitleColor = Colors.black54,
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
        side: BorderSide(
          color: borderColor,
          width: 1.0,
          style: BorderStyle.solid,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Container(
          decoration: BoxDecoration(
            gradient: isDragging
                ? null
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      backgroundColor,
                      backgroundColor.withOpacity(0.95),
                    ],
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 8.0, 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 14.0,
                              height: 1.3,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: borderColor.withOpacity(0.7),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildControlButton(
                            icon: Icons.chevron_left,
                            onPressed: onMoveLeft,
                            tooltip: 'Move to Previous Column',
                            color: onMoveLeft != null
                                ? Colors.blue.shade700
                                : Colors.grey.shade300,
                          ),
                          Container(
                            height: 1,
                            width: 16,
                            margin: const EdgeInsets.symmetric(vertical: 2.0),
                            color: borderColor.withOpacity(0.7),
                          ),
                          _buildControlButton(
                            icon: Icons.chevron_right,
                            onPressed: onMoveRight,
                            tooltip: 'Move to Next Column',
                            color: onMoveRight != null
                                ? Colors.blue.shade700
                                : Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    VoidCallback? onPressed,
    required String tooltip,
    required Color color,
  }) {
    return SizedBox(
      width: 32.0,
      height: 28.0,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(4.0),
            child: Container(
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 18.0,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
