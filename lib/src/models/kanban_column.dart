class KanbanColumn {
  final String title;
  final List<String> itemIds;
  final int limit;

  KanbanColumn({
    required this.title,
    required this.itemIds,
    required this.limit,
  });

  bool canAddItem() {
    return itemIds.length < limit;
  }

  KanbanColumn copyWith({
    String? title,
    List<String>? itemIds,
    int? limit,
  }) {
    return KanbanColumn(
      title: title ?? this.title,
      itemIds: itemIds ?? this.itemIds,
      limit: limit ?? this.limit,
    );
  }
}
