import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../data/models/bazaar_item.dart';
import '../../data/services/gemini_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Speech to Text variables
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = "";
  
  // 2. _HomeScreenState এর ভেতরে সার্ভিসটির অবজেক্ট তৈরি করা হলো
  final GeminiService _geminiService = GeminiService();
  
  // Controller to dynamically show recognized text inside the TextField
  final TextEditingController _textController = TextEditingController();

  // Hardcoded dummy data for testing our UI layout
  final List<BazaarItem> dummyBazaarList = [
    BazaarItem(id: "1", itemName: "পেঁয়াজ", quantity: "১ কেজি", category: "সবজি"),
    BazaarItem(id: "2", itemName: "আলু", quantity: "২ কেজি", category: "সবজি"),
    BazaarItem(id: "3", itemName: "সয়াবিন তেল", quantity: "১ লিটার", category: "মুদি মাল"),
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // This function triggers when the mic button is pressed
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('Status: $val'),
        onError: (val) => print('Error: $val'),
      );
      
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'bn_BD', // Forces the engine to recognize pure Bengali
          onResult: (val) => setState(() {
            _voiceText = val.recognizedWords;
            // Instantly show the spoken words inside the text field for great UX
            _textController.text = _voiceText;
          }),
        );
      }
    } else {
      // ৩. এখানে তোমার দেওয়া রিয়েল-টাইম AI কানেকশনের লজিকটি হুবহু বসানো হলো
      setState(() => _isListening = false);
      await _speech.stop();
      
      if (_voiceText.isNotEmpty) {
        // স্ক্রিনে একটা লোডিং বা প্রগ্রেস বার দেখানোর জন্য (Good UX)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI আপনার লিস্ট গোছাচ্ছে... 🧠')),
        );

        // Gemini থেকে স্ট্রাকচার্ড লিস্ট নিয়ে আসা
        final aiOutput = await _geminiService.parseBazaarList(_voiceText);

        // পাওয়া আইটেমগুলো আমাদের মূল dummyBazaarList-এ যোগ করা
        setState(() {
          for (var itemData in aiOutput) {
            dummyBazaarList.add(
              BazaarItem(
                id: DateTime.now().millisecondsSinceEpoch.toString() + itemData['itemName'],
                itemName: itemData['itemName'],
                quantity: itemData['quantity'],
                category: itemData['category'],
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Clean, light gray background
      appBar: AppBar(
        title: const Text(
          'স্মার্ট বাজার ফর্দ 🛒',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // The visual list container
          Expanded(
            child: ListView.builder(
              itemCount: dummyBazaarList.length,
              itemBuilder: (context, index) {
                final item = dummyBazaarList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Icon(Icons.shopping_basket, color: Colors.green[700]),
                    ),
                    title: Text(
                      item.itemName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('পরিমাণ: ${item.quantity} | ${item.category}'),
                    trailing: Checkbox(
                      activeColor: Colors.green[700],
                      value: item.isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          item.isChecked = value ?? false;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Bottom control deck for inputting speech
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'মুখে বলুন বা এখানে লিখুন...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Massive voice action button designed for single thumb-clicks in a busy market
                FloatingActionButton(
                  onPressed: _listen, // Wire up the voice recording logic here
                  backgroundColor: _isListening ? Colors.red[700] : Colors.green[700], // Red visual cue when listening
                  child: Icon(
                    _isListening ? Icons.stop : Icons.mic, 
                    color: Colors.white, 
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}