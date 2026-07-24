import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/glass_box.dart';
import '../../../../../core/widgets/captain_action_button.dart';

/// TripRequestDialog - Premium Glassmorphic overlay with active countdown timer & Android ergonomics.
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
      duration: const Duration(milliseconds: 400),
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
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s20),
          child: GlassBox(
            borderRadius: AppSpacing.radiusXL,
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with Badge & Countdown Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s8),
                          decoration: BoxDecoration(
                            color: AppColors.primary500.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.motorcycle_rounded,
                            color: AppColors.primary500,
                            size: 22,
                          ),
                        ),
                        AppSpacing.w10,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s6),
                          decoration: BoxDecoration(
                            color: AppColors.primary500.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'طلب لَفَّة جديد',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary500,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Countdown circle timer
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 38,
                          height: 38,
                          child: CircularProgressIndicator(
                            value: _secondsRemaining / 15.0,
                            strokeWidth: 3.5,
                            backgroundColor: isDark ? AppColors.gray800 : AppColors.gray200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _secondsRemaining <= 5 ? AppColors.danger : AppColors.primary500,
                            ),
                          ),
                        ),
                        Text(
                          '$_secondsRemaining',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _secondsRemaining <= 5 ? AppColors.danger : (isDark ? Colors.white : AppColors.gray900),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                AppSpacing.h16,

                // Passenger Info Tile
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary500.withOpacity(0.2),
                      child: Text(
                        widget.passengerName.isNotEmpty ? widget.passengerName[0] : 'ع',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary500,
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                              AppSpacing.w4,
                              Text(
                                '${widget.passengerRating}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${widget.fare.toStringAsFixed(0)} ر.ي',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary500,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ],
                ),

                AppSpacing.h16,

                // Route representation
                Column(
                  children: [
                    // Pickup
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.primary500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpacing.w12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'نقطة الاستلام',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gray500,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                ),
                              ),
                              Text(
                                widget.pickup,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Dashed connector
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 2,
                            height: 20,
                            color: isDark ? AppColors.white.withOpacity(0.12) : AppColors.gray300,
                          ),
                        ],
                      ),
                    ),

                    // Dropoff
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.info,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpacing.w12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'الوجهة',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gray500,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                ),
                              ),
                              Text(
                                widget.dropoff,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                AppSpacing.h16,

                // Spec row (Distance, Time)
                Row(
                  children: [
                    Expanded(
                      child: _buildSpecCard(
                        context,
                        isDark,
                        Icons.map_rounded,
                        'المسافة',
                        widget.distance,
                      ),
                    ),
                    AppSpacing.w12,
                    Expanded(
                      child: _buildSpecCard(
                        context,
                        isDark,
                        Icons.schedule_rounded,
                        'الوقت المقدر',
                        widget.duration,
                      ),
                    ),
                  ],
                ),

                AppSpacing.h20,

                // Ergonomic Buttons (Accept / Reject) with Haptic Feedback
                Row(
                  children: [
                    // Reject Button
                    Expanded(
                      child: CaptainActionButton(
                        label: 'رفض',
                        isOutlined: true,
                        backgroundColor: AppColors.danger,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onReject();
                        },
                      ),
                    ),
                    
                    AppSpacing.w16,

                    // Accept Button
                    Expanded(
                      flex: 2,
                      child: CaptainActionButton(
                        label: 'قبول الطلب',
                        icon: Icons.check_circle_rounded,
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          widget.onAccept();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper builder for specs bento cards
  Widget _buildSpecCard(BuildContext context, bool isDark, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s10, horizontal: AppSpacing.s8),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.white.withOpacity(0.04) 
            : AppColors.gray100.withOpacity(0.8),
        borderRadius: AppSpacing.borderLG,
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray200,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.primary500,
          ),
          AppSpacing.w8,
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
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
