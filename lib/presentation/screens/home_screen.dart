import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/utils/number_utils.dart';
import '../../data/models/bazaar_item.dart';
import '../../data/services/gemini_service.dart';
import '../widgets/add_edit_item_dialog.dart';
import '../widgets/recipe_bazaar_dialog.dart';
import '../widgets/shopping_summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Box<BazaarItem> _bazaarBox;
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isListening = false;
  String _selectedLocaleId = 'bn_BD'; // Default Bengali (Bangladesh)

  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;
  String _loadingMessage = 'এআই তালিকা তৈরি করছে...';

  String _selectedCategoryFilter = "সব";
  bool _showOnlyPending = false;

  final List<String> _filterCategories = [
    "সব",
    "সবজি",
    "মাছ-মাংস",
    "মুদি মাল",
    "ফল",
    "অন্যান্য",
  ];

  @override
  void initState() {
    super.initState();
    _bazaarBox = Hive.box<BazaarItem>('bazaar_box');
    _initSpeech();
  }

  /// Initialize speech engine and detect best available Bengali locale
  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech Status: $status');
          if (status == 'done' || status == 'notListening') {
            if (_isListening) {
              setState(() => _isListening = false);
              if (_textController.text.isNotEmpty) {
                _processVoiceInput(_textController.text);
              }
            }
          }
        },
        onError: (errorNotification) {
          debugPrint('Speech Error: ${errorNotification.errorMsg}');
          if (mounted) {
            setState(() => _isListening = false);
          }
        },
      );

      if (available) {
        final locales = await _speech.locales();
        for (final loc in locales) {
          if (loc.localeId == 'bn_BD') {
            _selectedLocaleId = 'bn_BD';
            break;
          } else if (loc.localeId == 'bn_IN' || loc.localeId.startsWith('bn')) {
            _selectedLocaleId = loc.localeId;
          }
        }
        debugPrint('Selected Speech Locale: $_selectedLocaleId');
      }
    } catch (e) {
      debugPrint('Speech init failed: $e');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = _speech.isAvailable;
      if (!available) {
        available = await _speech.initialize();
      }

      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.dictation,
            partialResults: true,
          ),
          onResult: (val) {
            setState(() {
              _textController.text = val.recognizedWords;
            });
          },
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('মাইক্রোফোন চালু করা সম্ভব হয়নি। পারমিশন চেক করুন।'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
      if (_textController.text.isNotEmpty) {
        _processVoiceInput(_textController.text);
      }
    }
  }

  void _processVoiceInput(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'এআই তালিকা তৈরি করছে...';
    });

    try {
      final List<Map<String, dynamic>> aiResponse =
          await _geminiService.parseBazaarList(cleanText);

      await _addItemsToBox(aiResponse);
      _textController.clear();
    } catch (e) {
      debugPrint("Error storing data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('দুঃখিত, এআই সার্ভিস কাজ করছে না! ইন্টারনেট সংযোগ চেক করুন।'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Pick image from Camera or Gallery and parse with Gemini Vision OCR
  Future<void> _pickAndScanBazaarImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (image == null) return;

      setState(() {
        _isLoading = true;
        _loadingMessage = 'কাগজের ফর্দ স্ক্যান করা হচ্ছে...';
      });

      final imageBytes = await image.readAsBytes();
      final mimeType = image.name.toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg';

      final List<Map<String, dynamic>> aiResponse =
          await _geminiService.parseBazaarImage(imageBytes, mimeType: mimeType);

      if (aiResponse.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ছবি থেকে কোনো আইটেম পাওয়া যায়নি। স্পষ্ট ছবি তুলুন।'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        await _addItemsToBox(aiResponse);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ছবি থেকে ${aiResponse.length.toBengaliDigits()} টি আইটেম যুক্ত করা হয়েছে!'),
              backgroundColor: Colors.green[800],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Image scan error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ছবি স্ক্যান করতে সমস্যা হয়েছে। আবার চেষ্টা করুন।'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Generate recipe bazaar list via Recipe-to-Bazaar AI
  Future<void> _generateRecipeList(String dishName, int personCount) async {
    setState(() {
      _isLoading = true;
      _loadingMessage = '\'$dishName\'-এর জন্য ফর্দ তৈরি হচ্ছে...';
    });

    try {
      final List<Map<String, dynamic>> aiResponse =
          await _geminiService.generateRecipeBazaarList(dishName, personCount: personCount);

      if (aiResponse.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('রেসিপির ফর্দ তৈরি করা সম্ভব হয়নি। আবার চেষ্টা করুন।'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        await _addItemsToBox(aiResponse);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('\'$dishName\'-এর জন্য ${aiResponse.length.toBengaliDigits()} টি উপকরণ যুক্ত হয়েছে!'),
              backgroundColor: Colors.green[800],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Recipe generation error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('দুঃখিত, রেসিপি সার্ভিস কাজ করছে না!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show modal to choose image source (Camera vs Gallery)
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'কাগজের বাজার ফর্দ স্ক্যান করুন 📸',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.camera_alt, color: Colors.green),
                ),
                title: const Text('ক্যামেরা দিয়ে ছবি তুলুন'),
                subtitle: const Text('কাগজে লেখা বাজার ফর্দের সরাসরি ছবি তুলুন'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndScanBazaarImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.photo_library, color: Colors.green),
                ),
                title: const Text('গ্যালারি থেকে ছবি আপলোড করুন'),
                subtitle: const Text('ফোনে সেভ করা ফর্দের ছবি সিলেক্ট করুন'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndScanBazaarImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to insert AI items into Hive box
  Future<void> _addItemsToBox(List<Map<String, dynamic>> items) async {
    for (var itemMap in items) {
      final newItem = BazaarItem(
        id: '${DateTime.now().millisecondsSinceEpoch}_${itemMap['itemName'].hashCode}',
        itemName: itemMap['itemName'] ?? 'অজানা আইটেম',
        quantity: itemMap['quantity'] ?? '১ টি',
        category: itemMap['category'] ?? 'অন্যান্য',
        estimatedPrice: itemMap['estimatedPrice'] as int?,
      );
      await _bazaarBox.put(newItem.id, newItem);
    }
  }

  /// Open Add/Edit Item Dialog
  void _showAddOrEditDialog({BazaarItem? item}) {
    AddEditItemDialog.show(
      context,
      itemToEdit: item,
      onSave: (name, quantity, category, price) async {
        if (item != null) {
          // Editing existing item
          item.itemName = name;
          item.quantity = quantity;
          item.category = category;
          item.estimatedPrice = price;
          await item.save();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('\'$name\' আপডেট করা হয়েছে')),
            );
          }
        } else {
          // Adding new item manually
          final newItem = BazaarItem(
            id: '${DateTime.now().millisecondsSinceEpoch}_${name.hashCode}',
            itemName: name,
            quantity: quantity,
            category: category,
            estimatedPrice: price,
          );
          await _bazaarBox.put(newItem.id, newItem);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('\'$name\' ফর্দে যোগ করা হয়েছে')),
            );
          }
        }
      },
    );
  }

  /// Safe delete with undo SnackBar
  void _deleteWithUndo(BazaarItem item) {
    final deletedId = item.id;
    final restoredItem = BazaarItem(
      id: item.id,
      itemName: item.itemName,
      quantity: item.quantity,
      category: item.category,
      isChecked: item.isChecked,
      estimatedPrice: item.estimatedPrice,
    );

    item.delete();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('\'${restoredItem.itemName}\' মুছে ফেলা হয়েছে'),
        action: SnackBarAction(
          label: 'আনডু (Undo)',
          textColor: Colors.yellowAccent,
          onPressed: () {
            _bazaarBox.put(deletedId, restoredItem);
          },
        ),
      ),
    );
  }

  /// Confirmation dialog before clearing entire list
  void _confirmClearAll() {
    if (_bazaarBox.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('সম্পূর্ণ ফর্দ মুছে ফেলতে চান?'),
        content: const Text(
          'আপনার বাজারের ফর্দের সমস্ত আইটেম মুছে যাবে। আপনি কি নিশ্চিত?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _bazaarBox.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('সম্পূর্ণ ফর্দ মুছে ফেলা হয়েছে')),
              );
            },
            child: const Text('সব মুছুন'),
          ),
        ],
      ),
    );
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
          IconButton(
            icon: const Icon(Icons.soup_kitchen_outlined, color: Colors.white),
            tooltip: 'রেসিপি সহকারী',
            onPressed: () => RecipeBazaarDialog.show(
              context,
              onGenerate: _generateRecipeList,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined, color: Colors.white),
            tooltip: 'কাগজের ফর্দ স্ক্যান করুন',
            onPressed: _showImageSourceDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: 'ম্যানুয়ালি যোগ করুন',
            onPressed: () => _showAddOrEditDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            tooltip: 'সব মুছুন',
            onPressed: _confirmClearAll,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    _loadingMessage,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ValueListenableBuilder(
              valueListenable: _bazaarBox.listenable(),
              builder: (context, Box<BazaarItem> box, _) {
                final allItems = box.values.toList();
                final totalCount = allItems.length;
                final completedCount =
                    allItems.where((item) => item.isChecked).length;

                // Price calculations
                int totalEstimatedBudget = 0;
                int completedEstimatedBudget = 0;
                for (var item in allItems) {
                  if (item.estimatedPrice != null) {
                    totalEstimatedBudget += item.estimatedPrice!;
                    if (item.isChecked) {
                      completedEstimatedBudget += item.estimatedPrice!;
                    }
                  }
                }

                if (allItems.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'আপনার বাজারের ফর্দ খালি!\nনিচে মাইক চেপে, ছবি তুলে বা রেসিপি থেকে আইটেম যোগ করুন।',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 10,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[50],
                                  foregroundColor: Colors.green[800],
                                  elevation: 0,
                                  side: BorderSide(color: Colors.green.shade300),
                                ),
                                icon: const Icon(Icons.camera_alt_outlined),
                                label: const Text('কাগজের ফর্দ স্ক্যান'),
                                onPressed: _showImageSourceDialog,
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[50],
                                  foregroundColor: Colors.orange[900],
                                  elevation: 0,
                                  side: BorderSide(color: Colors.orange.shade300),
                                ),
                                icon: const Icon(Icons.soup_kitchen_outlined),
                                label: const Text('রেসিপি সহকারী'),
                                onPressed: () => RecipeBazaarDialog.show(
                                  context,
                                  onGenerate: _generateRecipeList,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Filter logic
                final filteredItems = allItems.where((item) {
                  final matchesCategory = _selectedCategoryFilter == "সব" ||
                      item.category == _selectedCategoryFilter;
                  final matchesPending =
                      !_showOnlyPending || !item.isChecked;
                  return matchesCategory && matchesPending;
                }).toList();

                // Group by category
                final Map<String, List<BazaarItem>> groupedItems = {};
                for (var item in filteredItems) {
                  if (!groupedItems.containsKey(item.category)) {
                    groupedItems[item.category] = [];
                  }
                  groupedItems[item.category]!.add(item);
                }

                final categories = groupedItems.keys.toList();

                return CustomScrollView(
                  slivers: [
                    // Shopping progress & budget summary card
                    SliverToBoxAdapter(
                      child: ShoppingSummaryCard(
                        totalItems: totalCount,
                        completedItems: completedCount,
                        totalEstimatedPrice: totalEstimatedBudget,
                        completedEstimatedPrice: completedEstimatedBudget,
                      ),
                    ),

                    // Filter chips row
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _filterCategories.map((cat) {
                                    final isSelected =
                                        _selectedCategoryFilter == cat;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: FilterChip(
                                        label: Text(
                                          cat,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        selected: isSelected,
                                        selectedColor: Colors.green[700],
                                        checkmarkColor: Colors.white,
                                        backgroundColor: Colors.white,
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedCategoryFilter = cat;
                                          });
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _showOnlyPending
                                    ? Icons.filter_alt
                                    : Icons.filter_alt_outlined,
                                color: _showOnlyPending
                                    ? Colors.green[800]
                                    : Colors.grey,
                              ),
                              tooltip: _showOnlyPending
                                  ? 'সব আইটেম দেখুন'
                                  : 'শুধু বাকি আইটেম দেখুন',
                              onPressed: () {
                                setState(() {
                                  _showOnlyPending = !_showOnlyPending;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Empty filter results
                    if (groupedItems.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'এই ফিল্টারে কোনো আইটেম পাওয়া যায়নি',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ),
                      )
                    else
                      // Grouped items list
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, catIndex) {
                            final categoryName = categories[catIndex];
                            final itemsInCategory =
                                groupedItems[categoryName]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, top: 16, bottom: 4),
                                  child: Text(
                                    categoryName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ),
                                ...itemsInCategory.map((item) {
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 5),
                                    elevation: 1.5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      onTap: () =>
                                          _showAddOrEditDialog(item: item),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.green[50],
                                        child: Icon(
                                          item.category == "সবজি"
                                              ? Icons.eco
                                              : item.category == "মাছ-মাংস"
                                                  ? Icons.restaurant
                                                  : item.category == "ফল"
                                                      ? Icons.apple
                                                      : Icons.shopping_basket,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                      title: Text(
                                        item.itemName,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          decoration: item.isChecked
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: item.isChecked
                                              ? Colors.grey
                                              : Colors.black87,
                                        ),
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Text(
                                            'পরিমাণ: ${item.quantity}',
                                            style: TextStyle(
                                              color: item.isChecked
                                                  ? Colors.grey
                                                  : Colors.grey[700],
                                            ),
                                          ),
                                          if (item.estimatedPrice != null) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.green[50],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color: Colors.green.shade200),
                                              ),
                                              child: Text(
                                                '~ ৳${item.estimatedPrice!.toBengaliDigits()}',
                                                style: TextStyle(
                                                  color: Colors.green[800],
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                            tooltip: 'পরিবর্তন করুন',
                                            onPressed: () =>
                                                _showAddOrEditDialog(
                                                    item: item),
                                          ),
                                          Checkbox(
                                            activeColor: Colors.green[700],
                                            value: item.isChecked,
                                            onChanged: (bool? value) {
                                              item.isChecked =
                                                  value ?? false;
                                              item.save();
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.redAccent,
                                            ),
                                            tooltip: 'মুছুন',
                                            onPressed: () =>
                                                _deleteWithUndo(item),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                          childCount: categories.length,
                        ),
                      ),

                    // Bottom padding space for floating input
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.green),
                tooltip: 'কাগজের ফর্দ স্ক্যান করুন',
                onPressed: _showImageSourceDialog,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (value) {
                      _processVoiceInput(value);
                    },
                    decoration: InputDecoration(
                      hintText: _isListening
                          ? 'শুনছি... কথা বলুন'
                          : 'মুখে বলুন বা এখানে লিখুন...',
                      hintStyle: TextStyle(
                        color: _isListening ? Colors.red[700] : Colors.grey,
                        fontWeight:
                            _isListening ? FontWeight.bold : FontWeight.normal,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                onPressed: _listen,
                backgroundColor:
                    _isListening ? Colors.red[700] : Colors.green[700],
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}