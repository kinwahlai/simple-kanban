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

  /// Whether this column should show the footer with add functionality
  final bool showFooter;

  const KanbanColumnConfig({
    required this.title,
    this.initialItems = const [],
    this.limit,
    this.showFooter = true,
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
      showFooter: true,
    );
  }

  /// Creates a work-in-progress column (limited items, no add functionality)
  factory KanbanColumnConfig.workInProgress({
    String title = 'In Progress',
    List<KanbanItem> initialItems = const [],
    required int limit,
  }) {
    return KanbanColumnConfig(
      title: title,
      initialItems: initialItems,
      limit: limit,
      showFooter: false,
    );
  }

  /// Creates a done/archive column (unlimited items by default, no add functionality)
  factory KanbanColumnConfig.done({
    String title = 'Done',
    List<KanbanItem> initialItems = const [],
    int? limit,
  }) {
    return KanbanColumnConfig(
      title: title,
      initialItems: initialItems,
      limit: limit,
      showFooter: false,
    );
  }

  /// Creates a copy of this config with the given fields replaced with new values
  KanbanColumnConfig copyWith({
    String? title,
    List<KanbanItem>? initialItems,
    int? limit,
    bool? showFooter,
  }) {
    return KanbanColumnConfig(
      title: title ?? this.title,
      initialItems: initialItems ?? this.initialItems,
      limit: limit ?? this.limit,
      showFooter: showFooter ?? this.showFooter,
    );
  }
}
