import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abstractify/models/ocr_result_model.dart';
import 'package:abstractify/widgets/imagepreview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:abstractify/providers/ocr_result_provider.dart';

class DropZoneWidget extends ConsumerStatefulWidget {
  final List<String> supportedExtensions;

  const DropZoneWidget({
    super.key,
    this.supportedExtensions = const ['.jpg', '.jpeg', '.png', '.webp'],
  });

  @override
  ConsumerState<DropZoneWidget> createState() => _DropZoneWidgetState();
}

class _DropZoneWidgetState extends ConsumerState<DropZoneWidget> {
  bool _isHighlighted = false;
  bool _isProcessing = false;

  Future<void> _handleFiles(List<String> paths) async {
    try {
      setState(() => _isProcessing = true);
      final validFiles = await _filterValidFiles(paths);
      if (validFiles.isEmpty) return;

      final notifier = ref.read(ocrResultsProvider.notifier);
      notifier.addAll(validFiles.map((path) => OcrResult(path: path)).toList());
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<List<String>> _filterValidFiles(List<String> paths) async {
    final validFiles = <String>[];

    await Future.wait(paths.map((path) async {
      try {
        final file = File(path);
        final stat = await file.stat();

        if (await file.exists() &&
            stat.type == FileSystemEntityType.file &&
            widget.supportedExtensions.any((ext) =>
                p.extension(path).toLowerCase() == ext.toLowerCase())) {
          validFiles.add(path);
        }
      } catch (_) {}
    }));

    return validFiles;
  }

  Future<void> _selectFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      allowedExtensions: widget.supportedExtensions
          .map((ext) => ext.replaceAll('.', ''))
          .toList(),
    );

    if (result != null) {
      await _handleFiles(result.paths.whereType<String>().toList());
    }
  }

  Future<void> _selectFolder() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;

    final completer = Completer<void>();
    final stream = Directory(selectedDirectory).list(recursive: true);
    final validFiles = <String>[];

    stream.listen(
      (entity) {
        if (entity is File &&
            widget.supportedExtensions.any((ext) =>
                p.extension(entity.path).toLowerCase() == ext.toLowerCase())) {
          validFiles.add(entity.path);
        }
      },
      onDone: () {
        _handleFiles(validFiles);
        completer.complete();
      },
      onError: (e) => print('Error listing files: $e'),
    );

    return completer.future;
  }

  void _clearSelection() {
    ref.read(ocrResultsProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final ocrResults = ref.watch(ocrResultsProvider);

    return SizedBox(
      height: 160,
      child: DropTarget(
        onDragEntered: (_) => setState(() => _isHighlighted = true),
        onDragExited: (_) => setState(() => _isHighlighted = false),
        onDragDone: (details) => _handleFiles(
          details.files.map((f) => f.path).toList(),
        ),
        child: AbsorbPointer(
          absorbing: _isProcessing,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isHighlighted ? Colors.blue : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: _isHighlighted
                  ? Colors.blue.withValues(alpha: 50)
                  : Colors.transparent,
            ),
            child: _buildContent(ocrResults),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, OcrResult> ocrResults) {
    return GestureDetector(
      onTap: _selectFiles,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: _buildMainContent(ocrResults),
            ),
            const SizedBox(width: 12),
            _buildActionButtons(ocrResults),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(Map<String, OcrResult> ocrResults) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isProcessing)
          const CircularProgressIndicator()
        else
          Icon(
            Icons.cloud_upload,
            size: 50,
            color: _isHighlighted ? Colors.blue : Colors.grey,
          ),
        const SizedBox(height: 8),
        ocrResults.isEmpty
            ? Text(
                _isProcessing ? "Processing files..." : "Drop images or click",
                style: Theme.of(context).textTheme.bodyMedium,
              )
            : Text(
                "${ocrResults.length} files selected",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, OcrResult> ocrResults) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(
          icon: Icons.folder_open,
          tooltip: "Select folder",
          onPressed: _selectFolder,
        ),
        _buildIconButton(
          icon: Icons.image,
          tooltip: "Preview images",
          onPressed: ocrResults.isNotEmpty
              ? () => showDialog(
                    context: context,
                    builder: (_) => ImagePreviewModal(),
                  )
              : null,
        ),
        _buildIconButton(
          icon: Icons.clear,
          tooltip: "Clear selection",
          onPressed: ocrResults.isNotEmpty ? _clearSelection : null,
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 24),
      tooltip: tooltip,
      onPressed: onPressed,
      splashRadius: 16,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
}
