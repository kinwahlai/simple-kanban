import 'package:flutter/material.dart';
import '../models/kanban_item.dart';
import '../models/kanban_column.dart' as models;
import 'kanban_board.dart';
import 'kanban_card.dart';

class KanbanColumnWidget extends StatefulWidget {
  final models.KanbanColumn column;
  final List<KanbanItem> items;

  /// Callback for adding new items. If null, the column won't support adding items.
  /// This should be null for columns that shouldn't allow new items to be added.
  final Function(String title, String subtitle)? onAddItem;
  final Function(String, String) onMoveToColumn;
  final Function(String, int) onReorderItem;
  final bool canMoveLeft;
  final bool canMoveRight;
  final bool targetLeftHasSpace;
  final bool targetRightHasSpace;
  final KanbanBoardTheme theme;
  final bool hideHeader;

  const KanbanColumnWidget({
    super.key,
    required this.column,
    required this.items,
    this.onAddItem,
    required this.onMoveToColumn,
    required this.onReorderItem,
    required this.canMoveLeft,
    required this.canMoveRight,
    required this.targetLeftHasSpace,
    required this.targetRightHasSpace,
    required this.theme,
    this.hideHeader = false,
  });

  @override
  State<KanbanColumnWidget> createState() => _KanbanColumnWidgetState();
}

class _KanbanColumnWidgetState extends State<KanbanColumnWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.theme.columnColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: widget.theme.cardBorderColor.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          if (!widget.hideHeader) _buildHeader(),
          Expanded(
            child: _buildItemList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 64.0,
      decoration: BoxDecoration(
        color: widget.theme.headerColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title and count grouped together
          Row(
            children: [
              Text(
                widget.column.title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: widget.theme.headerTextColor,
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: widget.theme.columnColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  widget.column.limit != null
                      ? '${widget.items.length}/${widget.column.limit}'
                      : '${widget.items.length}',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: widget.theme.countTextColor,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          if (widget.onAddItem != null)
            Container(
              height: 32.0,
              width: 32.0,
              decoration: BoxDecoration(
                color: widget.column.canAddItem()
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: IconButton(
                icon: const Icon(Icons.add_rounded, size: 20.0),
                padding: EdgeInsets.zero,
                color: widget.column.canAddItem()
                    ? Colors.white
                    : Colors.grey.shade500,
                tooltip: widget.column.canAddItem()
                    ? 'Add New Item'
                    : 'Column is at capacity',
                onPressed:
                    widget.column.canAddItem() ? _showAddItemDialog : null,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showAddItemDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => _AddItemDialog(
        onAdd: (title, subtitle) {
          widget.onAddItem?.call(title, subtitle);
        },
      ),
    );
  }

  Widget _buildItemList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return _buildDraggableItem(item, index);
      },
    );
  }

  Widget _buildDraggableItem(KanbanItem item, int index) {
    return DragTarget<String>(
      onWillAccept: (data) {
        // Only accept items from the same column
        return data != null && widget.column.itemIds.contains(data);
      },
      onAccept: (data) {
        final draggedIndex = widget.items.indexWhere((item) => item.id == data);
        if (draggedIndex != -1 && draggedIndex != index) {
          widget.onReorderItem(data, index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: KanbanCard(
            item: item,
            backgroundColor: widget.theme.cardColor,
            borderColor: widget.theme.cardBorderColor,
            titleColor: widget.theme.cardTitleColor,
            subtitleColor: widget.theme.cardSubtitleColor,
            onMoveLeft: widget.canMoveLeft && widget.targetLeftHasSpace
                ? () => widget.onMoveToColumn(item.id, 'left')
                : null,
            onMoveRight: widget.canMoveRight && widget.targetRightHasSpace
                ? () => widget.onMoveToColumn(item.id, 'right')
                : null,
          ),
        );
      },
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
