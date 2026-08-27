import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/glass_box.dart';
import '../../bloc/ride_bloc.dart';

/// SearchingCaptainOverlay — Modernized Searching & Active Ride Overlay according to Stitch design specs.
///
/// Contains 3 consecutive UI states:
/// 1. Initial State: Top centered AppBar "البحث عن كابتن" with back arrow button.
/// 2. Active Searching State: Pulse radar animation + Bottom sheet card with searching status, 2 info columns, price & payment, cancel button, and confirm location main button.
/// 3. Captain Found State: Replaces searching card with captain profile (Honda red motorcycle), plate, rating, circular call button (url_launcher), circular cancel button, and trip details link.
class SearchingCaptainOverlay extends StatefulWidget {
  final VoidCallback onCancel;
  final String? pickup;
  final String? dropoff;
  final String? vehicleTier;
  final double? price;
  final String? captainName;
  final String? captainPhone;
  final String? motorcycleModel;
  final String? licensePlate;
  final double? captainRating;
  final String? eta;
  final bool? forceCaptainFound;

  const SearchingCaptainOverlay({
    super.key,
    required this.onCancel,
    this.pickup,
    this.dropoff,
    this.vehicleTier,
    this.price,
    this.captainName,
    this.captainPhone,
    this.motorcycleModel,
    this.licensePlate,
    this.captainRating,
    this.eta,
    this.forceCaptainFound,
  });

  @override
  State<SearchingCaptainOverlay> createState() =>
      _SearchingCaptainOverlayState();
}

class _SearchingCaptainOverlayState extends State<SearchingCaptainOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Local state flag to simulate switching to Captain Found state for demo/testing
  final bool _simulatedFound = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _callCaptain(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(
        scheme: 'tel', path: cleanPhone.isEmpty ? '+967777123456' : cleanPhone);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint('Could not launch phone dialer: $e');
    }
  }

  void _showTripDetailsModal(
      BuildContext context, bool isDark, String priceStr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: GlassBox(
          borderRadius: AppSpacing.radiusBottomSheet,
          customBgColor: isDark ? const Color(0xFF111827) : Colors.white,
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              AppSpacing.h16,
              Text(
                'تفاصيل الرحلة الحالية',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              AppSpacing.h16,
              _buildDetailItem(
                isDark,
                Icons.my_location_rounded,
                AppColors.success,
                'موقع الانطلاق',
                widget.pickup ?? 'شارع حدة، أمام مركز الكميم',
              ),
              AppSpacing.h12,
              _buildDetailItem(
                isDark,
                Icons.location_on_rounded,
                AppColors.danger,
                'وجهة الوصول',
                widget.dropoff ?? 'جامعة صنعاء - البوابة الرئيسية',
              ),
              AppSpacing.h12,
              _buildDetailItem(
                isDark,
                Icons.payments_rounded,
                AppColors.primary500,
                'إجمالي التكلفة وطريقة الدفع',
                '$priceStr • لَفّة بريميوم (نقداً)',
              ),
              AppSpacing.h24,
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppSpacing.radiusMD,
                    ),
                  ),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      bool isDark, IconData icon, Color iconColor, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        AppSpacing.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<RideBloc, RideState>(
        builder: (context, blocState) {
          final bool isAcceptedFromBloc = blocState is RideAccepted ||
              (blocState is RideBookingConfirmed &&
                  blocState.status == 'found');

          final bool isCaptainFound = widget.forceCaptainFound == true ||
              _simulatedFound ||
              isAcceptedFromBloc;

          // Default fields for mock data if state is missing details
          final String displayCaptainName = widget.captainName ??
              (blocState is RideAccepted ? blocState.captainName : 'أحمد محمد');
          final String displayMotorcycle = widget.motorcycleModel ??
              (blocState is RideAccepted
                  ? blocState.vehicleModel
                  : 'دراجة هوندا - أحمر');
          final String displayPlate = widget.licensePlate ??
              (blocState is RideAccepted
                  ? blocState.vehiclePlate
                  : '10293 صنعاء');
          final double displayRating = widget.captainRating ??
              (blocState is RideAccepted ? blocState.captainRating : 4.9);
          final String displayEta = widget.eta ??
              (blocState is RideAccepted ? blocState.eta : '4 دقائق');
          final String displayPhone = widget.captainPhone ?? '+967777123456';

          final double displayPriceValue = widget.price ?? 2500.0;
          final String priceStr =
              '${displayPriceValue.toStringAsFixed(0)} ريال';

          return Stack(
            children: [
              // Slight background dim to focus on overlay UI without covering map
              Positioned.fill(
                child: Container(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.15),
                ),
              ),

              // ==========================================
              // STATE 1: TOP APPBAR ABOVE MAP
              // Centered Title + Right Back Arrow Button (RTL)
              // ==========================================
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSpacing.s8,
                left: AppSpacing.s16,
                right: AppSpacing.s16,
                child: Row(
                  children: [
                    // Back Arrow Button (Push above Shell)
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1F2937).withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: isDark ? AppColors.white : AppColors.gray900,
                          size: 22,
                        ),
                        onPressed: widget.onCancel,
                      ),
                    ),

                    // Centered Header Title
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s12),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1F2937).withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          isCaptainFound
                              ? 'تم العثور على كابتن'
                              : 'البحث عن كابتن',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.white : AppColors.gray900,
                          ),
                        ),
                      ),
                    ),

                    // Spacer/Empty container for symmetry
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              // ==========================================
              // SEARCHING RADAR PULSE ANIMATION (Center of Map)
              // Only active during Searching State
              // ==========================================
              if (!isCaptainFound)
                Positioned.fill(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 170 * _pulseAnimation.value,
                              height: 170 * _pulseAnimation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    AppColors.primary500.withValues(alpha: 0.12),
                              ),
                            ),
                            Container(
                              width: 115 * _pulseAnimation.value,
                              height: 115 * _pulseAnimation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    AppColors.primary500.withValues(alpha: 0.22),
                              ),
                            ),
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary500,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary500
                                        .withValues(alpha: 0.45),
                                    blurRadius: 24,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.motorcycle_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

              // ==========================================
              // DYNAMIC BOTTOM SHEET CARD (Layer 3)
              // Seamlessly transitions between State 2 & State 3
              // ==========================================
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GlassBox(
                  borderRadius: AppSpacing.radiusBottomSheet,
                  customBgColor: isDark
                      ? const Color(0xFF111827).withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.95),
                  padding: EdgeInsets.only(
                    top: AppSpacing.s16,
                    left: AppSpacing.s20,
                    right: AppSpacing.s20,
                    bottom:
                        MediaQuery.of(context).padding.bottom + AppSpacing.s16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handlebar indicator
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      AppSpacing.h16,

                      // ==========================================
                      // STATE 2: SEARCHING STATE BOTTOM CARD
                      // ==========================================
                      if (!isCaptainFound) ...[
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'جاري البحث عن كابتن...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.gray900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'سنصل إليك قريبًا في صنعاء',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.gray400
                                      : AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        AppSpacing.h16,

                        // 2 Columns Info Row: Captains Nearby + Estimated Arrival
                        Row(
                          children: [
                            // Column 1: Captains Nearby
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.white.withValues(alpha: 0.03)
                                      : AppColors.gray50,
                                  borderRadius: AppSpacing.radiusMD,
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.white
                                            .withValues(alpha: 0.05)
                                        : AppColors.gray200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary500
                                            .withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.motorcycle_rounded,
                                        color: AppColors.primary500,
                                        size: 18,
                                      ),
                                    ),
                                    AppSpacing.w10,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'كابتن بالقرب منك',
                                            style: TextStyle(
                                              fontFamily:
                                                  'IBM Plex Sans Arabic',
                                              fontSize: 10.5,
                                              color: isDark
                                                  ? AppColors.gray400
                                                  : AppColors.gray600,
                                            ),
                                          ),
                                          const Text(
                                            '8 كباتن',
                                            style: TextStyle(
                                              fontFamily:
                                                  'IBM Plex Sans Arabic',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.primary500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            AppSpacing.w12,

                            // Column 2: Estimated Arrival Time
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.white.withValues(alpha: 0.03)
                                      : AppColors.gray50,
                                  borderRadius: AppSpacing.radiusMD,
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.white
                                            .withValues(alpha: 0.05)
                                        : AppColors.gray200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary500
                                            .withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.access_time_rounded,
                                        color: AppColors.primary500,
                                        size: 18,
                                      ),
                                    ),
                                    AppSpacing.w10,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'الوصول المتوقع',
                                            style: TextStyle(
                                              fontFamily:
                                                  'IBM Plex Sans Arabic',
                                              fontSize: 10.5,
                                              color: isDark
                                                  ? AppColors.gray400
                                                  : AppColors.gray600,
                                            ),
                                          ),
                                          const Text(
                                            '5 دقائق',
                                            style: TextStyle(
                                              fontFamily:
                                                  'IBM Plex Sans Arabic',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.primary500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        AppSpacing.h12,

                        // Price & Payment Row
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.white.withValues(alpha: 0.02)
                                : AppColors.gray100,
                            borderRadius: AppSpacing.radiusMD,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.card_membership_rounded,
                                    color: AppColors.primary500,
                                    size: 16,
                                  ),
                                  AppSpacing.w8,
                                  Text(
                                    'طريقة الدفع: لَفّة بريميوم',
                                    style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.gray300
                                          : AppColors.gray800,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                priceStr,
                                style: const TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        AppSpacing.h16,

                        // Full-Width Cancel Ride Action Button
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              context
                                  .read<RideBloc>()
                                  .add(const CancelRideRequested());
                              widget.onCancel();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFF1F2937)
                                  : const Color(0xFFFEE2E2),
                              foregroundColor: AppColors.danger,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppSpacing.radiusMD,
                                side: BorderSide(
                                  color: AppColors.danger.withValues(alpha: 0.4),
                                  width: 1.2,
                                ),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: AppColors.danger,
                                ),
                                AppSpacing.w8,
                                Text(
                                  'إلغاء طلب الرحلة',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // ==========================================
                      // STATE 3: CAPTAIN FOUND STATE BOTTOM CARD
                      // ==========================================
                      if (isCaptainFound) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تم العثور على كابتن',
                                    style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? AppColors.white
                                          : AppColors.gray900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.near_me_rounded,
                                        color: AppColors.primary500,
                                        size: 14,
                                      ),
                                      AppSpacing.w4,
                                      Text(
                                        'يصل خلال $displayEta',
                                        style: const TextStyle(
                                          fontFamily: 'IBM Plex Sans Arabic',
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Action Buttons: Small Circular Cancel Button (X) + Circular Phone Call Button
                            Row(
                              children: [
                                // Small Circular Cancel Button (X)
                                GestureDetector(
                                  onTap: widget.onCancel,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : AppColors.gray100,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.1)
                                            : AppColors.gray300,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 20,
                                      color: isDark
                                          ? AppColors.white
                                          : AppColors.gray800,
                                    ),
                                  ),
                                ),

                                AppSpacing.w10,

                                // Circular Phone Call Button
                                GestureDetector(
                                  onTap: () => _callCaptain(displayPhone),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF22C55E)
                                              .withValues(alpha: 0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.call_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        AppSpacing.h16,

                        // Captain Information Card
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.white.withValues(alpha: 0.03)
                                : AppColors.gray50,
                            borderRadius: AppSpacing.radiusMD,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.white.withValues(alpha: 0.05)
                                  : AppColors.gray200,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Captain Avatar Image (Circular)
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary500,
                                    width: 2,
                                  ),
                                  color: AppColors.primary500
                                      .withValues(alpha: 0.15),
                                ),
                                child: const CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: AppColors.primary500,
                                    size: 32,
                                  ),
                                ),
                              ),

                              AppSpacing.w12,

                              // Captain Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          displayCaptainName,
                                          style: TextStyle(
                                            fontFamily: 'IBM Plex Sans Arabic',
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w900,
                                            color: isDark
                                                ? AppColors.white
                                                : AppColors.gray900,
                                          ),
                                        ),
                                        AppSpacing.w8,
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary500
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star_rounded,
                                                color: AppColors.primary500,
                                                size: 13,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                displayRating
                                                    .toStringAsFixed(1),
                                                style: const TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    AppSpacing.h4,

                                    // Bike Model & Color (Motorcycle identity)
                                    Text(
                                      displayMotorcycle,
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.gray400
                                            : AppColors.gray600,
                                      ),
                                    ),

                                    AppSpacing.h6,

                                    // License Plate
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.1)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white24
                                              : Colors.black26,
                                        ),
                                      ),
                                      child: Text(
                                        displayPlate,
                                        style: TextStyle(
                                          fontFamily: 'IBM Plex Sans Arabic',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: isDark
                                              ? AppColors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        AppSpacing.h12,

                        // Bottom Row: Price + Payment Method + Details Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  priceStr,
                                  style: const TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary500,
                                  ),
                                ),
                                Text(
                                  'طريقة الدفع: لَفّة بريميوم (نقداً)',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.gray400
                                        : AppColors.gray600,
                                  ),
                                ),
                              ],
                            ),

                            // "التفاصيل" Link / Button
                            TextButton.icon(
                              onPressed: () => _showTripDetailsModal(
                                  context, isDark, priceStr),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary500,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                              ),
                              icon: const Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                'التفاصيل',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
