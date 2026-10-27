/// Extension to convert English numbers to Bengali numerals
extension BengaliNumberExtension on num {
  String toBengaliDigits() {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

    String str = toString();
    for (int i = 0; i < englishDigits.length; i++) {
      str = str.replaceAll(englishDigits[i], bengaliDigits[i]);
    }
    return str;
  }

  /// Converts number to Bengali numerals with comma separators (e.g. 1500 -> ১,৫০০)
  String toBengaliDigitsWithComma() {
    final intVal = toInt();
    final parts = intVal.abs().toString();

    String formatted;
    if (parts.length <= 3) {
      formatted = parts;
    } else {
      final lastThree = parts.substring(parts.length - 3);
      final remaining = parts.substring(0, parts.length - 3);
      final regExp = RegExp(r'\B(?=(\d{2})+(?!\d))');
      formatted = '${remaining.replaceAll(regExp, ',')},$lastThree';
    }

    if (intVal < 0) {
      formatted = '-$formatted';
    }

    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

    for (int i = 0; i < englishDigits.length; i++) {
      formatted = formatted.replaceAll(englishDigits[i], bengaliDigits[i]);
    }
    return formatted;
  }
}

