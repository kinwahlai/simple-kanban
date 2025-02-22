class KanbanColumn {
  final String title;
  final List<String> itemIds;
  final int? limit;

  const KanbanColumn({
    required this.title,
    required this.itemIds,
    this.limit,
  });

  bool canAddItem() {
    if (limit == null) return true;
    return itemIds.length < (limit ?? 0);
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
