import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String _apiKey;
  late final GenerativeModel _model;
  String? lastError;

  GeminiService({String? apiKey, String modelName = 'gemini-2.5-flash'})
      : _apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      debugPrint("Warning: Gemini API Key is empty. Please check your .env file.");
    }
    _model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
    );
  }

  /// Parses raw text into a structured list of bazaar items with estimated prices
  Future<List<Map<String, dynamic>>> parseBazaarList(String rawText) async {
    lastError = null;
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
      final errStr = e.toString();
      if (errStr.contains('403') || errStr.contains('leaked')) {
        lastError = 'API Key ত্রুটি: আপনার জেমিনি এপিআই কি ব্লক বা অবৈধ। .env ফাইলে নতুন কি দিন।';
      } else if (errStr.contains('404') || errStr.contains('not found')) {
        lastError = 'মডেল পাওয়া যায়নি। অনুগ্রহ করে ইন্টারনেট ও মডেল সেটিংস চেক করুন।';
      } else if (errStr.contains('SocketException') || errStr.contains('timed out')) {
        lastError = 'ইন্টারনেট সংযোগ নেই বা টাইমআউট হয়েছে।';
      } else {
        lastError = 'এআই সেবা সংযোগ ব্যর্থ হয়েছে: $errStr';
      }
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

  /// Rule-based offline parser for Bengali and Banglish shopping phrases
  List<Map<String, dynamic>> parseBazaarListOffline(String rawText) {
    if (rawText.trim().isEmpty) return [];

    final text = rawText.trim();

    final numMap = {
      'ek': '১', 'one': '১', 'dui': '২', 'two': '২',
      'tin': '৩', 'three': '৩', 'char': '৪', 'four': '৪',
      'pach': '৫', 'paach': '৫', 'five': '৫', 'choy': '৬', 'six': '৬',
      'shat': '৭', 'sat': '৭', 'seven': '৭', 'at': '৮', 'aath': '৮', 'eight': '৮',
      'noy': '৯', 'nine': '৯', 'dosh': '১০', 'ten': '১০',
      '0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪',
      '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯',
    };

    final delimiters = RegExp(r'[,;\n]|\s+(?:এবং|আর|o|and)\s+', caseSensitive: false);
    final segments = text.split(delimiters).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    List<String> rawItems = [];
    if (segments.length == 1) {
      final itemSplitRegex = RegExp(
        r'(?:(?<=^|\s)(?=(?:\d+|[০-৯]+|ek|dui|tin|char|pach|choy|shat|at|noy|dosh|one|two|three|four|five|six|seven|eight|nine|ten|আধা|পোয়া|এক|দুই|তিন|চার|পাঁচ)\s*(?:কেজি|গ্রাম|লিটার|ডজন|টি|টা|kg|kilo|gm|gram|liter|litre|ltr|dozen|pcs?|হালি)(?=\s|$|[,\n])))',
        caseSensitive: false,
      );
      final parts = text.split(itemSplitRegex).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      rawItems = parts.isNotEmpty ? parts : segments;
    } else {
      rawItems = segments;
    }

    final List<Map<String, dynamic>> results = [];
    final unitRegex = RegExp(
      r'(\d+|[০-৯]+|(?:ek|dui|tin|char|pach|choy|shat|at|noy|dosh|one|two|three|four|five|six|seven|eight|nine|ten|আধা|পোয়া|এক|দুই|তিন|চার|পাঁচ))?\s*(কেজি|গ্রাম|লিটার|ডজন|টি|টা|kg|kilo|gm|gram|liter|litre|ltr|dozen|pcs?|হালি)?',
      caseSensitive: false,
    );

    for (final raw in rawItems) {
      if (raw.trim().isEmpty) continue;

      final itemStr = raw.trim();
      String quantity = '১ টি';
      String itemName = itemStr;

      final match = unitRegex.firstMatch(itemStr);
      if (match != null && match.group(0) != null && match.group(0)!.trim().isNotEmpty) {
        String numPart = (match.group(1) ?? '1').trim().toLowerCase();
        String unitPart = (match.group(2) ?? 'টি').trim().toLowerCase();

        if (numMap.containsKey(numPart)) {
          numPart = numMap[numPart]!;
        } else if (numPart == 'আধা') {
          numPart = '৫০০';
          unitPart = 'গ্রাম';
        } else if (numPart == 'পোয়া') {
          numPart = '২৫০';
          unitPart = 'গ্রাম';
        }

        if (unitPart == 'kg' || unitPart == 'kilo') {
          unitPart = 'কেজি';
        } else if (unitPart == 'gm' || unitPart == 'gram') {
          unitPart = 'গ্রাম';
        } else if (unitPart == 'liter' || unitPart == 'litre' || unitPart == 'ltr') {
          unitPart = 'লিটার';
        } else if (unitPart == 'dozen') {
          unitPart = 'ডজন';
        } else if (unitPart == 'pc' || unitPart == 'pcs' || unitPart == 'টা') {
          unitPart = 'টি';
        }

        quantity = '$numPart $unitPart';
        itemName = itemStr.replaceFirst(match.group(0)!, '').trim();
      }

      if (itemName.isEmpty) {
        itemName = itemStr;
      }

      itemName = _translateBanglishItem(itemName);
      final category = _detectCategory(itemName);

      results.add({
        'itemName': itemName,
        'quantity': quantity,
        'category': category,
        'estimatedPrice': null,
      });
    }

    return results;
  }

  static String _translateBanglishItem(String name) {
    final lower = name.toLowerCase().trim();
    const dictionary = {
      'alu': 'আলু', 'potato': 'আলু',
      'peyaj': 'পেঁয়াজ', 'pyaj': 'পেঁয়াজ', 'onion': 'পেঁয়াজ',
      'roshun': 'রসুন', 'rosun': 'রসুন', 'garlic': 'রসুন',
      'ada': 'আদা', 'ginger': 'আদা',
      'morich': 'মরিচ', 'chilli': 'মরিচ', 'chili': 'মরিচ',
      'tometo': 'টমেটো', 'tomato': 'টমেটো',
      'dim': 'ডিম', 'egg': 'ডিম', 'eggs': 'ডিম',
      'tel': 'তেল', 'oil': 'তেল', 'soyabean tel': 'সয়াবিন তেল',
      'chal': 'চাল', 'rice': 'চাল',
      'dal': 'ডাল', 'daal': 'ডাল', 'lentil': 'ডাল',
      'murgi': 'মুরগি', 'murgir mangsho': 'মুরগির মাংস', 'chicken': 'মুরগির মাংস',
      'goru': 'গরুর মাংস', 'gorur mangsho': 'গরুর মাংস', 'beef': 'গরুর মাংস',
      'khasi': 'খাসির মাংস', 'mutton': 'খাসির মাংস',
      'mach': 'মাছ', 'fish': 'মাছ',
      'lobon': 'লবণ', 'salt': 'লবণ',
      'chini': 'চিনি', 'sugar': 'চিনি',
      'ata': 'আটা', 'flour': 'আটা',
      'shosha': 'শসা', 'cucumber': 'শসা',
      'begun': 'বেগুন', 'brinjal': 'বেগুন',
      'potol': 'পটল',
      'fulkopi': 'ফুলকপি', 'cauliflower': 'ফুলকপি',
      'badhakopi': 'বাঁধাকপি', 'cabbage': 'বাঁধাকপি',
      'gajor': 'গাজর', 'carrot': 'গাজর',
      'lebu': 'লেবু', 'lemon': 'লেবু',
      'dud': 'দুধ', 'dudh': 'দুধ', 'milk': 'দুধ',
      'cha': 'চা পাতা', 'tea': 'চা পাতা',
      'kola': 'কলা', 'banana': 'কলা',
      'apel': 'আপেল', 'apple': 'আপেল',
      'aam': 'আম', 'mango': 'আম',
    };
    return dictionary[lower] ?? name;
  }

  static String _detectCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('আলু') || lower.contains('পেঁয়াজ') || lower.contains('পেঁয়াজ') || lower.contains('পিঁয়াজ') || lower.contains('রসুন') ||
        lower.contains('আদা') || lower.contains('মরিচ') || lower.contains('টমেটো') ||
        lower.contains('বেগুন') || lower.contains('পটল') || lower.contains('ফুলকপি') ||
        lower.contains('বাঁধাকপি') || lower.contains('গাজর') || lower.contains('শসা') ||
        lower.contains('শাক') || lower.contains('লেবু')) {
      return 'সবজি';
    } else if (lower.contains('মুরগি') || lower.contains('মাংস') || lower.contains('গরু') ||
               lower.contains('খাসি') || lower.contains('মাছ') || lower.contains('ইলিশ') ||
               lower.contains('রুই') || lower.contains('চিংড়ি')) {
      return 'মাছ-মাংস';
    } else if (lower.contains('তেল') || lower.contains('চাল') || lower.contains('ডাল') ||
               lower.contains('চিনি') || lower.contains('লবণ') || lower.contains('আটা') ||
               lower.contains('ময়দা') || lower.contains('ডিম') || lower.contains('দুধ') ||
               lower.contains('চা') || lower.contains('হলুদ') || lower.contains('মশলা')) {
      return 'মুদি মাল';
    } else if (lower.contains('আপেল') || lower.contains('কলা') || lower.contains('আম') ||
               lower.contains('কমলা') || lower.contains('আঙুর') || lower.contains('পেয়ারা')) {
      return 'ফল';
    }
    return 'অন্যান্য';
  }
}
