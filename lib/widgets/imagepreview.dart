import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:path/path.dart' as p;

class ImagePreviewModal extends StatefulWidget {
  final List<String> imagePaths;

  const ImagePreviewModal({super.key, required this.imagePaths});

  @override
  State<ImagePreviewModal> createState() => _ImagePreviewModalState();
}

class _ImagePreviewModalState extends State<ImagePreviewModal> {
  final Map<String, Size> _sizeCache = {};
  final Map<String, String> _sizeFormatCache = {};

  @override
  void dispose() {
    _sizeCache.clear();
    _sizeFormatCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: screenSize.width * 0.8,
        height: screenSize.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Selected Images',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount =
                      (constraints.maxWidth ~/ 200).clamp(1, 4);

                  return GridView.builder(
                    cacheExtent: 500,
                    itemCount: widget.imagePaths.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final path = widget.imagePaths[index];
                      return _ImageTile(
                        path: path,
                        sizeCache: _sizeCache,
                        sizeFormatCache: _sizeFormatCache,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final String path;
  final Map<String, Size> sizeCache;
  final Map<String, String> sizeFormatCache;

  const _ImageTile({
    required this.path,
    required this.sizeCache,
    required this.sizeFormatCache,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = p.basename(path);
    final file = File(path);
    final fileSizeKB = file.lengthSync() / 1024;
    final formattedSize = sizeFormatCache[path] ?? _formatFileSize(fileSizeKB);

    if (!sizeFormatCache.containsKey(path)) {
      sizeFormatCache[path] = formattedSize;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.file(
                file,
                fit: BoxFit.cover,
                cacheWidth: 400,
                filterQuality: FilterQuality.medium,
                isAntiAlias: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              fileName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 6, right: 6),
            child: _SizeProvider(
              path: path,
              sizeCache: sizeCache,
              formattedSize: formattedSize,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(double kb) {
    // Fixed method name consistency
    return kb > 1024
        ? '${(kb / 1024).toStringAsFixed(1)} MB'
        : '${kb.toStringAsFixed(1)} KB';
  }
}

class _SizeProvider extends StatelessWidget {
  final String path;
  final Map<String, Size> sizeCache;
  final String formattedSize;

  const _SizeProvider({
    required this.path,
    required this.sizeCache,
    required this.formattedSize,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Size>(
      future: _getImageSize(path),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final size = snapshot.data ?? Size.zero;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${size.width.toInt()} x ${size.height.toInt()}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                formattedSize,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          );
        }
        return const Text(
          'Loading...',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        );
      },
    );
  }

  Future<Size> _getImageSize(String path) async {
    if (sizeCache.containsKey(path)) return sizeCache[path]!;

    try {
      final file = File(path);
      // Use correct input type and proper async handling
      final sizeResult = ImageSizeGetter.getSizeResult(FileInput(file));
      final size = sizeResult.size;
      final dimensions = Size(size.width, size.height);
      sizeCache[path] = dimensions;
      return dimensions;
    } catch (e) {
      return Size.zero;
    }
  }
}
