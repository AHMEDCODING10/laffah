import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../domain/entities/wallet_entity.dart';

/// TransactionListTile — Displays a single wallet transaction item with clear sign,
/// status badges, and an interactive Uber-like transaction receipt sheet.
class TransactionListTile extends StatelessWidget {
  final bool isDark;
  final TransactionEntity transaction;

  const TransactionListTile({
    super.key,
    required this.isDark,
    required this.transaction,
  });

  void _showReceiptSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TransactionReceiptSheet(
        transaction: transaction,
        isDark: isDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCredit = transaction.isCredit;
    final bool isPending = transaction.isPending;
    final bool isRejected = transaction.isRejected;

    // Semantic amount color
    final Color amountColor = isCredit
        ? AppColors.success
        : (isDark ? AppColors.white : AppColors.gray900);

    // Icon container color
    final Color iconBgColor = isCredit
        ? AppColors.success.withValues(alpha: 0.14)
        : (isRejected
            ? AppColors.danger.withValues(alpha: 0.12)
            : AppColors.primary500.withValues(alpha: 0.12));

    final IconData txIcon = isCredit
        ? Icons.arrow_downward_rounded
        : (transaction.title.contains('استرداد')
            ? Icons.replay_rounded
            : Icons.arrow_upward_rounded);

    final Color iconColor = isCredit
        ? AppColors.success
        : (isRejected ? AppColors.danger : (isDark ? AppColors.primary300 : AppColors.primary700));

    return InkWell(
      onTap: () => _showReceiptSheet(context),
      borderRadius: AppSpacing.radiusMD,
      child: GlassBox(
        borderRadius: AppSpacing.radiusMD,
        margin: const EdgeInsets.only(bottom: AppSpacing.s10),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s14,
          vertical: AppSpacing.s12,
        ),
        child: Row(
          children: [
            // Transaction Category Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                txIcon,
                color: iconColor,
                size: 20,
              ),
            ),
            AppSpacing.w12,

            // Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.displayTitle,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      // Subtitle
                      if (transaction.displaySubtitle.isNotEmpty) ...[
                        Flexible(
                          child: Text(
                            transaction.displaySubtitle,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11,
                              color:
                                  isDark ? AppColors.gray400 : AppColors.gray600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],

                      // Status Badge
                      if (isPending)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 10,
                                color: Color(0xFFD97706),
                              ),
                              SizedBox(width: 3),
                              Text(
                                'قيد المراجعة',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (isRejected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'مرفوضة',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (transaction.date.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      transaction.date,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: isDark ? AppColors.gray500 : AppColors.gray500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Amount with Sign
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}${transaction.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: amountColor,
                  ),
                ),
                Text(
                  'ريال',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
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

/// Transaction Receipt Bottom Sheet (Uber-style)
class _TransactionReceiptSheet extends StatelessWidget {
  final TransactionEntity transaction;
  final bool isDark;

  const _TransactionReceiptSheet({
    required this.transaction,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCredit = transaction.isCredit;
    final bool isPending = transaction.isPending;
    final bool isRejected = transaction.isRejected;

    final String statusLabel = isPending
        ? 'قيد المراجعة السريعة'
        : (isRejected ? 'معاملة مرفوضة' : 'معاملة ناجحة ومكتملة');

    final Color statusColor = isPending
        ? const Color(0xFFD97706)
        : (isRejected ? AppColors.danger : AppColors.success);

    final String refId = transaction.extractedReferenceId ?? transaction.id;
    final String method = transaction.extractedPaymentMethod ?? 'محفظة إلكترونية';
    final String? senderAccount = transaction.extractedSenderAccount;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s16,
        AppSpacing.s20,
        AppSpacing.s32,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppSpacing.radiusBottomSheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
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

          // Icon and status badge
          Container(
            padding: const EdgeInsets.all(AppSpacing.s14),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPending
                  ? Icons.hourglass_top_rounded
                  : (isRejected ? Icons.cancel_outlined : Icons.check_circle_rounded),
              color: statusColor,
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
                '${isCredit ? '+' : '-'}${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: isCredit ? AppColors.success : (isDark ? Colors.white : AppColors.gray900),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
                color: statusColor,
              ),
            ),
          ),
          AppSpacing.h20,

          // Details List
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2430) : AppColors.gray50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white10 : AppColors.gray200,
              ),
            ),
            child: Column(
              children: [
                _buildReceiptRow(
                  label: 'نوع المعاملة',
                  value: transaction.displayTitle,
                  isDark: isDark,
                ),
                const Divider(height: 18),
                _buildReceiptRow(
                  label: 'وسيلة الدفع',
                  value: method,
                  isDark: isDark,
                ),
                if (refId.isNotEmpty) ...[
                  const Divider(height: 18),
                  _buildReceiptRow(
                    label: 'رقم السند / الإشعار',
                    value: '#$refId',
                    isDark: isDark,
                    canCopy: true,
                    onCopy: () {
                      Clipboard.setData(ClipboardData(text: refId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم نسخ رقم السند إلى الحافظة',
                            style: TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
                          ),
                          duration: Duration(seconds: 1),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ],
                if (senderAccount != null && senderAccount.isNotEmpty) ...[
                  const Divider(height: 18),
                  _buildReceiptRow(
                    label: 'رقم الحساب المحول منه',
                    value: senderAccount,
                    isDark: isDark,
                  ),
                ],
                if (transaction.date.isNotEmpty) ...[
                  const Divider(height: 18),
                  _buildReceiptRow(
                    label: 'تاريخ وتوقيت العملية',
                    value: transaction.date,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),

          // Informational Tip Banner
          AppSpacing.h16,
          if (isPending)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFD97706),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'طلبك قيد المراجعة والمطابقة السريعة من فريق عمليات لَفَّة، وسيتم إيداع الرصيد في محفظتك تلقائياً فور التحقق من الإشعار.',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11.5,
                        color: Color(0xFFB45309),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (isCredit && !isRejected)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تم إيداع هذا المبلغ في رصيد محفظتك وهو متاح للاستخدام في جميع المشاوير.',
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
                  borderRadius: BorderRadius.circular(12),
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
                  color: isDark ? AppColors.white : AppColors.gray800,
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
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),
            if (canCopy && onCopy != null) ...[
              const SizedBox(width: 4),
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
