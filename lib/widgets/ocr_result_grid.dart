import 'package:flutter/material.dart';
import 'package:abstractify/widgets/ocr_result_card.dart';
import 'package:abstractify/models/ocr_result_model.dart';

class OcrResultGrid extends StatelessWidget {
  final List<OcrResult> ocrResults;
  final void Function(String filename, String newText) onTextUpdated;

  const OcrResultGrid({
    super.key,
    required this.ocrResults,
    required this.onTextUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (ocrResults.isEmpty) {
      return const Center(
        child: Text("No OCR results to show 🫠"),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: ocrResults.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final result = ocrResults[index];
        return OcrResultCard(
          result: result,
          onTextUpdated: (newText) => onTextUpdated(result.filename, newText),
        );
      },
    );
  }
}
