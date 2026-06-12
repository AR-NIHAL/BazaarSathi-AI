import 'package:bazaar_sathi_ai/data/services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../data/models/bazaar_item.dart'; //
// ১. আপনার GeminiService টি ইমপোর্ট করুন (আপনার প্রজেক্টের সঠিক পাথ অনুযায়ী এটি পরিবর্তন করতে পারেন)

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

  // ২. জেমিনি সার্ভিসের একটি ইনস্ট্যান্স এবং লোডিং স্টেট তৈরি করা
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    _bazaarBox = Hive.box<BazaarItem>('bazaar_box'); //
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose(); //
  }

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
        // মুখে বলা শেষ হলে ডেটা প্রসেস করা শুরু হবে
        _processVoiceInput(_textController.text);
      }
    }
  }

  // ৩. আসল জেমিনি সার্ভিস এবং লুপের লজিক এখানে যুক্ত করা হয়েছে
  void _processVoiceInput(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isLoading = true; // এআই প্রসেসিং শুরু হলে লোডিং দেখাবে
    });

    try {
      // জেমিনি সার্ভিস কল করে এআই থেকে স্ট্রাকচার্ড লিস্ট নিয়ে আসা
      List<Map<String, dynamic>> aiResponse = await _geminiService.parseBazaarList(text);

      // লুপ ঘুরিয়ে প্রতিটা আইটেম হাইভ বক্সে পুশ করা
      for (var itemMap in aiResponse) {
        // জেমিনি থেকে আসা ম্যাপ ডেটা ব্যবহার করে BazaarItem তৈরি
        final newItem = BazaarItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + itemMap['itemName'].hashCode.toString(), // ইউনিক আইডি নিশ্চিত করতে
          itemName: itemMap['itemName'] ?? 'অজানা আইটেম',
          quantity: itemMap['quantity'] ?? '১ টি',
          category: itemMap['category'] ?? 'অন্যান্য',
        );

        // হাইভ ডেটাবেজে সেভ করা (এটি অটোমেটিক ইউআই-তে রিফ্লেক্ট করবে)
        await _bazaarBox.put(newItem.id, newItem);
      }

      // কাজ শেষ হলে টেক্সট বক্স ক্লিয়ার করে দেওয়া
      _textController.clear();
    } catch (e) {
      print("Error storing data: $e");
      // কোনো এরর হলে ইউজারকে স্নাকবার দিয়ে জানানো যেতে পারে
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('দুঃখিত, জেমিনি সার্ভিস কাজ করছে না!')),
      );
    } finally {
      setState(() {
        _isLoading = false; // কাজ শেষে লোডিং বন্ধ হবে
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), //
      appBar: AppBar(
        title: const Text(
          'স্মার্ট বাজার ফর্দ 🛒', //
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[700], //
        centerTitle: true, //
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: () => _bazaarBox.clear(), //
          ),
        ],
      ),
      // জেমিনি যখন ডেটা প্রসেস করবে তখন স্ক্রিনের মাঝখানে একটি লোডিং সার্কেল দেখাবে
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : ValueListenableBuilder(
              valueListenable: _bazaarBox.listenable(), //
              builder: (context, Box<BazaarItem> box, _) {
                final items = box.values.toList(); //

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'আপনার বাজারের ফর্দ খালি!\nনিচে মাইক চেপে আইটেম যোগ করুন।', //
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                // ক্যাটাগরি অনুযায়ী গ্রুপিং লজিক
                final Map<String, List<BazaarItem>> groupedItems = {}; //
                for (var item in items) {
                  if (!groupedItems.containsKey(item.category)) {
                    groupedItems[item.category] = []; //
                  }
                  groupedItems[item.category]!.add(item); //
                }

                final categories = groupedItems.keys.toList(); //

                return ListView.builder(
                  itemCount: categories.length, //
                  itemBuilder: (context, catIndex) {
                    final categoryName = categories[catIndex]; //
                    final itemsInCategory = groupedItems[categoryName]!; //

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start, //
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 16, bottom: 4), //
                          child: Text(
                            categoryName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800], //
                            ),
                          ),
                        ),
                        ...itemsInCategory.map((item) {
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), //
                            elevation: 1.5, //
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), //
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green[50], //
                                child: Icon(
                                  item.category == "সবজি" ? Icons.eco : Icons.shopping_basket, //
                                  color: Colors.green[700], //
                                ),
                              ),
                              title: Text(
                                item.itemName, //
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold, //
                                  decoration: item.isChecked ? TextDecoration.lineThrough : null, //
                                  color: item.isChecked ? Colors.grey : Colors.black87, //
                                ),
                              ),
                              subtitle: Text('পরিমাণ: ${item.quantity}'), //
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min, //
                                children: [
                                  Checkbox(
                                    activeColor: Colors.green[700], //
                                    value: item.isChecked, //
                                    onChanged: (bool? value) {
                                      item.isChecked = value ?? false; //
                                      item.save(); //
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent), //
                                    onPressed: () => item.delete(), //
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
        padding: const EdgeInsets.all(24.0), //
        decoration: BoxDecoration(
          color: Colors.white, //
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), //
              blurRadius: 10, //
              offset: const Offset(0, -5), //
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16), //
                decoration: BoxDecoration(
                  color: Colors.grey[100], //
                  borderRadius: BorderRadius.circular(30), //
                ),
                child: TextField(
                  controller: _textController, //
                  onSubmitted: (value) {
                    // কী-বোর্ড থেকে এন্টার চাপলেও যেন ইনপুট প্রসেস হয়
                    _processVoiceInput(value);
                  },
                  decoration: const InputDecoration(
                    hintText: 'মুখে বলুন বা এখানে লিখুন...', //
                    border: InputBorder.none, //
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12), //
            FloatingActionButton(
              onPressed: _listen, //
              backgroundColor: _isListening ? Colors.red[700] : Colors.green[700], //
              child: Icon(
                _isListening ? Icons.stop : Icons.mic, //
                color: Colors.white, //
                size: 28, //
              ),
            ),
          ],
        ),
      ),
    );
  }
}