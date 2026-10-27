import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bazaar_sathi_ai/presentation/widgets/shopping_summary_card.dart';

void main() {
  group('ShoppingSummaryCard Widget Tests', () {
    testWidgets('Renders correct progress percentage, ratio, budget, expense, and savings',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShoppingSummaryCard(
              totalItems: 4,
              completedItems: 3,
              totalEstimatedPrice: 1500,
              completedEstimatedPrice: 1120,
            ),
          ),
        ),
      );

      // Verify Percentage inside circular gauge: ৭৫% and সম্পন্ন
      expect(find.text('৭৫%'), findsOneWidget);
      expect(find.text('সম্পন্ন'), findsOneWidget);

      // Verify Status Ratio below circular gauge: ৩/৪টি কেনা শেষ
      expect(find.text('৩/৪টি কেনা শেষ'), findsOneWidget);

      // Verify Savings Pill: আজকের সাশ্রয় and ৳৩৮০ (২৫%)
      expect(find.textContaining('আজকের সাশ্রয়:'), findsOneWidget);
      expect(find.textContaining('৳৩৮০ (২৫%)'), findsOneWidget);

      // Verify Budget Limit: বাজেট সীমা and ৳১,৫০০
      expect(find.text('বাজেট সীমা'), findsOneWidget);
      expect(find.text('৳১,৫০০'), findsOneWidget);

      // Verify Current Expense: বর্তমান খরচ and ৳১,১২০
      expect(find.text('বর্তমান খরচ'), findsOneWidget);
      expect(find.text('৳১,১২০'), findsOneWidget);
    });

    testWidgets('Returns SizedBox.shrink() when totalItems is 0',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShoppingSummaryCard(
              totalItems: 0,
              completedItems: 0,
            ),
          ),
        ),
      );

      expect(find.text('সম্পন্ন'), findsNothing);
      expect(find.text('বাজেট সীমা'), findsNothing);
      expect(find.text('বর্তমান খরচ'), findsNothing);
    });

    testWidgets('Handles over-budget state gracefully without negative savings',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShoppingSummaryCard(
              totalItems: 4,
              completedItems: 4,
              totalEstimatedPrice: 1500,
              completedEstimatedPrice: 1650,
            ),
          ),
        ),
      );

      // 4/4 = 100%
      expect(find.text('১০০%'), findsOneWidget);
      expect(find.text('৪/৪টি কেনা শেষ'), findsOneWidget);

      // Savings shows ৳০ (০%) instead of negative
      expect(find.textContaining('৳০ (০%)'), findsOneWidget);
    });
  });
}
