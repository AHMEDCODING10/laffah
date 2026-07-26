import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

/// CaptainRejectReasonDialog — Interactive dialog allowing Captains to select a reason
/// before declining a ride or parcel delivery request.
class CaptainRejectReasonDialog extends StatefulWidget {
  final String orderTitle;
  final Function(String reason) onConfirmReject;

  const CaptainRejectReasonDialog({
    super.key,
    required this.orderTitle,
    required this.onConfirmReject,
  });

  static void show({
    required BuildContext context,
    required String orderTitle,
    required Function(String reason) onConfirmReject,
  }) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => CaptainRejectReasonDialog(
        orderTitle: orderTitle,
        onConfirmReject: onConfirmReject,
      ),
    );
  }

  @override
  State<CaptainRejectReasonDialog> createState() => _CaptainRejectReasonDialogState();
}

class _CaptainRejectReasonDialogState extends State<CaptainRejectReasonDialog> {
  String _selectedReason = 'الموقع بعيد جداً عن دراجتي';

  final List<String> _reasons = const [
    'الموقع بعيد جداً عن دراجتي النارية',
    'الأجرة والمبلغ غير متناسبين مع المسافة',
    'لدي عطل فني في الدراجة النارية حالياً',
    'انشغال أو عدم التفرغ في الوقت الحالي',
    'سبب آخر',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s20),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141822).withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cancel_outlined,
                          color: AppColors.danger,
                          size: 24,
                        ),
                      ),
                      AppSpacing.w12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تأكيد رفض الطلب',
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: AppColors.danger,
                              ),
                            ),
                            Text(
                              widget.orderTitle,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 11.5,
                                color: isDark ? AppColors.gray400 : AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  AppSpacing.h16,

                  const Text(
                    'حدد سبب رفض الطلب لمساعدتنا في تحسين التوزيع:',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray500,
                    ),
                  ),

                  AppSpacing.h8,

                  // Reasons Radio List
                  ..._reasons.map((reason) {
                    final isSelected = reason == _selectedReason;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedReason = reason;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.danger.withValues(alpha: 0.1)
                              : (isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.danger
                                : (isDark ? Colors.white12 : AppColors.gray200),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              size: 18,
                              color: isSelected ? AppColors.danger : AppColors.gray500,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                reason,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.danger
                                      : (isDark ? Colors.white : AppColors.gray900),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  AppSpacing.h16,

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? Colors.white24 : AppColors.gray300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.w12,
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            Navigator.pop(context);
                            widget.onConfirmReject(_selectedReason);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'تأكيد الرفض',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
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
    );
  }
}
