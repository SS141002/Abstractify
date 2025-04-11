class OcrResult {
  final String filename;
  final String text;

  OcrResult({
    required this.filename,
    required this.text,
  });

  // Helper to create an instance from JSON
  factory OcrResult.fromJson(MapEntry<String, dynamic> entry) {
    return OcrResult(
      filename: entry.key,
      text: entry.value.toString(),
    );
  }

  // Optional: Convert it back to JSON
  Map<String, dynamic> toJson() {
    return {
      filename: text,
    };
  }
}
