import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../data/models/bazaar_item.dart';
// এখানে আপনার জেমিনি সার্ভিসের ইমপোর্ট পাথটি দিন (যেমন:)
// import '../../core/services/gemini_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Box<BazaarItem> _bazaarBox;
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    // ১. অলরেডি মেইন ফাইলে ওপেন করা হাইভ বক্সের রেফারেন্স নেওয়া
    _bazaarBox = Hive.box<BazaarItem>('bazaar_box');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // ভয়েস লিসেনিং মেথড (আপনার আগের লজিক অনুযায়ী)
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _textController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_textController.text.isNotEmpty) {
        _processVoiceInput(_textController.text);
      }
    }
  }

  // এআই দিয়ে প্রসেস করে হাইভে ডেটা সেভ করার মেথড
  void _processVoiceInput(String text) async {
    // এখানে আপনার GeminiService কল করে লিস্ট নিয়ে আসবেন
    // উদাহরণস্বরূপ নিচে একটি ডামি অবজেক্ট তৈরি করে দেখানো হলো যা জেমিনি থেকে আসবে:

    final newItem = BazaarItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemName: text, // এআই থেকে পাওয়া নাম
      quantity: '১ কেজি', // এআই থেকে পাওয়া পরিমাণ
      category: 'সবজি', // এআই থেকে পাওয়া ক্যাটাগরি
    );

    // ২. ডেটাবেজে আইটেম পুশ করা (এটি অটোমেটিক ইউআই-তে রিফ্লেক্ট করবে)
    await _bazaarBox.put(newItem.id, newItem);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'স্মার্ট বাজার ফর্দ 🛒',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        actions: [
          // অল ক্লিয়ার বাটন (পুরো ফর্দ একসাথে ডিলিট করার জন্য)
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: () => _bazaarBox.clear(),
          ),
        ],
      ),
      // ৩. ValueListenableBuilder ব্যবহার করার ফলে হাইভে কোনো ডেটা অ্যাড/ডিলিট/আপডেট হলে ইউআই নিজে থেকেই রিফ্রেশ হবে
      body: ValueListenableBuilder(
        valueListenable: _bazaarBox.listenable(),
        builder: (context, Box<BazaarItem> box, _) {
          final items = box.values.toList();

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'আপনার বাজারের ফর্দ খালি!\nনিচে মাইক চেপে আইটেম যোগ করুন।',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          // ৪. হাইভ থেকে আসা লাইভ ডেটাগুলোকে ক্যাটাগরি অনুযায়ী ম্যাপে গ্রুপিং করা
          final Map<String, List<BazaarItem>> groupedItems = {};
          for (var item in items) {
            if (!groupedItems.containsKey(item.category)) {
              groupedItems[item.category] = [];
            }
            groupedItems[item.category]!.add(item);
          }

          final categories = groupedItems.keys.toList();

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, catIndex) {
              final categoryName = categories[catIndex];
              final itemsInCategory = groupedItems[categoryName]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ক্যাটাগরি সাব-হেডার
                  //  সঠিক কোড
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      top: 16,
                      bottom: 4,
                    ),
                    child: Text(
                      categoryName, // ক্যাটাগরির নাম
                      style: TextStyle(
                        // <-- style সবসময় Text উইজেটের ভেতরে থাকবে
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ),

                  // ঐ নির্দিষ্ট ক্যাটাগরির আইটেম লিস্ট
                  ...itemsInCategory.map((item) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green[50],
                          child: Icon(
                            item.category == "সবজি"
                                ? Icons.eco
                                : Icons.shopping_basket,
                            color: Colors.green[700],
                          ),
                        ),
                        title: Text(
                          item.itemName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: item.isChecked
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isChecked
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),
                        subtitle: Text('পরিমাণ: ${item.quantity}'),
                        // ডিলিট করার সুবিধা
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              activeColor: Colors.green[700],
                              value: item.isChecked,
                              onChanged: (bool? value) {
                                // ৫. হাইভে রিয়েল-টাইম চেক স্ট্যাটাস আপডেট করা
                                item.isChecked = value ?? false;
                                item.save(); // HiveObject এর বিল্ট-ইন মেথড যা লোকাল ডেটা আপডেট করে
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                // ৬. সিঙ্গেল আইটেম হাইভ থেকে ডিলিট করা
                                item.delete();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
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
            FloatingActionButton(
              onPressed: _listen,
              backgroundColor: _isListening
                  ? Colors.red[700]
                  : Colors.green[700],
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
