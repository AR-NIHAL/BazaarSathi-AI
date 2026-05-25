import 'package:hive/hive.dart';

// এই লাইনটি কোড জেনারেট করার জন্য অত্যন্ত জরুরি
part 'bazaar_item.g.dart';

@HiveType(typeId: 0) // ডেটাবেজের জন্য একটি ইউনিক টাইপ আইডি (0)
class BazaarItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String itemName;

  @HiveField(2)
  final String quantity;

  @HiveField(3)
  final String category;

  @HiveField(4)
  bool isChecked; // এটি ফাইনাল হবে না, কারণ ইউজার বক্সে টিক মার্ক দেবে

  BazaarItem({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.category,
    this.isChecked = false,
  });

  factory BazaarItem.fromJson(Map<String, dynamic> json) {
    return BazaarItem(
      id: json['id'] ?? '',
      itemName: json['itemName'] ?? '',
      quantity: json['quantity'] ?? '',
      category: json['category'] ?? 'অন্যান্য',
    );
  }
}