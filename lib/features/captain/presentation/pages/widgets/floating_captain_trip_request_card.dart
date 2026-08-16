import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

/// FloatingCaptainTripRequestCard — Ultra-modern floating glassmorphic card for incoming ride requests.
/// Displays directly above the Captain's bottom navigation bar on the interactive map.
/// Uses ONLY motorcycle icon (دراجة نارية) and matches the notification card layout 100%.
class FloatingCaptainTripRequestCard extends StatefulWidget {
  final String tripId;
  final String passengerName;
  final double passengerRating;
  final String pickup;
  final String dropoff;
  final double fare;
  final String distance;
  final String duration;
  final String timeTag;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const FloatingCaptainTripRequestCard({
    super.key,
    required this.tripId,
    required this.passengerName,
    this.passengerRating = 5.0,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distance,
    required this.duration,
    this.timeTag = 'منذ ثواني',
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<FloatingCaptainTripRequestCard> createState() =>
      _FloatingCaptainTripRequestCardState();
}

class _FloatingCaptainTripRequestCardState
    extends State<FloatingCaptainTripRequestCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.14),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1B2232).withValues(alpha: 0.95)
                        : Colors.white.withValues(alpha: 0.98),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFFFF6B00).withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ─── Header: Title + Motorcycle Icon + Rating + Time ───
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Motorcycle Icon in Orange Circle (دراجة فقط)
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B00).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.two_wheeler_rounded,
                              color: Color(0xFFFF6B00),
                              size: 26,
                            ),
                          ),
                          AppSpacing.w12,
                          // Title & Passenger Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'طلب مشوار جديد 🛵',
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFFF6B00),
                                      ),
                                    ),
                                    // Time Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF263044)
                                            : AppColors.gray100,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        widget.timeTag,
                                        style: TextStyle(
                                          fontFamily: 'IBM Plex Sans Arabic',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.gray400
                                              : AppColors.gray600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFFFB800),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      widget.passengerRating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.white
                                            : AppColors.gray900,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.person_rounded,
                                      color: AppColors.gray400,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      widget.passengerName,
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.gray300
                                            : AppColors.gray700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      Divider(
                        height: 1,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.gray200,
                      ),
                      const SizedBox(height: 12),

                      // ─── Route: Current Location -> Destination ───
                      Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueAccent,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 22,
                                color: isDark ? AppColors.gray600 : AppColors.gray300,
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFF6B00),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.pickup.isNotEmpty
                                      ? widget.pickup
                                      : 'موقعك الحالي',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.gray300
                                        : AppColors.gray700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.dropoff.isNotEmpty
                                      ? widget.dropoff
                                      : 'الوجهة المحددة',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? AppColors.white
                                        : AppColors.gray900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ─── Specs & Fare Row: Distance | Duration | Price (YER) ───
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF131824)
                              : const Color(0xFFFFF7F0),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFF6B00).withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Distance
                            Row(
                              children: [
                                const Icon(Icons.route_rounded,
                                    size: 16, color: AppColors.gray500),
                                const SizedBox(width: 4),
                                Text(
                                  widget.distance,
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.gray300
                                        : AppColors.gray800,
                                  ),
                                ),
                              ],
                            ),
                            // Duration
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded,
                                    size: 16, color: AppColors.gray500),
                                const SizedBox(width: 4),
                                Text(
                                  widget.duration,
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.gray300
                                        : AppColors.gray800,
                                  ),
                                ),
                              ],
                            ),
                            // Fare in YER
                            Row(
                              children: [
                                Text(
                                  widget.fare.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFF6B00),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Text(
                                  'ر.ي',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF6B00),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ─── Action Buttons: Accept (Large Orange) & Reject ───
                      Row(
                        children: [
                          // Reject Button
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                widget.onReject();
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.redAccent.withValues(alpha: 0.5)
                                      : Colors.redAccent.withValues(alpha: 0.4),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'رفض',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.w12,
                          // Accept Button (Expanded & Prominent)
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.heavyImpact();
                                widget.onAccept();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B00),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'قبول المشوار',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
