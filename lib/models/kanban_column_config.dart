import 'kanban_item.dart';

/// Configuration for a Kanban column, encapsulating all column-specific settings
class KanbanColumnConfig {
  /// The title of the column
  final String title;

  /// Initial items in the column
  final List<KanbanItem> initialItems;

  /// Maximum number of items allowed in the column
  /// If null, the column can hold unlimited items
  final int? limit;

  /// Whether this column allows adding new items
  final bool canAddItems;

  const KanbanColumnConfig({
    required this.title,
    this.initialItems = const [],
    this.limit,
    this.canAddItems = false,
  });

  /// Creates a backlog-style column (unlimited items by default, with add functionality)
  factory KanbanColumnConfig.backlog({
    String title = 'To Do',
    List<KanbanItem> initialItems = const [],
    int? limit,
  }) {
    return KanbanColumnConfig(
      title: title,
      initialItems: initialItems,
      limit: limit,
      canAddItems: true,
    );
  }

  /// Creates a work-in-progress column (limited items, no add functionality by default)
  factory KanbanColumnConfig.workInProgress({
    String title = 'In Progress',
    List<KanbanItem> initialItems = const [],
    required int limit,
    bool canAddItems = false,
  }) {
    return KanbanColumnConfig(
      title: title,
      initialItems: initialItems,
      limit: limit,
      canAddItems: canAddItems,
    );
  }

  /// Creates a done/archive column (unlimited items by default, no add functionality)
  factory KanbanColumnConfig.done({
    String title = 'Done',
    List<KanbanItem> initialItems = const [],
    int? limit,
    bool canAddItems = false,
  }) {
    return KanbanColumnConfig(
      title: title,
      initialItems: initialItems,
      limit: limit,
      canAddItems: canAddItems,
    );
  }

  /// Creates a copy of this config with the given fields replaced with new values
  KanbanColumnConfig copyWith({
    String? title,
    List<KanbanItem>? initialItems,
    int? limit,
    bool? canAddItems,
  }) {
    return KanbanColumnConfig(
      title: title ?? this.title,
      initialItems: initialItems ?? this.initialItems,
      limit: limit ?? this.limit,
      canAddItems: canAddItems ?? this.canAddItems,
    );
  }
}
