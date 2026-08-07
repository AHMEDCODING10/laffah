import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

/// TripRatingBottomSheet - Post-trip rating, feedback, and tipping interface
class TripRatingBottomSheet extends StatefulWidget {
  final double tripFare;
  final String captainName;
  final String vehicleInfo;
  final VoidCallback onSubmitted;

  const TripRatingBottomSheet({
    super.key,
    required this.tripFare,
    required this.captainName,
    required this.vehicleInfo,
    required this.onSubmitted,
  });

  @override
  State<TripRatingBottomSheet> createState() => _TripRatingBottomSheetState();
}

class _TripRatingBottomSheetState extends State<TripRatingBottomSheet> {
  int _rating = 5;
  final List<String> _selectedTags = [];
  int _selectedTipAmount = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _feedbackTags = [
    'قيادة آمنة وهادئة',
    'سيارة/دراجة نظيفة جداً',
    'الالتزام بالوقت والمواعيد',
    'التعامل اللبق والمحترم',
    'معرفة ممتازة بالطرق والاختصارات',
    'الالتزام بالوقاية والسلامة',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalPayment = widget.tripFare + _selectedTipAmount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
          borderRadius: AppSpacing.borderBottomSheet,
        ),
        padding: EdgeInsets.only(
          top: AppSpacing.s24,
          left: AppSpacing.s24,
          right: AppSpacing.s24,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.gray700 : AppColors.gray300,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              
              AppSpacing.h20,

              Text(
                'لقد وصلت لوجهتك بسلامة الله!',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              AppSpacing.h6,
              Text(
                'كيف كانت تجربتك ومشوارك اليوم مع الكابتن؟',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
              
              AppSpacing.h20,

              _buildCaptainProfileCard(isDark),

              AppSpacing.h24,

              _buildInteractiveStars(isDark),

              AppSpacing.h24,

              _buildFeedbackTagsSection(isDark),

              AppSpacing.h20,

              _buildTippingSection(isDark),

              AppSpacing.h20,

              _buildCommentsInputField(isDark),

              AppSpacing.h20,

              _buildReceiptBreakdownBox(isDark, totalPayment),

              AppSpacing.h24,

              _isSubmitting
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary500),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _submitRating,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderMD,
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'تأكيد التقييم والدفع المالي',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
              AppSpacing.h8,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaptainProfileCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50,
        borderRadius: AppSpacing.borderLG,
        border: Border.all(
          color: isDark ? AppColors.white.withValues(alpha: 0.04) : AppColors.gray200,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary500.withValues(alpha: 0.12),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary500,
              size: 28,
            ),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.captainName,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h4,
                Text(
                  widget.vehicleInfo,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10, vertical: AppSpacing.s4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.stars_rounded, color: AppColors.success, size: 12),
                AppSpacing.w4,
                Text(
                  'كابتن متميز',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveStars(bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            final isLit = starValue <= _rating;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _rating = starValue;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.bounceOut,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6),
                child: Icon(
                  Icons.star_rounded,
                  color: isLit ? AppColors.warning : (isDark ? AppColors.gray800 : AppColors.gray300),
                  size: 44,
                ),
              ),
            );
          }),
        ),
        AppSpacing.h8,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _getRatingDescription(_rating),
            key: ValueKey<int>(_rating),
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: AppColors.primary500,
            ),
          ),
        ),
      ],
    );
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 1:
        return 'تجربة سيئة جداً وغير مرضية 👎';
      case 2:
        return 'هناك ملاحظات سلبية كثيرة ⚠️';
      case 3:
        return 'جيدة، ولكن تتطلب التحسين والمطابقة 😐';
      case 4:
        return 'رائعة ومريحة، شكراً للكابتن 👍';
      case 5:
        return 'ممتازة وخمس نجوم كاملة! 🌟';
      default:
        return '';
    }
  }

  Widget _buildFeedbackTagsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'ما الذي تميز به الكابتن؟ (اختر ما ينطبق):',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.gray600,
            ),
          ),
        ),
        AppSpacing.h10,
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          alignment: WrapAlignment.center,
          children: _feedbackTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(
                tag,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected 
                      ? AppColors.white 
                      : (isDark ? AppColors.white : AppColors.gray800),
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary500,
              checkmarkColor: AppColors.white,
              backgroundColor: isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? AppColors.primary500 : (isDark ? AppColors.white.withValues(alpha: 0.04) : AppColors.gray200),
                ),
              ),
              onSelected: (_) => _toggleTag(tag),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTippingSection(bool isDark) {
    final tips = [100, 200, 500];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'أضف إكرامية (بخشيش نقدي) لتشجيع الكابتن:',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.gray600,
            ),
          ),
        ),
        AppSpacing.h8,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTipAmount = 0;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
                decoration: BoxDecoration(
                  color: _selectedTipAmount == 0
                      ? AppColors.primary500.withValues(alpha: 0.12)
                      : (isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray100),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedTipAmount == 0
                        ? AppColors.primary500
                        : (isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray200),
                    width: _selectedTipAmount == 0 ? 1.5 : 1.0,
                  ),
                ),
                child: Text(
                  'بدون إكرامية',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: _selectedTipAmount == 0 ? AppColors.primary500 : (isDark ? AppColors.gray400 : AppColors.gray700),
                  ),
                ),
              ),
            ),
            AppSpacing.w10,
            ...tips.map((tip) {
              final isSelected = _selectedTipAmount == tip;
              return Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTipAmount = tip;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary500.withValues(alpha: 0.12)
                          : (isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray100),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary500
                            : (isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray200),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Text(
                      '+$tip ر.ي',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: isSelected ? AppColors.primary500 : (isDark ? AppColors.gray400 : AppColors.gray700),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentsInputField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'أضف تعليقاً أو ملاحظات إضافية (اختياري):',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.gray600,
            ),
          ),
        ),
        AppSpacing.h8,
        TextField(
          controller: _commentController,
          maxLines: 2,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 13,
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
          decoration: InputDecoration(
            hintText: 'اكتب هنا أي ملاحظة ترغب في مشاركتها معنا لتطوير جودة الخدمة...',
            hintStyle: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 11.5,
              fontWeight: FontWeight.normal,
              color: isDark ? AppColors.gray600 : AppColors.gray400,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 12),
            filled: true,
            fillColor: isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50,
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderSM,
              borderSide: BorderSide(
                color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderSM,
              borderSide: const BorderSide(
                color: AppColors.primary500,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptBreakdownBox(bool isDark, double totalPayment) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: AppColors.primary500.withValues(alpha: 0.04),
        borderRadius: AppSpacing.borderMD,
        border: Border.all(
          color: AppColors.primary500.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: AppColors.primary500, size: 16),
              AppSpacing.w6,
              Text(
                'تفاصيل الفاتورة النقدية ومجموع الأجرة:',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
          AppSpacing.h12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تكلفة المشوار الأساسية (دراجة/سيارة):',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  color: AppColors.gray600,
                ),
              ),
              Text(
                '${_formatCurrency(widget.tripFare)} ريال',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ],
          ),
          if (_selectedTipAmount > 0) ...[
            AppSpacing.h8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'قيمة الإكرامية المضافة للكابتن:',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11,
                    color: AppColors.gray600,
                  ),
                ),
                Text(
                  '+ ${_formatCurrency(_selectedTipAmount.toDouble())} ريال',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
          AppSpacing.h8,
          const Divider(height: 1, thickness: 0.5),
          AppSpacing.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إجمالي المبلغ المستحق دفعه كاش للكابتن:',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: AppColors.primary500,
                ),
              ),
              Text(
                '${_formatCurrency(totalPayment)} ريال يمني',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitRating() {
    setState(() {
      _isSubmitting = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        Navigator.pop(context);
        widget.onSubmitted();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: AppColors.white, size: 20),
                  AppSpacing.w12,
                  Text(
                    'تم تسجيل تقييمك للكابتن وشكر الإكرامية بنجاح! رافقتكم السلامة.',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });
  }

  String _formatCurrency(double amount) {
    final String str = amount.toInt().toString();
    if (str.length <= 3) return str;
    
    final List<String> parts = [];
    int end = str.length;
    while (end > 0) {
      final int start = end - 3 > 0 ? end - 3 : 0;
      parts.insert(0, str.substring(start, end));
      end = start;
    }
    return parts.join(',');
  }
}
