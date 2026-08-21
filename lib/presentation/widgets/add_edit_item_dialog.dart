import 'package:flutter/material.dart';
import '../../data/models/bazaar_item.dart';

class AddEditItemDialog extends StatefulWidget {
  final BazaarItem? itemToEdit;
  final Function(String name, String quantity, String category, int? price) onSave;

  const AddEditItemDialog({
    super.key,
    this.itemToEdit,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    BazaarItem? itemToEdit,
    required Function(String name, String quantity, String category, int? price) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddEditItemDialog(
        itemToEdit: itemToEdit,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddEditItemDialog> createState() => _AddEditItemDialogState();
}

class _AddEditItemDialogState extends State<AddEditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late String _selectedCategory;

  final List<String> _categories = [
    "সবজি",
    "মাছ-মাংস",
    "মুদি মাল",
    "ফল",
    "অন্যান্য",
  ];

  final List<String> _quickQuantities = [
    "১ কেজি",
    "২ কেজি",
    "৫০০ গ্রাম",
    "১ লিটার",
    "১ ডজন",
    "৪ টি",
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.itemToEdit?.itemName ?? '');
    _quantityController =
        TextEditingController(text: widget.itemToEdit?.quantity ?? '১ কেজি');
    _priceController = TextEditingController(
      text: widget.itemToEdit?.estimatedPrice != null
          ? widget.itemToEdit!.estimatedPrice.toString()
          : '',
    );
    _selectedCategory = widget.itemToEdit?.category ?? 'সবজি';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final price = int.tryParse(_priceController.text.trim());
      widget.onSave(
        _nameController.text.trim(),
        _quantityController.text.trim(),
        _selectedCategory,
        price,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemToEdit != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'আইটেম পরিবর্তন করুন ✏️' : 'নতুন আইটেম যোগ করুন ➕',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Item Name Input
              TextFormField(
                controller: _nameController,
                autofocus: !isEditing,
                decoration: InputDecoration(
                  labelText: 'আইটেমের নাম',
                  hintText: 'যেমন: আলু, পেঁয়াজ, রুই মাছ',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.shopping_bag_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'অনুগ্রহ করে আইটেমের নাম লিখুন';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quantity Input
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'পরিমাণ',
                        hintText: 'যেমন: ১ কেজি',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.scale_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'পরিমাণ দিন';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Price Input
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'মূল্য (৳)',
                        hintText: 'ঐচ্ছিক',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.payments_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Quick quantity chips
              Wrap(
                spacing: 6,
                children: _quickQuantities.map((q) {
                  return ActionChip(
                    label: Text(q, style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      setState(() {
                        _quantityController.text = q;
                      });
                    },
                    backgroundColor: Colors.green[50],
                    side: BorderSide(color: Colors.green.shade200),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Category Selection Chips
              const Text(
                'ক্যাটাগরি নির্বাচন করুন:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(
                      cat,
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
                          _selectedCategory = cat;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submit,
                  child: Text(
                    isEditing ? 'পরিবর্তন সংরক্ষণ করুন' : 'তালিকায় যোগ করুন',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
