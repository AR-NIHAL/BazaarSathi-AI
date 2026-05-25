import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // তোমার API Key-টি এখানে বসাও (টেস্টিং এর জন্য)
  final String _apiKey = ""; 
  late final GenerativeModel _model;

  GeminiService() {
    // ২০২৬ সালে gemini-2.5-flash হচ্ছে সবচেয়ে ফাস্ট এবং ফ্রি টায়ারের জন্য বেস্ট
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', 
      apiKey: _apiKey,
    );
  }

  Future<List<Map<String, dynamic>>> parseBazaarList(String rawText) async {
    // এই প্রম্পটটিই হচ্ছে আসল ট্রিক। একে বলা হয় Few-Shot Prompting।
    final prompt = """
You are a strict Bangladeshi Bazaar Assistant. Your job is to extract items from raw Bangla text and convert them into a structured JSON array. 

Rules:
1. Return ONLY a valid JSON array of objects. Do NOT include markdown blocks like ```json or any conversational text.
2. Each object MUST have these exact keys: "itemName", "quantity", "category".
3. Normalize numbers to digits (e.g., "দুই কেজি" becomes "২ কেজি").
4. Categories should be standard like: "সবজি", "মাছ-মাংস", "মুদি মাল", "ফল", "অন্যান্য".

Example Input: "দুই কেজি আলু আর ৫০০ গ্রাম মুরগির মাংস"
Example Output: [{"itemName": "আলু", "quantity": "২ কেজি", "category": "সবজি"}, {"itemName": "মুরগির মাংস", "quantity": "৫০০ গ্রাম", "category": "মাছ-মাংস"}]

Now process this text: "$rawText"
""";

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      final responseText = response.text?.trim() ?? "[]";
      
      // JSON স্ট্রিংটিকে ফ্লাটারের লিস্টে কনভার্ট করছি
      List<dynamic> decoded = jsonDecode(responseText);
      return List<Map<String, dynamic>>.from(decoded);
    } catch (e) {
      print("Gemini Error: $e");
      return [];
    }
  }
}
