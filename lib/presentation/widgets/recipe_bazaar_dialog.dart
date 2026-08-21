import 'package:flutter/material.dart';
import '../../core/utils/number_utils.dart';

class RecipeBazaarDialog extends StatefulWidget {
  final Function(String dishName, int personCount) onGenerate;

  const RecipeBazaarDialog({
    super.key,
    required this.onGenerate,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(String dishName, int personCount) onGenerate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RecipeBazaarDialog(onGenerate: onGenerate),
    );
  }

  @override
  State<RecipeBazaarDialog> createState() => _RecipeBazaarDialogState();
}

class _RecipeBazaarDialogState extends State<RecipeBazaarDialog> {
  final _controller = TextEditingController();
  int _selectedPersons = 4;

  final List<int> _personOptions = [2, 4, 6, 8, 10, 15];
  final List<String> _popularDishes = [
    "গরুর কাচ্চি বিরিয়ানি",
    "খিচুড়ি ও ইলিশ মাছ",
    "চিকেন রোস্ট ও পোলাও",
    "খাসির রেজালা",
    "সবজি নুডুলস",
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.pop(context);
    widget.onGenerate(text, _selectedPersons);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.restaurant_menu, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'রেসিপি বাজার সহকারী 🍲',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'আপনি যে খাবার রান্না করতে চান তা লিখুন, এআই স্বয়ংক্রিয়ভাবে প্রয়োজনীয় সব মশলা ও উপকরণের বাজার ফর্দ তৈরি করে দেবে।',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Dish Name Input
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'খাবার / রান্নার নাম',
                hintText: 'যেমন: কাচ্চি বিরিয়ানি, ইলিশ ভুনা',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.soup_kitchen_outlined),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 10),

            // Popular Dish Chips
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _popularDishes.map((dish) {
                return ActionChip(
                  label: Text(dish, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.green[50],
                  side: BorderSide(color: Colors.green.shade200),
                  onPressed: () {
                    setState(() {
                      _controller.text = dish;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Person Count Selector
            const Text(
              'কত জনের জন্য রান্না হবে?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _personOptions.map((count) {
                  final isSelected = _selectedPersons == count;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        '${count.toBengaliDigits()} জন',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.green[700],
                      backgroundColor: Colors.grey[100],
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedPersons = count;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  'উপকরণের ফর্দ তৈরি করুন',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _submit,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
