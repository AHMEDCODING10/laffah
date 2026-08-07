import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/glass_box.dart';

/// RatingAndSupportDialog - Glassmorphic popup dialog for completed rides/parcels
class RatingAndSupportDialog extends StatefulWidget {
  final String tripId;
  final String captainName;
  final String tripType;
  final double fare;
  final Function(int rating, String comment)? onRatingSubmitted;
  final VoidCallback? onOpenSupportTicket;

  const RatingAndSupportDialog({
    super.key,
    required this.tripId,
    required this.captainName,
    this.tripType = 'رحلة سريعة',
    required this.fare,
    this.onRatingSubmitted,
    this.onOpenSupportTicket,
  });

  @override
  State<RatingAndSupportDialog> createState() => _RatingAndSupportDialogState();
}

class _RatingAndSupportDialogState extends State<RatingAndSupportDialog> {
  int _currentRating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitRating() {
    setState(() {
      _isSubmitting = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        if (widget.onRatingSubmitted != null) {
          widget.onRatingSubmitted!(_currentRating, _commentController.text.trim());
        }
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'شكرًا لك! تم تسجيل تقييمك بنجاح',
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderMD),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s32),
      child: GlassBox(
        borderRadius: AppSpacing.radiusXL,
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.white.withValues(alpha: 0.12) : AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AppSpacing.h16,

              Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 40,
                ),
              ),
              AppSpacing.h16,

              const Text(
                'تم الوصول بنجاح!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: AppColors.primary500,
                ),
              ),
              AppSpacing.h4,
              Text(
                'شكرًا لاختيارك لَفَّة لرحلتك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),

              AppSpacing.h20,

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppColors.backgroundDark.withValues(alpha: 0.4) 
                      : AppColors.surfaceLight.withValues(alpha: 0.6),
                  borderRadius: AppSpacing.borderLG,
                  border: Border.all(
                    color: isDark ? AppColors.white.withValues(alpha: 0.06) : AppColors.gray200,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.fare.toStringAsFixed(0)} ريال',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: AppColors.primary500,
                          ),
                        ),
                        Text(
                          widget.tripType,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: isDark ? AppColors.gray300 : AppColors.gray700,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.captainName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: isDark ? AppColors.white : AppColors.gray900,
                          ),
                        ),
                        Text(
                          'الكابتن',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: isDark ? AppColors.gray500 : AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              AppSpacing.h24,

              const Text(
                'كيف كانت تجربتك؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              AppSpacing.h12,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = 5 - index;
                  final isLit = _currentRating >= starValue;
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _currentRating = starValue;
                      });
                    },
                    iconSize: 36,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isLit ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isLit ? AppColors.primary500 : AppColors.gray400,
                    ),
                  );
                }),
              ),

              AppSpacing.h20,

              TextField(
                controller: _commentController,
                maxLines: 3,
                maxLength: 150,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
                decoration: InputDecoration(
                  hintText: 'اكتب هنا أي ملاحظات إضافية عن المشوار...',
                  hintStyle: TextStyle(
                    fontSize: 11,
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: isDark ? AppColors.gray500 : AppColors.gray400,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.black.withValues(alpha: 0.2) : AppColors.white,
                  counterStyle: const TextStyle(fontSize: 10, fontFamily: 'IBM Plex Sans Arabic'),
                  contentPadding: const EdgeInsets.all(AppSpacing.s12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppSpacing.borderMD,
                    borderSide: BorderSide(
                      color: isDark ? AppColors.white.withValues(alpha: 0.08) : AppColors.gray300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppSpacing.borderMD,
                    borderSide: const BorderSide(
                      color: AppColors.primary500,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              AppSpacing.h20,

              SizedBox(
                width: double.infinity,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppSpacing.borderMD,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary500.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.borderMD,
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text(
                            'إرسال التقييم وإنهاء',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBM Plex Sans Arabic',
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
              ),

              AppSpacing.h12,

              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final Uri url = Uri.parse('whatsapp://send?phone=+967770291452');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    final Uri phoneUrl = Uri.parse('tel:+967770291452');
                    if (await canLaunchUrl(phoneUrl)) {
                      await launchUrl(phoneUrl);
                    }
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.support_agent_rounded,
                      color: AppColors.info,
                      size: 18,
                    ),
                    AppSpacing.w8,
                    Text(
<<<<<<< HEAD
                      'واجهت مشكلة؟ فتح تذكرة دعم',
=======
                      'تواصل مع الدعم الفني',
>>>>>>> origin/admin-ahmed
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


