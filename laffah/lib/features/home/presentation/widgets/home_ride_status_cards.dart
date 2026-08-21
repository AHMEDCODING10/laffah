import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../ride/presentation/bloc/ride_bloc.dart';

/// CaptainFoundCard — Overlay card displayed when a captain accepts the passenger's ride request.
class CaptainFoundCard extends StatelessWidget {
  final RideBookingConfirmed state;

  const CaptainFoundCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: GlassBox(
        borderRadius: AppSpacing.radiusLG,
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'تم قبول طلب لَفّتك بنجاح!',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                ),
                AppSpacing.w8,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: AppSpacing.radiusXS,
                  ),
                  child: const Text(
                    'الكابتن قادم إليك',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.h16,
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primary500,
                    size: 28,
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.captainName,
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                        ),
                      ),
                      AppSpacing.h4,
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.warning,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${state.rating.toStringAsFixed(1)} • ${state.vehicleModel}',
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
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.04)
                        : AppColors.gray100,
                    borderRadius: AppSpacing.radiusSM,
                  ),
                  child: Text(
                    state.vehiclePlate,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.h16,
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final Uri smsUri = Uri(
                        scheme: 'sms',
                        path: '+967700000000', // Mock Captain Number
                      );
                      if (await canLaunchUrl(smsUri)) {
                        await launchUrl(smsUri);
                      }
                    },
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                    ),
                    label: const Text(
                      'مراسلة الكابتن',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: AppColors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppSpacing.radiusSM,
                      ),
                    ),
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final Uri telUri = Uri(
                        scheme: 'tel',
                        path: '+967700000000', // Mock Captain Number
                      );
                      if (await canLaunchUrl(telUri)) {
                        await launchUrl(telUri);
                      }
                    },
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                    label: const Text(
                      'اتصال مباشر',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppSpacing.radiusSM,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// RideInProgressCard — Overlay card displayed while trip is in progress.
class RideInProgressCard extends StatelessWidget {
  final RideBookingConfirmed state;

  const RideInProgressCard({
    super.key,
    required this.state,
  });

  Future<void> _makeCall(String phone) async {
    final clean = phone.isNotEmpty ? phone : '770000000';
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendSms(String phone) async {
    final clean = phone.isNotEmpty ? phone : '770000000';
    final uri = Uri.parse('sms:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vehicleModel = state.vehicleModel.isNotEmpty ? state.vehicleModel : 'دراجة نارية';
    final vehiclePlate = state.vehiclePlate.isNotEmpty ? state.vehiclePlate : 'صنعاء';
    final destination = state.dropoff.isNotEmpty ? state.dropoff : 'وجهة الوصول';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        child: GlassBox(
          borderRadius: AppSpacing.radiusLG,
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.navigation_rounded,
                          color: AppColors.primary500,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'رحلتك الحالية مستمرة 🚀',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary500.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text(
                      'في الطريق للوجهة',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: AppColors.primary500,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.h12,
              // Destination Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF161B26)
                      : AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary500,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        destination,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.gray200 : AppColors.gray800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.h12,
              // Captain Profile Row
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary500, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.two_wheeler_rounded,
                      color: AppColors.primary500,
                      size: 24,
                    ),
                  ),
                  AppSpacing.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.captainName,
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.warning,
                              size: 14,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${state.rating.toStringAsFixed(1)} • $vehicleModel ($vehiclePlate)',
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
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.primary500,
                      size: 22,
                    ),
                    tooltip: 'مراسلة',
                    onPressed: () => _sendSms(state.captainPhone),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.phone_in_talk_rounded,
                      color: AppColors.success,
                      size: 22,
                    ),
                    tooltip: 'اتصال',
                    onPressed: () => _makeCall(state.captainPhone),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// RideCompletedCard — Ultra-modern invoice card displayed upon ride completion with interactive 5-star rating.
class RideCompletedCard extends StatefulWidget {
  final RideBookingConfirmed state;

  const RideCompletedCard({
    super.key,
    required this.state,
  });

  @override
  State<RideCompletedCard> createState() => _RideCompletedCardState();
}

class _RideCompletedCardState extends State<RideCompletedCard> {
  double _ratingSelected = 5.0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = widget.state;
    final captainName = state.captainName.isNotEmpty ? state.captainName : 'كابتن لَفَّة';
    final fare = state.selectedOption.basePrice;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        child: GlassBox(
          borderRadius: AppSpacing.radiusLG,
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'وصلت بحمد الله وتوفيقه! 🎉',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Fare Breakdown Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary500.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'إجمالي أجرة المشوار:',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${fare.toStringAsFixed(0)} ريال يمني',
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'كيف كانت تجربتك مع $captainName؟',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
              ),
              AppSpacing.h8,
              // Interactive 5-Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starVal = index + 1.0;
                  return IconButton(
                    icon: Icon(
                      _ratingSelected >= starVal
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: const Color(0xFFFFB800),
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() {
                        _ratingSelected = starVal;
                      });
                    },
                  );
                }),
              ),
              AppSpacing.h12,
              // Optional Review Note Field
              TextField(
                controller: _reviewController,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12.5,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
                decoration: InputDecoration(
                  hintText: 'أضف كلمة شكر أو ملاحظة للكابتن (اختياري)...',
                  hintStyle: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11.5,
                    color: AppColors.gray400,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF161B26)
                      : AppColors.gray100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              AppSpacing.h16,
              // Submit Rating Button
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _isSubmitting = true;
                          });
                          final tripId = widget.state.rideId ?? '1';
                          context.read<RideBloc>().add(SubmitTripRating(
                                tripId: tripId,
                                rating: _ratingSelected,
                                review: _reviewController.text.trim().isNotEmpty
                                    ? _reviewController.text.trim()
                                    : null,
                              ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'شكرًا لتقييمك! تم إرسال التقييم بنجاح.',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'إرسال التقييم وإنهاء المشوار',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
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
}

/// ParcelSubmittedCard — Overlay card displayed after parcel submission confirmation.
class ParcelSubmittedCard extends StatelessWidget {
  final ParcelSubmitted state;

  const ParcelSubmittedCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: GlassBox(
        borderRadius: AppSpacing.radiusLG,
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: AppColors.primary500,
                    size: 48,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'تم تسجيل طلب الطرد بنجاح!',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.h16,
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark.withValues(alpha: 0.5)
                    : AppColors.gray50,
                borderRadius: AppSpacing.radiusSM,
                border: Border.all(
                  color: isDark
                      ? AppColors.white.withValues(alpha: 0.05)
                      : AppColors.gray200,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'رقم تتبع الطرد الموحد:',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        state.trackingId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary500,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.h8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'اسم مستلم الشحنة:',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        state.data.receiverName,
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.h16,
            ElevatedButton(
              onPressed: () {
                context.read<RideBloc>().add(const CancelRideRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppSpacing.radiusSM,
                ),
              ),
              child: const Text(
                'العودة للقائمة الرئيسية',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
