class BazaarItem {
  final String id;
  final String itemName;
  final String quantity;
  final String category;
  bool isChecked; // Added this so user can cross out items while walking through the market!

  BazaarItem({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.category,
    this.isChecked = false,
  });

  // This will convert our database data or Gemini JSON into a Flutter Object
  factory BazaarItem.fromJson(Map<String, dynamic> json) {
    return BazaarItem(
      id: json['id'] ?? '',
      itemName: json['itemName'] ?? '',
      quantity: json['quantity'] ?? '',
      category: json['category'] ?? 'অন্যান্য',
    );
  }
}