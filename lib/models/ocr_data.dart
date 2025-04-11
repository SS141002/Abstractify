enum OcrMode { typed, handwritten }

enum SegmentationMode { automatic, manual }

enum PageType { ruled, plain }

enum SupportedLanguage {
  english,
  hindi,
  french,
  spanish,
  german,
  japanese,
  chinese,
  arabic,
  russian,
}

extension SupportedLanguageExtension on SupportedLanguage {
  /// Human-friendly label (for UI)
  String get label {
    switch (this) {
      case SupportedLanguage.english:
        return "English";
      case SupportedLanguage.hindi:
        return "Hindi";
      case SupportedLanguage.french:
        return "French";
      case SupportedLanguage.spanish:
        return "Spanish";
      case SupportedLanguage.german:
        return "German";
      case SupportedLanguage.japanese:
        return "Japanese";
      case SupportedLanguage.chinese:
        return "Chinese";
      case SupportedLanguage.arabic:
        return "Arabic";
      case SupportedLanguage.russian:
        return "Russian";
    }
  }

  /// EasyOCR-compatible language code
  String get code {
    switch (this) {
      case SupportedLanguage.english:
        return "en";
      case SupportedLanguage.hindi:
        return "hi";
      case SupportedLanguage.french:
        return "fr";
      case SupportedLanguage.spanish:
        return "es";
      case SupportedLanguage.german:
        return "de";
      case SupportedLanguage.japanese:
        return "ja";
      case SupportedLanguage.chinese:
        return "ch_sim"; // OR "ch_tra" for Traditional Chinese
      case SupportedLanguage.arabic:
        return "ar";
      case SupportedLanguage.russian:
        return "ru";
    }
  }

  static SupportedLanguage? fromLabel(String label) {
    try {
      return SupportedLanguage.values.firstWhere(
        (lang) => lang.label == label,
      );
    } catch (e) {
      return null;
    }
  }
}
