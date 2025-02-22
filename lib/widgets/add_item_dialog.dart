import 'package:flutter/material.dart';

class AddItemDialog extends StatefulWidget {
  final Function(String title, String subtitle) onAdd;

  const AddItemDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddItemDialog> createState() => AddItemDialogState();
}

class AddItemDialogState extends State<AddItemDialog> {
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
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            hintText: 'Enter item title',
                            errorMaxLines: 2,
                            helperText: 'Required, max 100 characters',
                            helperMaxLines: 2,
                            errorStyle: TextStyle(color: Colors.red),
                            filled: true,
                            border: OutlineInputBorder(),
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
