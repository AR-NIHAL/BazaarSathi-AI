import 'package:flutter_test/flutter_test.dart';
import 'package:bazaar_sathi_ai/data/services/gemini_service.dart';

void main() {
  group('GeminiService JSON Parsing & Sanitization Tests', () {
    test('Correctly decodes clean JSON array with estimatedPrice', () {
      const raw =
          '[{"itemName": "আলু", "quantity": "২ কেজি", "category": "সবজি", "estimatedPrice": 100}]';
      final result = GeminiService.extractAndDecodeJson(raw);

      expect(result.length, 1);
      expect(result[0]['itemName'], 'আলু');
      expect(result[0]['quantity'], '২ কেজি');
      expect(result[0]['category'], 'সবজি');
      expect(result[0]['estimatedPrice'], 100);
    });

    test('Correctly strips markdown code fences (```json ... ```)', () {
      const raw = '''
```json
[
  {"itemName": "মুরগির মাংস", "quantity": "১ কেজি", "category": "মাছ-মাংস", "estimatedPrice": 320},
  {"itemName": "সয়াবিন তেল", "quantity": "২ লিটার", "category": "মুদি মাল", "estimatedPrice": 340}
]
```
''';
      final result = GeminiService.extractAndDecodeJson(raw);

      expect(result.length, 2);
      expect(result[0]['itemName'], 'মুরগির মাংস');
      expect(result[0]['estimatedPrice'], 320);
      expect(result[1]['itemName'], 'সয়াবিন তেল');
      expect(result[1]['estimatedPrice'], 340);
    });

    test('Extracts JSON array embedded inside conversational text', () {
      const raw = '''
Here is the extracted list of items:
[
  {"itemName": "আপেল", "quantity": "১ কেজি", "category": "ফল", "estimatedPrice": 250}
]
Hope this helps with your bazaar!
''';
      final result = GeminiService.extractAndDecodeJson(raw);

      expect(result.length, 1);
      expect(result[0]['itemName'], 'আপেল');
      expect(result[0]['category'], 'ফল');
      expect(result[0]['estimatedPrice'], 250);
    });

    test('Gracefully handles malformed JSON without crashing', () {
      const raw = 'This is not json at all';
      final result = GeminiService.extractAndDecodeJson(raw);

      expect(result, isEmpty);
    });

    test('Handles missing keys by applying sensible fallback defaults', () {
      const raw = '[{"itemName": "পটল"}]';
      final result = GeminiService.extractAndDecodeJson(raw);

      expect(result.length, 1);
      expect(result[0]['itemName'], 'পটল');
      expect(result[0]['quantity'], '১ টি');
      expect(result[0]['category'], 'অন্যান্য');
      expect(result[0]['estimatedPrice'], isNull);
    });
  });
}
