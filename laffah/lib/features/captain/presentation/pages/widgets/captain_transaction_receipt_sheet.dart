import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/entities/captain_transaction_entity.dart';

/// CaptainTransactionReceiptSheet — Uber Driver-style interactive receipt bottom sheet
/// displaying complete financial breakdown and clear explanations for cash trips,
/// commissions, payouts, and bonuses.
class CaptainTransactionReceiptSheet extends StatelessWidget {
  final CaptainTransactionEntity transaction;
  final bool isDark;

  const CaptainTransactionReceiptSheet({
    super.key,
    required this.transaction,
    required this.isDark,
  });

  static void show(
    BuildContext context,
    CaptainTransactionEntity transaction,
    bool isDark,
  ) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: CaptainTransactionReceiptSheet(
          transaction: transaction,
          isDark: isDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isNegative = transaction.isNegative;
    final bool isCommission = transaction.isCommission;
    final bool isCash = transaction.isCash;
    final bool isParcel = transaction.isParcel;
    final bool isPayout = transaction.isPayout;
    final bool isDeposit = transaction.isDeposit;
    final bool isTrip = transaction.isTrip;

    final Color amountColor = isNegative
        ? (isDark ? const Color(0xFFF87171) : AppColors.danger)
        : AppColors.success;

    final Color iconColor = isNegative
        ? (isCommission ? const Color(0xFFF59E0B) : AppColors.danger)
        : AppColors.success;

    final String refNumber = transaction.extractedRefNumber;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s16,
        AppSpacing.s20,
        AppSpacing.s32,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141822) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          AppSpacing.h16,

          // Category Icon
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.categoryIcon,
              color: iconColor,
              size: 32,
            ),
          ),
          AppSpacing.h12,

          // Main Amount Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${isNegative ? '-' : '+'}${transaction.amount.toStringAsFixed(1)}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: amountColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'ريال يمني',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
            ],
          ),

          // Status Badge Pill
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: (isNegative ? const Color(0xFFF59E0B) : AppColors.success)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (isNegative ? const Color(0xFFF59E0B) : AppColors.success)
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              isCommission
                  ? 'عمولة منصة لَفَّة المقيدة'
                  : (isPayout
                      ? 'طلب سحب أرباح'
                      : (isDeposit ? 'إيداع ومكافأة' : 'أرباح مشوار منجز')),
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isNegative ? const Color(0xFFD97706) : AppColors.success,
              ),
            ),
          ),
          AppSpacing.h20,

          // Details List Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2433) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                _buildReceiptRow(
                  label: 'بيان المعاملة',
                  value: transaction.displayTitle,
                  isDark: isDark,
                ),
                const Divider(height: 18),
                _buildReceiptRow(
                  label: 'نوع الخدمة',
                  value: isParcel
                      ? 'توصيل طرد سريع (Laffah Box)'
                      : (isTrip ? 'توصيل ركاب (مشوار لَفَّة)' : 'عملية مالية'),
                  isDark: isDark,
                ),
                const Divider(height: 18),
                _buildReceiptRow(
                  label: 'طريقة التحصيل',
                  value: isCash ? 'نقداً باليد (كاش)' : 'محفظة إلكترونية',
                  isDark: isDark,
                  valueColor: isCash ? const Color(0xFF16A34A) : null,
                ),
                if (refNumber.isNotEmpty) ...[
                  const Divider(height: 18),
                  _buildReceiptRow(
                    label: 'رقم المرجع / المشوار',
                    value: '#$refNumber',
                    isDark: isDark,
                    canCopy: true,
                    onCopy: () {
                      Clipboard.setData(ClipboardData(text: refNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم نسخ رقم المرجع إلى الحافظة',
                            style: TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
                          ),
                          duration: Duration(seconds: 1),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
                const Divider(height: 18),
                _buildReceiptRow(
                  label: 'حالة المعاملة',
                  value: transaction.status,
                  isDark: isDark,
                ),
                if (transaction.date.isNotEmpty) ...[
                  const Divider(height: 18),
                  _buildReceiptRow(
                    label: 'تاريخ وتوقيت القيد',
                    value: transaction.date,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),

          // Informational Clarification Banner (Uber Driver Financial Logic)
          AppSpacing.h16,
          if (isCommission && isCash)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.payments_outlined,
                    color: Color(0xFFD97706),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'أجرة المشوار استلمتها نقداً بالكامل بيدك من الراكب عند انتهاء الرحلة. هذا المبلغ السالب يمثل فقط عمولة المنصة المستحقة عن المشوار والمقيدة في حسابك.',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11.5,
                        color: Color(0xFFB45309),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (isCommission && isParcel)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFFD97706),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'قيمة توصيل الطرد استلمتها نقداً من العميل أو المرسل، والمبلغ المسجل هنا هو عمولة خدمة التوصيل المقيدة على حساب لَفَّة.',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11.5,
                        color: Color(0xFFB45309),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (!isNegative)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'تمت إضافة هذا المبلغ كرصيد أرباح أو شحن لمحفظتك الرقمية ويمكن استخدامه لتسوية العمولات أو سحبه.',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11.5,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          AppSpacing.h20,
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(
                  color: isDark ? Colors.white24 : AppColors.gray300,
                ),
              ),
              child: Text(
                'إغلاق',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColors.gray800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow({
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
    bool canCopy = false,
    VoidCallback? onCopy,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            color: isDark ? AppColors.gray400 : AppColors.gray600,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
                color: valueColor ?? (isDark ? Colors.white : AppColors.gray900),
              ),
            ),
            if (canCopy && onCopy != null) ...[
              const SizedBox(width: 5),
              InkWell(
                onTap: onCopy,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 14,
                    color: AppColors.primary500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
