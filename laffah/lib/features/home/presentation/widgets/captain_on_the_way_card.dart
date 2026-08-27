import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../ride/presentation/bloc/ride_bloc.dart';

/// CaptainOnTheWayCard — Ultra-modern, compact floating card displayed at the bottom of Passenger Home Map.
/// Dynamically adapts between:
/// 1. 'accepted' -> Orange theme: "تم قبول المشوار 🛵" + ETA badge
/// 2. 'arrived'  -> Emerald Green theme: "وصل الكابتن إلى موقعك! 📍" + Arrival notice banner + Direct Call
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
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.35),
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
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: Text(
            widget.state.status == 'arrived'
                ? 'الكابتن وصل بالفعل وينتظرك عند نقطة الانطلاق. هل أنت متأكد من رغبتك في الإلغاء؟'
                : 'هل أنت متأكد من إلغاء المشوار؟ الكابتن في طريقه إليك الآن.',
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 13,
              height: 1.4,
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
                context.read<RideBloc>().add(
                      CancelRideRequested(
                        tripId: widget.state.rideId,
                        reason: 'إلغاء من قبل الراكب أثناء انتظار الكابتن',
                      ),
                    );
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
    final s = state.status.toLowerCase();
    final isArrived = s == 'arrived';
    final isInTransit = s == 'in_transit' || s == 'started' || s == 'in_progress';

    final Color primaryColor =
        isArrived ? const Color(0xFF00C853) : AppColors.primary500;
    final captainName =
        state.captainName.isNotEmpty && state.captainName != 'قيد البحث'
            ? state.captainName
            : 'علي صالح صالح';
    final vehicleModel =
        state.vehicleModel.isNotEmpty ? state.vehicleModel : 'غير محدد';
    final vehiclePlate =
        state.vehiclePlate.isNotEmpty ? state.vehiclePlate : 'ا ب ج';

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: EdgeInsets.fromLTRB(14, 0, 14, bottomPadding > 0 ? bottomPadding + 12 : 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isArrived
                      ? const Color(0xFF00C853).withValues(alpha: isDark ? 0.25 : 0.15)
                      : Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                  spreadRadius: isArrived ? 2 : 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF161B26).withValues(alpha: 0.97)
                        : Colors.white.withValues(alpha: 0.98),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isArrived
                          ? const Color(0xFF00C853).withValues(alpha: 0.5)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : AppColors.primary500.withValues(alpha: 0.25)),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ─── 1. Top Header: Status Tag & Arrival Timer ───
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Status Badge (Right in RTL)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4.5),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.35),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isArrived
                                      ? Icons.where_to_vote_rounded
                                      : (isInTransit
                                          ? Icons.rocket_launch_rounded
                                          : Icons.check_circle_rounded),
                                  color: primaryColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isArrived
                                      ? 'وصل الكابتن إلى موقعك! 📍'
                                      : (isInTransit
                                          ? 'في الطريق إلى الوجهة 🚀'
                                          : 'تم قبول المشوار 🛵'),
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ETA / Waiting Tag (Left in RTL)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4.5),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isArrived
                                      ? Icons.timer_outlined
                                      : (isInTransit
                                          ? Icons.near_me_rounded
                                          : Icons.access_time_filled_rounded),
                                  color: primaryColor,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isArrived
                                      ? 'بانتظارك الآن'
                                      : (isInTransit ? 'الوصول: ~8 د' : 'الوصول: ~3 د'),
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Arrival Notice Banner when Captain arrives at pickup
                      if (isArrived) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF00C853).withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: Color(0xFF00C853), size: 14),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'الكابتن وصل لنقطة الانطلاق وينتظرك، يرجى التوجه للدراجة النارية.',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00C853),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // ─── 2. Captain Profile (Avatar on Right, Details Middle, Plate on Left in RTL) ───
                      Row(
                        children: [
                          // 1. Captain Avatar (Right in RTL)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: primaryColor,
                                  size: 26,
                                ),
                              ),
                              Positioned(
                                bottom: -1,
                                right: -1,
                                child: Container(
                                  padding: const EdgeInsets.all(2.5),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF161B26)
                                          : Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.two_wheeler_rounded,
                                    color: Colors.white,
                                    size: 9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),

                          // 2. Captain Details (Middle in RTL)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  captainName,
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.gray900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFFFB800),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      state.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.gray900,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text('•',
                                        style: TextStyle(color: AppColors.gray400)),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        vehicleModel,
                                        style: TextStyle(
                                          fontFamily: 'IBM Plex Sans Arabic',
                                          fontSize: 11,
                                          color: isDark
                                              ? AppColors.gray400
                                              : AppColors.gray600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 3. Plate Number Tag (Left in RTL)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1C2230)
                                  : AppColors.gray100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : AppColors.gray300,
                              ),
                            ),
                            child: Text(
                              vehiclePlate,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.gray300
                                    : AppColors.gray800,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Divider(
                        height: 1,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : AppColors.gray200,
                      ),
                      const SizedBox(height: 8),

                      // ─── 3. Destination & Fare Summary (Destination on Right, Fare on Left in RTL) ───
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Destination (Right in RTL)
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    state.dropoff.isNotEmpty
                                        ? state.dropoff
                                        : 'الوجهة المحددة',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.gray200
                                          : AppColors.gray800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Fare (Left in RTL)
                          Text(
                            '${state.selectedOption.basePrice.toStringAsFixed(0)} ر.ي',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ─── 4. Action Buttons (Call Button on Right, Chat in Middle, Cancel/SOS on Left in RTL) ───
                      Row(
                        children: [
                          // Call Captain Button (Primary Action on Right in RTL)
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _makePhoneCall(state.captainPhone),
                                icon: const Icon(Icons.phone_in_talk_rounded,
                                    size: 16),
                                label: Text(
                                  isArrived
                                      ? 'اتصال فوري بالكابتن'
                                      : 'اتصال بالكابتن',
                                  style: const TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Message Button (💬) in Middle
                          InkWell(
                            onTap: () => _sendSms(state.captainPhone),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: primaryColor,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Cancel Button / Safety SOS (Left in RTL)
                          InkWell(
                            onTap: () {
                              if (isInTransit) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('خدمة الطوارئ والأمان نشطة على مدار الساعة 🛡️',
                                        style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                                  ),
                                );
                              } else {
                                _confirmCancel(context);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.danger.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                isInTransit ? Icons.shield_outlined : Icons.close_rounded,
                                color: AppColors.danger,
                                size: 18,
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
