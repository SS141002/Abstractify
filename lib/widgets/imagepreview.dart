import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abstractify/models/ocr_result_model.dart';
import 'package:abstractify/providers/ocr_result_provider.dart';

class ImagePreviewModal extends ConsumerWidget {
  const ImagePreviewModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(ocrResultsProvider);

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
                      (constraints.maxWidth ~/ 200).clamp(1, 6);

                  final entries = results.entries.toList();

                  return GridView.builder(
                    itemCount: entries.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final result = entries[index].value;
                      return _ImageTile(result: result);
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
  final OcrResult result;

  const _ImageTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final fileName = result.filename;
    final width = result.width;
    final height = result.height;
    final fileSize = result.size;

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
                File(result.path),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$width x $height",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  fileSize,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
