import 'dart:math' as math;
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

    // Savings calculation: budget - current expense
    final int savings = (totalEstimatedPrice > completedEstimatedPrice)
        ? (totalEstimatedPrice - completedEstimatedPrice)
        : 0;

    final int savingsPercent = (totalEstimatedPrice > 0 && savings > 0)
        ? ((savings / totalEstimatedPrice) * 100).round()
        : 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF022B1C), // Deep forest emerald
            Color(0xFF043825),
            Color(0xFF064E3B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF022B1C).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Column: Circular Progress Ring & Item Count
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CircularProgressGauge(
                progress: progress,
                percent: percent,
              ),
              const SizedBox(height: 10),
              Text(
                '${completedItems.toBengaliDigits()}/${totalItems.toBengaliDigits()}টি কেনা শেষ',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Right Column: Savings Pill & Budget/Expense Card
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Pill: আজকের সাশ্রয়
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E3D2B).withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFD97706).withValues(alpha: 0.75),
                      width: 1.2,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFFFBBF24),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'আজকের সাশ্রয়: ',
                                style: TextStyle(
                                  color: Color(0xFFFEF3C7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '৳${savings.toBengaliDigitsWithComma()} (${savingsPercent.toBengaliDigits()}%)',
                                style: const TextStyle(
                                  color: Color(0xFFFDE047),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Bottom Box: বাজেট সীমা & বর্তমান খরচ
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF04271A).withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // বাজেট সীমা
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'বাজেট সীমা',
                              style: TextStyle(
                                color: Color(0xFF6EE7B7),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '৳${totalEstimatedPrice.toBengaliDigitsWithComma()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      Container(
                        width: 1,
                        height: 32,
                        color: Colors.white.withValues(alpha: 0.12),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                      ),

                      // বর্তমান খরচ
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'বর্তমান খরচ',
                              style: TextStyle(
                                color: Color(0xFF6EE7B7),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '৳${completedEstimatedPrice.toBengaliDigitsWithComma()}',
                                style: const TextStyle(
                                  color: Color(0xFF6EE7B7),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgressGauge extends StatelessWidget {
  final double progress;
  final int percent;

  const _CircularProgressGauge({
    required this.progress,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(96, 96),
            painter: _CircularGaugePainter(
              progress: progress,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percent.toBengaliDigits()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'সম্পন্ন',
                style: TextStyle(
                  color: Color(0xFFD1FAE5),
                  fontWeight: FontWeight.w500,
                  fontSize: 11.5,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircularGaugePainter extends CustomPainter {
  final double progress;

  _CircularGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 9.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Dark emerald background track
    final trackPaint = Paint()
      ..color = const Color(0xFF042618)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Progress arc in golden amber
    final progressPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    const startAngle = -math.pi * 0.95;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
