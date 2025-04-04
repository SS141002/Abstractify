import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:abstractify/widgets/imagepreview.dart';
import 'package:file_picker/file_picker.dart';

class DropZoneWidget extends StatefulWidget {
  final Function(List<String>) onFilesChanged;

  const DropZoneWidget({super.key, required this.onFilesChanged});

  @override
  DropZoneWidgetState createState() => DropZoneWidgetState();
}

class DropZoneWidgetState extends State<DropZoneWidget> {
  bool isHighlighted = false;
  Set<String> selectedFiles = {}; // Stores file URIs

  // Handle files dropped into the zone
  void _handleFilesDropped(List<String> files) {
    setState(() {
      selectedFiles.addAll(files);
    });
    widget.onFilesChanged(selectedFiles.toList()); // Notify parent
  }

  // Handle file selection using File Picker
  Future<void> _selectFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
    if (result != null) {
      _handleFilesDropped(result.paths.whereType<String>().toList());
    }
  }

  // Handle folder selection (counts all files inside)
  Future<void> _selectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return; // User cancelled

    final directory = Directory(selectedDirectory);
    final imageExtensions = ['.jpg', '.jpeg', '.png'];

    final files = directory
        .listSync(recursive: false)
        .whereType<File>()
        .where((file) =>
            imageExtensions.contains(p.extension(file.path).toLowerCase()))
        .toList();

    setState(() {
      selectedFiles.addAll(files.map((f) => f.path));
    });
    widget.onFilesChanged(selectedFiles.toList());
  }

  // Clear all selected files
  void _clearSelection() {
    setState(() {
      selectedFiles.clear();
    });
    widget.onFilesChanged([]); // Notify parent
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: DropTarget(
        onDragEntered: (details) {
          setState(() => isHighlighted = true);
        },
        onDragExited: (details) {
          setState(() => isHighlighted = false);
        },
        onDragDone: (details) {
          setState(() {
            selectedFiles.addAll(details.files.map((file) => file.path));
            isHighlighted = false;
          });
          widget.onFilesChanged(selectedFiles.toList()); // update parent
        },
        child: GestureDetector(
          onTap: _selectFiles,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isHighlighted ? Colors.blue : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(12),
              //color: Colors.white,
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload,
                          size: 50, color: Colors.grey),
                      const SizedBox(height: 8),
                      selectedFiles.isEmpty
                          ? const Text(
                              "Drop images here or click to select",
                              style: TextStyle(fontSize: 14),
                            )
                          : Text(
                              "${selectedFiles.length} file(s) selected",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      tooltip: "Select Folder",
                      icon: const Icon(Icons.folder_open),
                      onPressed: _selectFolder,
                    ),
                    IconButton(
                      tooltip: "Preview Images",
                      icon: const Icon(Icons.image),
                      onPressed: selectedFiles.isEmpty
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (_) => ImagePreviewModal(
                                  imagePaths: selectedFiles.toList(),
                                ),
                              );
                            },
                    ),
                    IconButton(
                      tooltip: "Clear Selection",
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSelection,
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
