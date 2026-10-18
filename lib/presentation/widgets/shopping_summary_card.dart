import 'package:flutter/material.dart';
import '../../core/utils/number_utils.dart';

class ShoppingSummaryCard extends StatelessWidget {
  final int totalItems;
  final int completedItems;
  final int totalEstimatedPrice;
  final int completedEstimatedPrice;

  const ShoppingSummaryCard({
    super.key,
    required this.totalItems,
    required this.completedItems,
    this.totalEstimatedPrice = 0,
    this.completedEstimatedPrice = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) return const SizedBox.shrink();

    final double progress =
        totalItems > 0 ? (completedItems / totalItems) : 0.0;
    final int percent = (progress * 100).round();
    final int remainingItems = totalItems - completedItems;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C6E3C),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0B6A3A),
            Color(0xFF0F7C46),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C6E3C).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_graph_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'বাজারের সার্বিক অগ্রগতি',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              // Golden Status Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF78350F),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${percent.toBengaliDigits()}% সম্পন্ন',
                      style: const TextStyle(
                        color: Color(0xFF451A03),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar (Amber bar on subtle dark track)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 7,
              color: Colors.black.withValues(alpha: 0.22),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3-Column Stats Container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricColumn(
                    label: 'মোট আইটেম',
                    value: '${totalItems.toBengaliDigits()} টি',
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                Expanded(
                  child: _buildMetricColumn(
                    label: 'কেনা সম্পন্ন',
                    value: '${completedItems.toBengaliDigits()} টি',
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                Expanded(
                  child: _buildMetricColumn(
                    label: 'বাকি আছে',
                    value: '${remainingItems.toBengaliDigits()} টি',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Budget & Expense Strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.credit_card_outlined,
                    color: Color(0xFFFDE68A),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'বাজেট: ৳${totalEstimatedPrice.toBengaliDigits()}',
                    style: const TextStyle(
                      color: Color(0xFFFEF08A),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'মোট খরচ: ৳${completedEstimatedPrice.toBengaliDigits()}',
                  style: const TextStyle(
                    color: Color(0xFFA7F3D0),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn({
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

