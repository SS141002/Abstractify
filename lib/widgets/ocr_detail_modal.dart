import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:abstractify/models/ocr_result_model.dart'; // adjust path if needed

class OcrDetailModal extends StatefulWidget {
  final String tag;
  final OcrResult result;
  final ValueChanged<String> onTextUpdated;

  const OcrDetailModal({
    super.key,
    required this.tag,
    required this.result,
    required this.onTextUpdated,
  });

  @override
  State<OcrDetailModal> createState() => _OcrDetailModalState();
}

class _OcrDetailModalState extends State<OcrDetailModal> {
  late TextEditingController _controller;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.result.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      if (isEditing) {
        // Call update callback when editing ends
        widget.onTextUpdated(_controller.text);
      }
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        body: Center(
          child: GestureDetector(
            onTap: () {},
            child: Hero(
              tag: widget.tag,
              child: Material(
                color: theme.colorScheme.surface,
                elevation: 16,
                borderRadius: BorderRadius.circular(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.result.filename,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: TextField(
                              controller: _controller,
                              readOnly: !isEditing,
                              maxLines: null,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                filled: true,
                                fillColor: isEditing
                                    ? theme.colorScheme.surfaceVariant
                                        .withOpacity(0.3)
                                    : Colors.transparent,
                              ),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              tooltip: "Copy Text",
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: _controller.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Copied to clipboard!')),
                                );
                              },
                            ),
                            IconButton(
                              tooltip: isEditing ? "Done Editing" : "Edit Text",
                              icon: Icon(isEditing ? Icons.check : Icons.edit),
                              onPressed: _toggleEditMode,
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Close"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
