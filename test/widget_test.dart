import 'package:flutter_test/flutter_test.dart';
import 'package:bazaar_sathi_ai/data/models/bazaar_item.dart';

void main() {
  group('BazaarItem Model Tests', () {
    test('BazaarItem initializes with default values', () {
      final item = BazaarItem(
        id: '1',
        itemName: 'টমেটো',
        quantity: '১ কেজি',
        category: 'সবজি',
      );

      expect(item.id, '1');
      expect(item.itemName, 'টমেটো');
      expect(item.quantity, '১ কেজি');
      expect(item.category, 'সবজি');
      expect(item.isChecked, false);
    });

    test('BazaarItem.fromJson deserializes correctly', () {
      final json = {
        'id': '101',
        'itemName': 'রুই মাছ',
        'quantity': '২ কেজি',
        'category': 'মাছ-মাংস',
      };

      final item = BazaarItem.fromJson(json);
      expect(item.id, '101');
      expect(item.itemName, 'রুই মাছ');
      expect(item.quantity, '২ কেজি');
      expect(item.category, 'মাছ-মাংস');
      expect(item.isChecked, false);
    });
  });
}
