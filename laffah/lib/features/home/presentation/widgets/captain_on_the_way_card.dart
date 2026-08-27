import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../ride/presentation/bloc/ride_bloc.dart';

/// CaptainOnTheWayCard — Ultra-modern floating glassmorphic card displayed on the Passenger Home Map.
/// Dynamically adapts between:
/// 1. 'accepted' -> Orange theme: "الكابتن في الطريق إليك 🛵" + ETA badge
/// 2. 'arrived'  -> Emerald Green theme: "وصل الكابتن إلى موقعك! 📍" + Pulsing beacon + Direct Call
class CaptainOnTheWayCard extends StatefulWidget {
  final RideBookingConfirmed state;

  const CaptainOnTheWayCard({
    super.key,
    required this.state,
  });

  @override
  State<CaptainOnTheWayCard> createState() => _CaptainOnTheWayCardState();
}

class _CaptainOnTheWayCardState extends State<CaptainOnTheWayCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
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

  Future<void> _makePhoneCall(String phone) async {
    HapticFeedback.heavyImpact();
    final cleanPhone = phone.isNotEmpty ? phone : '770000000';
    final Uri url = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _sendSms(String phone) async {
    HapticFeedback.lightImpact();
    final cleanPhone = phone.isNotEmpty ? phone : '770000000';
    final Uri url = Uri.parse('sms:$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _confirmCancel(BuildContext context) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1B2232) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'إلغاء المشوار',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          content: Text(
            widget.state.status == 'arrived'
                ? 'الكابتن وصل بالفعل وينتظرك عند نقطة الانطلاق. هل أنت متأكد من رغبتك في الإلغاء؟'
                : 'هل أنت متأكد من إلغاء المشوار؟ الكابتن في طريقه إليك الآن.',
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'تراجع',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<RideBloc>().add(const CancelRideRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'تأكيد الإلغاء',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = widget.state;
    final isArrived = state.status.toLowerCase() == 'arrived';

    final Color primaryColor = isArrived ? const Color(0xFF00C853) : AppColors.primary500;
    final captainName = state.captainName.isNotEmpty && state.captainName != 'قيد البحث'
        ? state.captainName
        : 'كابتن لَفَّة';
    final vehicleModel = state.vehicleModel.isNotEmpty ? state.vehicleModel : 'دراجة نارية';
    final vehiclePlate = state.vehiclePlate.isNotEmpty ? state.vehiclePlate : 'صنعاء • 1245';

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
                  color: isArrived
                      ? const Color(0xFF00C853).withValues(alpha: isDark ? 0.35 : 0.22)
                      : Colors.black.withValues(alpha: isDark ? 0.5 : 0.16),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                  spreadRadius: isArrived ? 3 : 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1B2232).withValues(alpha: 0.96)
                        : Colors.white.withValues(alpha: 0.98),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isArrived
                          ? const Color(0xFF00C853).withValues(alpha: 0.7)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : AppColors.primary500.withValues(alpha: 0.3)),
                      width: isArrived ? 2.0 : 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ─── Top Status Badge: Dynamic Arrived vs On The Way ───
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: isArrived ? 0.16 : 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: isArrived ? 0.6 : 0.35),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isArrived
                                      ? Icons.where_to_vote_rounded
                                      : Icons.check_circle_rounded,
                                  color: primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isArrived
                                      ? 'وصل الكابتن إلى موقعك! 📍'
                                      : 'تم قبول المشوار 🛵',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Secondary ETA or Arrival Guidance Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isArrived
                                  ? const Color(0xFF00C853).withValues(alpha: 0.1)
                                  : AppColors.primary500.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isArrived
                                      ? Icons.timer_outlined
                                      : Icons.access_time_filled_rounded,
                                  color: primaryColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isArrived ? 'بانتظارك الآن' : 'الوصول: ~3 د',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Arrival Notice Banner when Captain is at pickup
                      if (isArrived) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00C853).withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: Color(0xFF00C853), size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'الكابتن وصل لنقطة الانطلاق وينتظرك، يرجى التوجه للدراجة النارية.',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF00C853),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // ─── Captain Profile Row: Avatar + Name + Rating + Motorcycle Badge ───
                      Row(
                        children: [
                          // Captain Avatar / Motorcycle Badge
                          Stack(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: primaryColor,
                                  size: 32,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.two_wheeler_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.w12,
                          // Captain Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  captainName,
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? AppColors.white
                                        : AppColors.gray900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFFFB800),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      state.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.white
                                            : AppColors.gray900,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '• $vehicleModel',
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.gray400
                                            : AppColors.gray600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Plate Number Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF131824)
                                  : AppColors.gray100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isArrived
                                    ? const Color(0xFF00C853).withValues(alpha: 0.5)
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : AppColors.gray300),
                              ),
                            ),
                            child: Text(
                              vehiclePlate,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
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

                      // ─── Destination & Fare Summary ───
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: primaryColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    state.dropoff.isNotEmpty
                                        ? state.dropoff
                                        : 'الوجهة المحددة',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.gray300
                                          : AppColors.gray800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${state.selectedOption.basePrice.toStringAsFixed(0)} ر.ي',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ─── Action Buttons: Call Captain | Message | Cancel ───
                      Row(
                        children: [
                          // Call Button
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: () => _makePhoneCall(state.captainPhone),
                              icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                              label: Text(
                                isArrived ? 'اتصال فوري بالكابتن' : 'اتصال بالكابتن',
                                style: const TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.w8,
                          // Message Button
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF263044)
                                  : AppColors.gray100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: primaryColor,
                                size: 20,
                              ),
                              tooltip: 'مراسلة الكابتن',
                              onPressed: () => _sendSms(state.captainPhone),
                            ),
                          ),
                          AppSpacing.w8,
                          // Cancel Button
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF263044)
                                  : AppColors.gray100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              tooltip: 'إلغاء المشوار',
                              onPressed: () => _confirmCancel(context),
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
