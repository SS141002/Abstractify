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
  String get label {
    switch (this) {
      case SupportedLanguage.english:
        return 'English';
      case SupportedLanguage.hindi:
        return 'Hindi';
      case SupportedLanguage.french:
        return 'French';
      case SupportedLanguage.spanish:
        return 'Spanish';
      case SupportedLanguage.german:
        return 'German';
      case SupportedLanguage.japanese:
        return 'Japanese';
      case SupportedLanguage.chinese:
        return 'Chinese';
      case SupportedLanguage.arabic:
        return 'Arabic';
      case SupportedLanguage.russian:
        return 'Russian';
    }
  }
}
