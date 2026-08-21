import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bazaar_sathi_ai/presentation/widgets/shopping_summary_card.dart';

void main() {
  group('ShoppingSummaryCard Widget Tests', () {
    testWidgets('Renders correct progress percentage and item counts in Bengali',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShoppingSummaryCard(
              totalItems: 10,
              completedItems: 4,
            ),
          ),
        ),
      );

      // Verify Percentage (4/10 = 40% -> ৪০%)
      expect(find.text('৪০%'), findsOneWidget);

      // Verify Progress Label
      expect(find.text('বাজারের অগ্রগতি'), findsOneWidget);

      // Verify Total, Completed, Remaining Counts in Bengali numerals
      expect(find.text('১০ টি'), findsOneWidget); // total
      expect(find.text('৪ টি'), findsOneWidget);  // completed
      expect(find.text('৬ টি'), findsOneWidget);  // remaining
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

      expect(find.text('বাজারের অগ্রগতি'), findsNothing);
    });
  });
}
