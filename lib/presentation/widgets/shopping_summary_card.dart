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
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade800,
            Colors.green.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'বাজারের অগ্রগতি',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percent.toBengaliDigits()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatChip(
                label: 'মোট আইটেম',
                value: '${totalItems.toBengaliDigits()} টি',
                icon: Icons.format_list_bulleted,
              ),
              _buildStatChip(
                label: 'কেনা সম্পন্ন',
                value: '${completedItems.toBengaliDigits()} টি',
                icon: Icons.check_circle_outline,
              ),
              _buildStatChip(
                label: 'বাকি আছে',
                value: '${remainingItems.toBengaliDigits()} টি',
                icon: Icons.pending_outlined,
              ),
            ],
          ),
          if (totalEstimatedPrice > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          color: Colors.yellowAccent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'আনুমানিক বাজেট: ৳${totalEstimatedPrice.toBengaliDigits()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (completedEstimatedPrice > 0)
                    Text(
                      'খরচ: ৳${completedEstimatedPrice.toBengaliDigits()}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 15),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
