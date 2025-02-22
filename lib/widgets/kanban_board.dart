import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/kanban_item.dart';
import '../models/kanban_column.dart';
import '../models/kanban_column_config.dart';
import 'kanban_column.dart';

/// Defines how the Kanban board should be laid out
enum KanbanLayoutMode {
  /// Horizontal scrolling layout for desktop/tablet
  horizontal,

  /// Vertical stacked layout for mobile
  vertical
}

class KanbanBoardTheme {
  final Color backgroundColor;
  final Color columnColor;
  final Color cardColor;
  final Color cardBorderColor;
  final Color headerColor;
  final Color headerTextColor;
  final Color cardTitleColor;
  final Color cardSubtitleColor;
  final Color countTextColor;

  const KanbanBoardTheme({
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.columnColor = const Color(0xFFF5F5F5),
    this.cardColor = Colors.white,
    this.cardBorderColor = const Color(0xFFE0E0E0),
    this.headerColor = Colors.white,
    this.headerTextColor = Colors.black87,
    this.cardTitleColor = Colors.black87,
    this.cardSubtitleColor = Colors.black54,
    this.countTextColor = Colors.black87,
  });
}

class KanbanBoard extends StatefulWidget {
  /// List of column configurations that define the board layout
  final List<KanbanColumnConfig> columns;

  /// Optional theme for customizing the board's appearance
  final KanbanBoardTheme? theme;

  /// Controls how the board is laid out. If not specified,
  /// it will be determined based on screen width.
  final KanbanLayoutMode? layoutMode;

  /// Width threshold below which the board switches to vertical layout
  static const double _mobileBreakpoint = 600;

  /// Default column configuration for a standard board
  static final List<KanbanColumnConfig> _defaultColumns = [
    KanbanColumnConfig.backlog(),
    KanbanColumnConfig.workInProgress(limit: 3),
    KanbanColumnConfig.done(),
  ];

  KanbanBoard({
    super.key,
    List<KanbanColumnConfig>? columns,
    this.theme,
    this.layoutMode,
  }) : columns = columns ?? _defaultColumns;

  /// Creates a standard three-column board with typical settings
  factory KanbanBoard.standard({
    KanbanBoardTheme? theme,
    List<KanbanItem>? backlogItems,
    List<KanbanItem>? inProgressItems,
    List<KanbanItem>? doneItems,
    int? backlogLimit,
    int? workInProgressLimit = 3,
    int? doneLimit,
  }) {
    return KanbanBoard(
      theme: theme,
      columns: [
        KanbanColumnConfig.backlog(
          initialItems: backlogItems ?? [],
          limit: backlogLimit,
        ),
        KanbanColumnConfig.workInProgress(
          limit: workInProgressLimit ?? 3,
          initialItems: inProgressItems ?? [],
        ),
        KanbanColumnConfig.done(
          initialItems: doneItems ?? [],
          limit: doneLimit,
        ),
      ],
    );
  }

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard>
    with SingleTickerProviderStateMixin {
  final _uuid = const Uuid();
  late final Map<String, KanbanItem> _items;
  late final List<KanbanColumn> _columns;
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initializeBoard() {
    _items = {};

    // Initialize items from the configurations
    for (var config in widget.columns) {
      for (var item in config.initialItems) {
        _items[item.id] = item;
      }
    }

    // Initialize columns from configurations
    _columns = widget.columns.map((config) {
      return KanbanColumn(
        title: config.title,
        itemIds: config.initialItems.map((item) => item.id).toList(),
        limit: config.limit,
      );
    }).toList();
  }

  int _getDefaultLimit(String columnTitle) {
    switch (columnTitle) {
      case 'In Progress':
        return 3;
      default:
        return 5;
    }
  }

  void _addItem(String columnTitle, String title, String subtitle) {
    final columnIndex = _columns.indexWhere((col) => col.title == columnTitle);
    if (columnIndex == -1) return;

    final column = _columns[columnIndex];
    if (!column.canAddItem()) return;

    final itemId = _uuid.v4();
    final item = KanbanItem(
      id: itemId,
      title: title,
      subtitle: subtitle,
    );

    setState(() {
      _items[itemId] = item;
      _columns[columnIndex] = column.copyWith(
        itemIds: [...column.itemIds, itemId],
      );
    });
  }

  void _moveToColumn(String itemId, String direction) {
    final currentColumnIndex = _columns.indexWhere(
      (col) => col.itemIds.contains(itemId),
    );
    if (currentColumnIndex == -1) return;

    int targetColumnIndex;
    if (direction == 'left') {
      targetColumnIndex = currentColumnIndex - 1;
    } else if (direction == 'right') {
      targetColumnIndex = currentColumnIndex + 1;
    } else {
      return;
    }

    if (targetColumnIndex < 0 || targetColumnIndex >= _columns.length) return;

    final sourceColumn = _columns[currentColumnIndex];
    final targetColumn = _columns[targetColumnIndex];

    // Check if target column has space
    if (!targetColumn.canAddItem()) return;

    setState(() {
      _columns[currentColumnIndex] = sourceColumn.copyWith(
        itemIds: sourceColumn.itemIds.where((id) => id != itemId).toList(),
      );
      _columns[targetColumnIndex] = targetColumn.copyWith(
        itemIds: [...targetColumn.itemIds, itemId],
      );
    });
  }

  void _reorderItem(String itemId, int newIndex) {
    final columnIndex = _columns.indexWhere(
      (col) => col.itemIds.contains(itemId),
    );
    if (columnIndex == -1) return;

    final column = _columns[columnIndex];
    final currentIndex = column.itemIds.indexOf(itemId);
    if (currentIndex == -1 || currentIndex == newIndex) return;

    setState(() {
      final newItemIds = List<String>.from(column.itemIds);
      newItemIds.removeAt(currentIndex);
      newItemIds.insert(newIndex, itemId);
      _columns[columnIndex] = column.copyWith(itemIds: newItemIds);
    });
  }

  List<KanbanItem> _getItemsForColumn(KanbanColumn column) {
    return column.itemIds
        .map((id) => _items[id])
        .whereType<KanbanItem>()
        .toList();
  }

  Widget _buildPageIndicator(KanbanBoardTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_columns.length, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentPage
                ? theme.headerColor
                : theme.headerColor.withOpacity(0.3),
          ),
        );
      }),
    );
  }

  Widget _buildMobileLayout(KanbanBoardTheme theme) {
    return Column(
      children: [
        Container(
          height: 64.0,
          decoration: BoxDecoration(
            color: theme.headerColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    color: theme.headerTextColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          // Title and count grouped together
                          Row(
                            children: [
                              Text(
                                _columns[_currentPage].title,
                                style: TextStyle(
                                  color: theme.headerTextColor,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.columnColor.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  _columns[_currentPage].limit != null
                                      ? '${_getItemsForColumn(_columns[_currentPage]).length}/${_columns[_currentPage].limit}'
                                      : '${_getItemsForColumn(_columns[_currentPage]).length}',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                    color: theme.countTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Add button on the right with spacing
                          if (widget.columns[_currentPage].canAddItems) ...[
                            const SizedBox(
                                width:
                                    16.0), // Increased spacing before add button
                            Container(
                              height: 32.0,
                              width: 32.0,
                              decoration: BoxDecoration(
                                color: _columns[_currentPage].canAddItem()
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.add_rounded, size: 20.0),
                                padding: EdgeInsets.zero,
                                color: _columns[_currentPage].canAddItem()
                                    ? Colors.white
                                    : Colors.grey.shade500,
                                tooltip: _columns[_currentPage].canAddItem()
                                    ? 'Add New Item'
                                    : 'Column is at capacity',
                                onPressed: _columns[_currentPage].canAddItem()
                                    ? () => _showAddItemDialog(_currentPage)
                                    : null,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _columns.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    color: theme.headerTextColor,
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              _buildPageIndicator(theme),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < -1000 &&
                  _currentPage < _columns.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else if (details.primaryVelocity! > 1000 && _currentPage > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _columns.length,
              itemBuilder: (context, index) {
                final column = _columns[index];
                final config = widget.columns[index];

                final leftHasSpace =
                    index > 0 ? _columns[index - 1].canAddItem() : false;
                final rightHasSpace = index < _columns.length - 1
                    ? _columns[index + 1].canAddItem()
                    : false;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: theme.columnColor,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: KanbanColumnWidget(
                    column: column,
                    items: _getItemsForColumn(column),
                    onAddItem: config.canAddItems
                        ? (title, subtitle) =>
                            _addItem(column.title, title, subtitle)
                        : null,
                    onMoveToColumn: _moveToColumn,
                    onReorderItem: _reorderItem,
                    canMoveLeft: index > 0,
                    canMoveRight: index < _columns.length - 1,
                    targetLeftHasSpace: leftHasSpace,
                    targetRightHasSpace: rightHasSpace,
                    theme: theme,
                    hideHeader: true,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddItemDialog(int columnIndex) async {
    final column = _columns[columnIndex];
    if (!column.canAddItem()) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => _AddItemDialog(
        onAdd: (title, subtitle) {
          _addItem(column.title, title, subtitle);
        },
      ),
    );
  }

  Widget _buildHorizontalLayout(KanbanBoardTheme theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _columns.asMap().entries.map((entry) {
        final index = entry.key;
        final column = entry.value;
        final config = widget.columns[index];

        // Check if adjacent columns have space
        final leftHasSpace =
            index > 0 ? _columns[index - 1].canAddItem() : false;
        final rightHasSpace = index < _columns.length - 1
            ? _columns[index + 1].canAddItem()
            : false;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: KanbanColumnWidget(
              column: column,
              items: _getItemsForColumn(column),
              onAddItem: config.canAddItems
                  ? (title, subtitle) => _addItem(column.title, title, subtitle)
                  : null,
              onMoveToColumn: _moveToColumn,
              onReorderItem: _reorderItem,
              canMoveLeft: index > 0,
              canMoveRight: index < _columns.length - 1,
              targetLeftHasSpace: leftHasSpace,
              targetRightHasSpace: rightHasSpace,
              theme: theme,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? const KanbanBoardTheme();
    final screenWidth = MediaQuery.of(context).size.width;
    final useVerticalLayout = widget.layoutMode == KanbanLayoutMode.vertical ||
        (widget.layoutMode == null &&
            screenWidth < KanbanBoard._mobileBreakpoint);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: useVerticalLayout
          ? _buildMobileLayout(theme)
          : _buildHorizontalLayout(theme),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final Function(String title, String subtitle) onAdd;

  const _AddItemDialog({
    required this.onAdd,
  });

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _subtitleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    try {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() {
          _isSubmitting = true;
          _hasError = false;
        });

        // Trim whitespace from inputs
        final title = _titleController.text.trim();
        final subtitle = _subtitleController.text.trim();

        // Additional validation
        if (title.length > 100) {
          _showError('Title must be less than 100 characters');
          return;
        }

        if (subtitle.length > 500) {
          _showError('Description must be less than 500 characters');
          return;
        }

        // Unfocus before submitting to prevent keyboard issues
        FocusManager.instance.primaryFocus?.unfocus();

        try {
          widget.onAdd(title, subtitle);
          Navigator.of(context).pop();
        } catch (e) {
          _showError('Failed to add item. Please try again.');
        }
      }
    } catch (e) {
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _hasError = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: Dialog(
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600.0,
            minWidth: 400.0,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add New Item',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24.0),
                SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            hintText: 'Enter item title',
                            errorMaxLines: 2,
                            helperText: 'Required, max 100 characters',
                            helperMaxLines: 2,
                            errorStyle: const TextStyle(color: Colors.red),
                            filled: true,
                            border: const OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          autofocus: true,
                          enabled: !_isSubmitting,
                          maxLength: 100,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a title';
                            }
                            if (value.length > 100) {
                              return 'Title must be less than 100 characters';
                            }
                            return null;
                          },
                          onChanged: (_) {
                            if (_hasError) {
                              setState(() => _hasError = false);
                            }
                          },
                        ),
                        const SizedBox(height: 24.0),
                        TextFormField(
                          controller: _subtitleController,
                          decoration: InputDecoration(
                            labelText: 'Subtitle',
                            hintText: 'Brief description or link to task',
                            errorMaxLines: 2,
                            helperText: 'Optional, max 200 characters',
                            helperMaxLines: 2,
                            errorStyle: const TextStyle(color: Colors.red),
                            filled: true,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.short_text),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _subtitleController.text.isEmpty
                                  ? null
                                  : () => setState(
                                      () => _subtitleController.clear()),
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          enabled: !_isSubmitting,
                          maxLength: 200,
                          maxLines: 1,
                          onFieldSubmitted: (_) => _handleSubmit(),
                          onChanged: (value) {
                            if (_hasError) {
                              setState(() => _hasError = false);
                            }
                            // Force a rebuild to update the clear button state
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.of(context).pop();
                            },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16.0),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
