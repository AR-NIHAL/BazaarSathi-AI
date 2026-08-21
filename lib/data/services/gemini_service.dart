import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String _apiKey;
  late final GenerativeModel _model;

  GeminiService({String? apiKey})
      : _apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      debugPrint("Warning: Gemini API Key is empty. Please check your .env file.");
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  /// Parses raw text into a structured list of bazaar items with estimated prices
  Future<List<Map<String, dynamic>>> parseBazaarList(String rawText) async {
    if (rawText.trim().isEmpty) return [];

    final prompt = """
You are a strict Bangladeshi Bazaar Assistant with price estimation knowledge. 
Extract shopping items from raw text (Bangla, Banglish, or English) and convert them into a structured JSON array.

Rules:
1. Return ONLY a valid JSON array of objects.
2. Each object MUST contain these exact keys:
   - "itemName": Name of the item in Bengali (e.g., "আলু", "সয়াবিন তেল")
   - "quantity": Normalized Bengali quantity with unit (e.g., "২ কেজি", "১ লিটার", "৫০০ গ্রাম", "১ ডজন", "৪ টি")
   - "category": Must be one of: "সবজি", "মাছ-মাংস", "মুদি মাল", "ফল", "অন্যান্য"
   - "estimatedPrice": Estimated total price in Bangladeshi Taka (integer digits, e.g. 100, 320, 50) based on typical retail prices in Bangladesh.
3. Convert all spoken/written numbers into Bengali digits (e.g., "two kg" -> "২ কেজি", "আধা কেজি" -> "৫০০ গ্রাম" or "০.৫ কেজি").

Example Input: "দুই কেজি আলু আর ৫০০ গ্রাম মুরগির মাংস আর এক ডজন ডিম"
Example Output: [
  {"itemName": "আলু", "quantity": "২ কেজি", "category": "সবজি", "estimatedPrice": 100},
  {"itemName": "মুরগির মাংস", "quantity": "৫০০ গ্রাম", "category": "মাছ-মাংস", "estimatedPrice": 160},
  {"itemName": "ডিম", "quantity": "১ ডজন", "category": "মুদি মাল", "estimatedPrice": 150}
]

Now process this text: "$rawText"
""";

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final rawResponse = response.text?.trim() ?? "";

      return extractAndDecodeJson(rawResponse);
    } catch (e) {
      debugPrint("Gemini Error: $e");
      return [];
    }
  }

  /// Parses a photo/image of a handwritten or printed bazaar list using Gemini Multimodal Vision
  Future<List<Map<String, dynamic>>> parseBazaarImage(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    if (imageBytes.isEmpty) return [];

    final prompt = """
You are a strict Bangladeshi Bazaar Assistant with Multimodal Vision OCR capabilities and price estimation.
Analyze this image (handwritten Bengali/English paper bazaar list, memo, or receipt) and extract all shopping items, quantities, and realistic estimated prices into a structured JSON array.

Rules:
1. Return ONLY a valid JSON array of objects.
2. Each object MUST contain these exact keys:
   - "itemName": Name of the item in Bengali (e.g., "আলু", "সয়াবিন তেল", "মুরগি")
   - "quantity": Normalized Bengali quantity with unit (e.g., "২ কেজি", "১ লিটার", "৫০০ গ্রাম", "১ ডজন", "৪ টি")
   - "category": Must be one of: "সবজি", "মাছ-মাংস", "মুদি মাল", "ফল", "অন্যান্য"
   - "estimatedPrice": Estimated total price in Bangladeshi Taka (integer digits, e.g. 100, 320, 50).
3. Convert all numbers to Bengali digits (e.g., "২ কেজি", "১.৫ কেজি").

Example Output: [
  {"itemName": "আলু", "quantity": "২ কেজি", "category": "সবজি", "estimatedPrice": 100},
  {"itemName": "মুরগির মাংস", "quantity": "১ কেজি", "category": "মাছ-মাংস", "estimatedPrice": 320},
  {"itemName": "সয়াবিন তেল", "quantity": "২ লিটার", "category": "মুদি মাল", "estimatedPrice": 340}
]
""";

    try {
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, imageBytes),
        ]),
      ];

      final response = await _model.generateContent(content);
      final rawResponse = response.text?.trim() ?? "";

      return extractAndDecodeJson(rawResponse);
    } catch (e) {
      debugPrint("Gemini Vision OCR Error: $e");
      return [];
    }
  }

  /// Generates a complete bazaar shopping list for a given recipe or meal name
  Future<List<Map<String, dynamic>>> generateRecipeBazaarList(
    String dishName, {
    int personCount = 4,
  }) async {
    final prompt = """
You are an expert Bangladeshi Chef and Bazaar Assistant.
Generate a complete grocery shopping list of ingredients needed to cook: "$dishName" for $personCount people in Bangladesh.

Rules:
1. Return ONLY a valid JSON array of objects.
2. Include all necessary meat/fish, vegetables, spices, oil, and staples.
3. Each object MUST contain these exact keys:
   - "itemName": Name in Bengali (e.g., "পোলাও চাল", "গরুর মাংস", "পেঁয়াজ", "এলাচ")
   - "quantity": Proportional quantity in Bengali with unit (e.g., "১ কেজি", "২৫০ গ্রাম", "৪ টি")
   - "category": Must be one of: "সবজি", "মাছ-মাংস", "মুদি মাল", "ফল", "অন্যান্য"
   - "estimatedPrice": Estimated price in Bangladeshi Taka (integer digits).
4. Keep numbers in Bengali digits.
""";

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final rawResponse = response.text?.trim() ?? "";

      return extractAndDecodeJson(rawResponse);
    } catch (e) {
      debugPrint("Gemini Recipe Error: $e");
      return [];
    }
  }

  /// Cleans markdown code fences, comments, and extracts JSON array safely
  @visibleForTesting
  static List<Map<String, dynamic>> extractAndDecodeJson(String text) {
    if (text.isEmpty) return [];

    try {
      // Step 1: Remove markdown code block fences (e.g. ```json ... ```)
      String cleaned = text;
      if (cleaned.contains("```")) {
        cleaned = cleaned
            .replaceAll(RegExp(r'```(?:json)?\n?'), '')
            .replaceAll('```', '')
            .trim();
      }

      // Step 2: Extract the array portion between the first '[' and last ']'
      final startIndex = cleaned.indexOf('[');
      final endIndex = cleaned.lastIndexOf(']');
      if (startIndex != -1 && endIndex != -1 && endIndex >= startIndex) {
        cleaned = cleaned.substring(startIndex, endIndex + 1).trim();
      }

      // Step 3: Decode JSON
      final dynamic decoded = jsonDecode(cleaned);
      if (decoded is! List) return [];

      // Step 4: Validate and normalize items
      final List<Map<String, dynamic>> items = [];
      for (final item in decoded) {
        if (item is Map) {
          int? price;
          if (item["estimatedPrice"] != null) {
            price = item["estimatedPrice"] is num
                ? (item["estimatedPrice"] as num).round()
                : int.tryParse(item["estimatedPrice"].toString());
          }

          items.add({
            "itemName": item["itemName"]?.toString().trim() ?? "অজানা আইটেম",
            "quantity": item["quantity"]?.toString().trim() ?? "১ টি",
            "category": item["category"]?.toString().trim() ?? "অন্যান্য",
            "estimatedPrice": price,
          });
        }
      }

      return items;
    } catch (e) {
      debugPrint("JSON Extraction/Decoding Error: $e\nRaw Text: $text");
      return [];
    }
  }
}
