import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart'; // তোমার প্রজেক্ট স্ট্রাকচার অনুযায়ী পাথটি চেক করে নিও

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'স্মার্ট বাজার ফর্দ',
      debugShowCheckedModeBanner: false, // স্ক্রিনের কোণার লাল ডেমো ব্যানারটি সরানোর জন্য
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // ডিফল্ট কাউন্টার পেজ বদলে আমাদের হোম স্ক্রিন সেট করা হলো
    );
  }
}