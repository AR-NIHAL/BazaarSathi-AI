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
}
