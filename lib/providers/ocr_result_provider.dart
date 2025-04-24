import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abstractify/models/ocr_result_model.dart';

final ocrResultsProvider =
    StateNotifierProvider<OcrResultNotifier, Map<String, OcrResult>>(
  (ref) => OcrResultNotifier(),
);

class OcrResultNotifier extends StateNotifier<Map<String, OcrResult>> {
  OcrResultNotifier() : super({});

  // Getter for easy access to the list of results
  List<OcrResult> get ocrResults => state.values.toList();

  // Get the total number of stored objects
  int get count => state.length;

  // Add a single OcrResult using UUID as key
  void add(OcrResult item) {
    if (!state.containsKey(item.uuid)) {
      state = {...state, item.uuid: item};
    }
  }

  // Add multiple OcrResults with UUID-based deduplication
  void addAll(List<OcrResult> items) {
    final newMap = Map<String, OcrResult>.from(state);
    for (final item in items) {
      if (!newMap.containsKey(item.uuid)) {
        newMap[item.uuid] = item;
      }
    }
    state = newMap;
  }

  // Remove an item by UUID
  void delete(String uuid) {
    final newMap = Map<String, OcrResult>.from(state);
    newMap.remove(uuid);
    state = newMap;
  }

  // Clear all items
  void clear() {
    state = {};
  }

  // Check if a UUID exists
  bool contains(String uuid) => state.containsKey(uuid);

  // Get an item by UUID
  OcrResult? get(String uuid) => state[uuid];

  // Update the text of an existing OcrResult by UUID
  void updateText(String uuid, String newText) {
    if (state.containsKey(uuid)) {
      final updated = state[uuid]!.changeText(text: newText);
      state = {
        ...state,
        uuid: updated,
      };
    }
  }

  // Get the minimum width among all images
  int get minWidth {
    if (state.isEmpty) return 2;
    return state.values.map((e) => e.width).reduce((a, b) => a < b ? a : b);
  }

// Get the minimum height among all images
  int get minHeight {
    if (state.isEmpty) return 2;
    return state.values.map((e) => e.height).reduce((a, b) => a < b ? a : b);
  }
}
