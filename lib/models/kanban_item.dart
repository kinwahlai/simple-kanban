class KanbanItem {
  final String id;
  final String title;
  final String subtitle;

  KanbanItem({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  KanbanItem copyWith({
    String? id,
    String? title,
    String? subtitle,
  }) {
    return KanbanItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}
