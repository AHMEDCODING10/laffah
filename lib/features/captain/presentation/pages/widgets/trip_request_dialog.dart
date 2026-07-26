import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

/// TripRequestDialog - High-fidelity Glassmorphic overlay for incoming Captain ride requests.
/// Features a 15-second animated countdown ring, Yemeni Rial pricing, distance/time specs,
/// and large ergonomic action buttons for single-handed motorcycle operation.
class TripRequestDialog extends StatefulWidget {
  final String passengerName;
  final double passengerRating;
  final String pickup;
  final String dropoff;
  final double fare;
  final String distance;
  final String duration;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const TripRequestDialog({
    super.key,
    required this.passengerName,
    required this.passengerRating,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distance,
    required this.duration,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<TripRequestDialog> createState() => _TripRequestDialogState();
}

class _TripRequestDialogState extends State<TripRequestDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  Timer? _countdownTimer;
  int _secondsRemaining = 15;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        widget.onReject();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 88), // Extra bottom padding for floating bar
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                blurRadius: 28,
                spreadRadius: 4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s20),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141822).withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFFF6B00).withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Badge & Countdown Progress Ring
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.s8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B00).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.two_wheeler_rounded,
                                color: Color(0xFFFF6B00),
                                size: 22,
                              ),
                            ),
                            AppSpacing.w10,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B00).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Text(
                                'طلب مشوار جديد ⚡',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFF6B00),
                                  fontFamily: 'IBM Plex Sans Arabic',
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Countdown ring
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 42,
                              height: 42,
                              child: CircularProgressIndicator(
                                value: _secondsRemaining / 15.0,
                                strokeWidth: 4.0,
                                backgroundColor: isDark ? AppColors.gray800 : AppColors.gray200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _secondsRemaining <= 5 ? AppColors.danger : const Color(0xFFFF6B00),
                                ),
                              ),
                            ),
                            Text(
                              '$_secondsRemaining',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                color: _secondsRemaining <= 5 ? AppColors.danger : (isDark ? Colors.white : AppColors.gray900),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    AppSpacing.h16,

                    // Passenger Info & Fare Row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFFF6B00).withValues(alpha: 0.2),
                          child: Text(
                            widget.passengerName.isNotEmpty ? widget.passengerName[0] : 'ع',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF6B00),
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ),
                        AppSpacing.w12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.passengerName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  color: isDark ? Colors.white : AppColors.gray900,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                  AppSpacing.w4,
                                  Text(
                                    '${widget.passengerRating} ★',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B00).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFFF6B00).withValues(alpha: 0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'الأجرة المتوقعة',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  color: Color(0xFFFF6B00),
                                ),
                              ),
                              Text(
                                '${widget.fare.toStringAsFixed(0)} ر.ي',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFF6B00),
                                  fontFamily: 'IBM Plex Sans Arabic',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.h16,

                    // Pickup & Dropoff Route Details
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : AppColors.gray50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Pickup Location
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              AppSpacing.w12,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'نقطة الانطلاق (A)',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontFamily: 'IBM Plex Sans Arabic',
                                      ),
                                    ),
                                    Text(
                                      widget.pickup,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        color: isDark ? Colors.white : AppColors.gray900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                width: 2,
                                height: 16,
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                            ),
                          ),

                          // Dropoff Location
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              AppSpacing.w12,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'وجهة الوصول (B)',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                        fontFamily: 'IBM Plex Sans Arabic',
                                      ),
                                    ),
                                    Text(
                                      widget.dropoff,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        color: isDark ? Colors.white : AppColors.gray900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.h12,

                    // Specs Bento Row (Distance & Time)
                    Row(
                      children: [
                        Expanded(
                          child: _buildSpecCard(
                            isDark,
                            Icons.map_rounded,
                            'المسافة الفردية',
                            widget.distance,
                          ),
                        ),
                        AppSpacing.w12,
                        Expanded(
                          child: _buildSpecCard(
                            isDark,
                            Icons.schedule_rounded,
                            'الزمان المقدر',
                            widget.duration,
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.h16,

                    // Action Buttons (Reject / Accept)
                    Row(
                      children: [
                        // Reject Button
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                widget.onReject();
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.danger,
                                side: const BorderSide(color: AppColors.danger, width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'رفض',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),

                        AppSpacing.w12,

                        // Accept Button
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.heavyImpact();
                                widget.onAccept();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B00),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: const Color(0xFFFF6B00).withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.flash_on_rounded, size: 20),
                              label: const Text(
                                'قبول الطلب الآن',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14.5,
                                ),
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
    );
  }

  Widget _buildSpecCard(bool isDark, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFF6B00)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.gray500,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: isDark ? Colors.white : AppColors.gray900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
