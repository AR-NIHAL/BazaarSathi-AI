import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/bazaar_item.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // হাইভ ইনিশিয়াকশন
  await Hive.initFlutter();
  
  // আমাদের তৈরি করা বাজারের আইটেম অ্যাডাপ্টার রেজিস্টার করা
  Hive.registerAdapter(BazaarItemAdapter());
  
  // 'bazaar_box' নামে একটি লোকাল স্টোরেজ বক্স ওপেন করা
  await Hive.openBox<BazaarItem>('bazaar_box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}