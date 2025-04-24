import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abstractify/providers/ocr_result_provider.dart'; // Import your provider
import 'package:abstractify/widgets/ocr_result_card.dart';

class OcrResultGrid extends ConsumerWidget {
  const OcrResultGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(ocrResultsProvider).values.toList();

    if (results.isEmpty) {
      return const Center(
        child: Text("No OCR results to show 🫠"),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: results.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final result = results[index];
        return OcrResultCard(result: result);
      },
    );
  }
}
