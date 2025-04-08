import 'package:flutter/material.dart';
import 'package:abstractify/models/ocr_modes.dart';

class OcrToggleSection extends StatelessWidget {
  final OcrMode selectedOcrMode;
  final void Function(OcrMode) onOcrModeChanged;

  final SegmentationMode selectedSegmentationMode;
  final void Function(SegmentationMode) onSegmentationChanged;

  final PageType selectedPageType;
  final void Function(PageType) onPageTypeChanged;

  const OcrToggleSection({
    super.key,
    required this.selectedOcrMode,
    required this.onOcrModeChanged,
    required this.selectedSegmentationMode,
    required this.onSegmentationChanged,
    required this.selectedPageType,
    required this.onPageTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabeledToggle<OcrMode>(
            label: "OCR Mode:",
            values: OcrMode.values,
            selectedValue: selectedOcrMode,
            labelBuilder: (mode) =>
            mode == OcrMode.typed ? "Typed" : "Hand",
            onChanged: onOcrModeChanged,
          ),
          if (selectedOcrMode == OcrMode.handwritten) ...[
            const SizedBox(height: 15),
            _buildLabeledToggle<SegmentationMode>(
              label: "Segmentation:",
              values: SegmentationMode.values,
              selectedValue: selectedSegmentationMode,
              labelBuilder: (mode) =>
              mode == SegmentationMode.automatic ? "Auto" : "Manual",
              onChanged: onSegmentationChanged,
            ),
            const SizedBox(height: 15),
            _buildLabeledToggle<PageType>(
              label: "Page Type:",
              values: PageType.values,
              selectedValue: selectedPageType,
              labelBuilder: (type) =>
              type == PageType.ruled ? "Ruled" : "Plain",
              onChanged: onPageTypeChanged,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabeledToggle<T>({
    required String label,
    required List<T> values,
    required T selectedValue,
    required String Function(T) labelBuilder,
    required void Function(T) onChanged,
  }) {
    return Row(
      children: [
        Text(label),
        Spacer(),
        ToggleButtons(
          isSelected: values.map((v) => v == selectedValue).toList(),
          onPressed: (index) => onChanged(values[index]),
          borderRadius: BorderRadius.circular(8),
          selectedColor: Colors.white,
          fillColor: Colors.blue,
          color: Colors.black,
          constraints: const BoxConstraints(minWidth: 70, minHeight: 30),
          children: values.map((v) => Text(labelBuilder(v))).toList(),
        ),
      ],
    );
  }
}
