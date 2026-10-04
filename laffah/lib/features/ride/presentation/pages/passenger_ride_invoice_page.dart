import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/ride_bloc.dart';

/// PassengerRideInvoicePage — Premium visual trip summary and rating screen for passengers.
/// Matches the unified aesthetic of Laffah and includes full trip details, interactive 5-star rating,
/// and smooth return to the main passenger home dashboard.
class PassengerRideInvoicePage extends StatefulWidget {
  final double fare;
  final String tripId;
  final String captainName;
  final String captainPhone;
  final String vehicleModel;
  final String vehiclePlate;
  final String pickup;
  final String dropoff;
  final String distance;
  final String duration;
  final String paymentMethod;
  final double discount;
  final double rating;

  const PassengerRideInvoicePage({
    super.key,
    required this.fare,
    required this.tripId,
    required this.captainName,
    this.captainPhone = '',
    this.vehicleModel = 'دراجة نارية',
    this.vehiclePlate = 'صنعاء',
    this.pickup = 'موقعك الحالي',
    this.dropoff = 'الوجهة المحددة',
    this.distance = '6.3 كم',
    this.duration = '7 دقيقة',
    this.paymentMethod = 'نقداً (Cash)',
    this.discount = 0.0,
    this.rating = 5.0,
  });

  @override
  State<PassengerRideInvoicePage> createState() =>
      _PassengerRideInvoicePageState();
}

class _PassengerRideInvoicePageState extends State<PassengerRideInvoicePage> {
  double _selectedRating = 5.0;
  final Set<String> _selectedFeedbackChips = {};
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitted = false;

  final List<String> _feedbackOptions = [
    'سائق محترم 🤝',
    'التزام بالوقت ⏱️',
    'قيادة آمنة ومريحة 🛡️',
    'مركبة نظيفة ✨',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _onFinish() {
    HapticFeedback.mediumImpact();
    // Reset passenger ride bloc state cleanly
    context.read<RideBloc>().add(const ResetRideState());
    context.go(LaffahRoutes.passengerHome);
  }

  void _submitRating() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSubmitted = true;
    });

    final comment = [
      if (_selectedFeedbackChips.isNotEmpty) _selectedFeedbackChips.join(' • '),
      if (_commentController.text.trim().isNotEmpty) _commentController.text.trim(),
    ].join('\n');

    context.read<RideBloc>().add(RateTripRequested(
          tripId: widget.tripId,
          rating: _selectedRating,
          comment: comment.isNotEmpty ? comment : 'خدمة ممتازة',
        ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.success,
        content: Text(
          'شكراً لتقييمك! نسعد دائماً بخدمتك في لَفَّة.',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalFare = (widget.fare - widget.discount).clamp(0.0, double.infinity);
    final pickupName = widget.pickup.split('،').first.trim();
    final dropoffName = widget.dropoff.split('،').first.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F1116) : const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            'ملخص الرحلة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s20, vertical: AppSpacing.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.h12,

              // Success circular badge
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: const BoxDecoration(
                      color: AppColors.primary500,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),

              AppSpacing.h16,

              // Success title and subtitle
              const Text(
                'تمت الرحلة بنجاح',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              AppSpacing.h6,
              const Text(
                'شكراً لاختيارك لَفَّة! نتمنى لك يوماً سعيداً وممتعاً.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray500,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),

              AppSpacing.h24,

              // Invoice Details Glass Box Card
              GlassBox(
                borderRadius: AppSpacing.radiusLG,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s20, vertical: AppSpacing.s20),
                child: Column(
                  children: [
                    const Text(
                      'إجمالي قيمة المشوار',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray500,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                    AppSpacing.h4,
                    Text(
                      '${totalFare.toStringAsFixed(0)} ريال',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary500,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s14),
                      child: Divider(height: 1),
                    ),

                    _buildInvoiceRow('طريقة الدفع', widget.paymentMethod),
                    AppSpacing.h10,
                    _buildInvoiceRow('المسافة', widget.distance),
                    AppSpacing.h10,
                    _buildInvoiceRow('وقت الرحلة',
                        widget.duration.endsWith(' د')
                            ? widget.duration.replaceAll(' د', ' دقيقة')
                            : widget.duration),
                    AppSpacing.h10,
                    _buildInvoiceRow('المسار',
                        'من ${pickupName.isNotEmpty ? pickupName : 'موقعك'} إلى ${dropoffName.isNotEmpty ? dropoffName : 'الوجهة'}'),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s14),
                      child: Divider(height: 1),
                    ),

                    // Captain details row
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary500.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.two_wheeler_rounded,
                            color: AppColors.primary500,
                            size: 22,
                          ),
                        ),
                        AppSpacing.w12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.captainName.isNotEmpty
                                    ? widget.captainName
                                    : 'الكابتن',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.vehicleModel} • ${widget.vehiclePlate}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.gray500,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.captainPhone.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : AppColors.gray100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.captainPhone,
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              AppSpacing.h20,

              // Rating & Feedback Section
              Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.gray200,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'كيف كانت تجربتك مع ${widget.captainName.isNotEmpty ? widget.captainName : 'الكابتن'}؟',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                    AppSpacing.h8,
                    // Interactive Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        return IconButton(
                          icon: Icon(
                            _selectedRating >= starValue
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFFFB800),
                            size: 34,
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedRating = starValue;
                            });
                          },
                        );
                      }),
                    ),

                    AppSpacing.h10,

                    // Feedback chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _feedbackOptions.map((tag) {
                        final isSelected = _selectedFeedbackChips.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (selected) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (selected) {
                                _selectedFeedbackChips.add(tag);
                              } else {
                                _selectedFeedbackChips.remove(tag);
                              }
                            });
                          },
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: isSelected
                                ? AppColors.primary500
                                : (isDark ? AppColors.gray300 : AppColors.gray700),
                          ),
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : AppColors.gray100,
                          selectedColor:
                              AppColors.primary500.withValues(alpha: 0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary500
                                  : Colors.transparent,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    if (!_isSubmitted) ...[
                      AppSpacing.h12,
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: _submitRating,
                          icon: const Icon(Icons.check_circle_outline_rounded,
                              size: 18),
                          label: const Text(
                            'إرسال التقييم',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary500,
                            side: const BorderSide(
                                color: AppColors.primary500, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              AppSpacing.h24,

              // Primary Action: Return to Home Dashboard
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _onFinish,
                  icon: const Icon(Icons.home_rounded, size: 20),
                  label: const Text(
                    'العودة للرئيسية',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 3,
                  ),
                ),
              ),

              AppSpacing.h20,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
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
    );
  }
}
