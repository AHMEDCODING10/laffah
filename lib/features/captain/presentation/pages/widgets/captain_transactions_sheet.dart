import '../../../../../l10n/app_localizations.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

import '../../../domain/entities/captain_transaction_entity.dart';

/// CaptainTransactionsSheet — Comprehensive transaction history bottom sheet.
/// Displays all ride earnings, payout withdrawals, and platform commissions.
class CaptainTransactionsSheet extends StatefulWidget {
  final List<CaptainTransactionEntity> transactions;

  const CaptainTransactionsSheet({
    super.key,
    required this.transactions,
  });

  static void show(
      BuildContext context, List<CaptainTransactionEntity> transactions) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          CaptainTransactionsSheet(transactions: transactions),
    );
  }

  @override
  State<CaptainTransactionsSheet> createState() =>
      _CaptainTransactionsSheetState();
}

class _CaptainTransactionsSheetState extends State<CaptainTransactionsSheet> {
  String _selectedFilter = 'ALL';

  List<CaptainTransactionEntity> get _filteredTransactions {
    if (_selectedFilter == 'EARNINGS') {
      return widget.transactions.where((t) => !t.isNegative).toList();
    } else if (_selectedFilter == 'WITHDRAWALS') {
      return widget.transactions.where((t) => t.isNegative).toList();
    }
    return widget.transactions;
  }

  void _showTransactionDetails(CaptainTransactionEntity item, bool isDark) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF141822) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(
                item.isNegative
                    ? Icons.account_balance_rounded
                    : Icons.motorcycle_rounded,
                color: item.isNegative
                    ? AppColors.danger
                    : const Color(0xFFFF6B00),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.gray900,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(AppLocalizations.of(context)!.capt_amount,
                  '${item.isNegative ? '-' : '+'} ${item.amount} ${AppLocalizations.of(context)!.pass_yer.replaceAll(RegExp(r" \(YER\)"), "")}', isDark,
                  isHighlight: true),
              const SizedBox(height: 8),
              _buildDetailRow(AppLocalizations.of(context)!.capt_status,
                  item.status, isDark),
              const SizedBox(height: 8),
              _buildDetailRow(AppLocalizations.of(context)!.capt_time_date,
                  item.date, isDark),
              const SizedBox(height: 8),
              _buildDetailRow(AppLocalizations.of(context)!.capt_ref_number,
                  item.refId, isDark),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.capt_close,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B00),
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            color: AppColors.gray500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: isHighlight ? 15 : 12.5,
            fontWeight: FontWeight.w900,
            color: isHighlight
                ? const Color(0xFFFF6B00)
                : (isDark ? Colors.white : AppColors.gray900),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final list = _filteredTransactions;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141822).withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.96),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag Handle Bar
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

                  // Header Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.capt_tx_history,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: isDark ? Colors.white : AppColors.gray900,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 20, color: AppColors.gray500),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  AppSpacing.h12,

                  // Filter Tabs Bar (الكل, أرباح, سحوبات)
                  Row(
                    children: [
                      _buildTabChip(AppLocalizations.of(context)!.capt_all, 'ALL', _selectedFilter == 'ALL', isDark),
                      const SizedBox(width: 8),
                      _buildTabChip(
                          AppLocalizations.of(context)!.capt_earnings, 'EARNINGS',
                          _selectedFilter == 'EARNINGS',
                          isDark,
                          color: AppColors.success),
                      const SizedBox(width: 8),
                      _buildTabChip(
                          AppLocalizations.of(context)!.capt_withdrawals, 'WITHDRAWALS',
                          _selectedFilter == 'WITHDRAWALS',
                          isDark,
                          color: AppColors.danger),
                    ],
                  ),

                  AppSpacing.h16,

                  // Transactions List
                  Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: Text(
                              AppLocalizations.of(context)!.capt_no_tx_category,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.gray600,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: list.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final item = list[index];
                              final bool isNegative = item.isNegative;
                              final Color statusColor = isNegative
                                  ? AppColors.warning
                                  : AppColors.success;

                              return GestureDetector(
                                onTap: () =>
                                    _showTransactionDetails(item, isDark),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.03)
                                        : AppColors.gray50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.04)
                                          : Colors.black
                                              .withValues(alpha: 0.03),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: isNegative
                                                  ? AppColors.danger
                                                      .withValues(alpha: 0.1)
                                                  : const Color(0xFFFF6B00)
                                                      .withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isNegative
                                                  ? Icons
                                                      .account_balance_rounded
                                                  : Icons.motorcycle_rounded,
                                              size: 20,
                                              color: isNegative
                                                  ? AppColors.danger
                                                  : const Color(0xFFFF6B00),
                                            ),
                                          ),
                                          AppSpacing.w12,
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      'IBM Plex Sans Arabic',
                                                  color: isDark
                                                      ? Colors.white
                                                      : AppColors.gray900,
                                                ),
                                              ),
                                              AppSpacing.h4,
                                              Text(
                                                item.date,
                                                style: const TextStyle(
                                                  fontSize: 10.5,
                                                  color: AppColors.gray500,
                                                  fontFamily:
                                                      'IBM Plex Sans Arabic',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${isNegative ? '-' : '+'} ${item.amount} ${AppLocalizations.of(context)!.pass_yer.replaceAll(RegExp(r" \(YER\)"), "")}',
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w900,
                                              color: isNegative
                                                  ? AppColors.danger
                                                  : const Color(0xFFFF6B00),
                                              fontFamily:
                                                  'IBM Plex Sans Arabic',
                                            ),
                                          ),
                                          AppSpacing.h4,
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(
                                                  alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              item.status,
                                              style: TextStyle(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                color: statusColor,
                                                fontFamily:
                                                    'IBM Plex Sans Arabic',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, String value, bool isSelected, bool isDark,
      {Color? color}) {
    final chipColor = color ?? const Color(0xFFFF6B00);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.15)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : AppColors.gray100),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? chipColor
                : (isDark ? Colors.white12 : AppColors.gray200),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
            color: isSelected
                ? chipColor
                : (isDark ? AppColors.gray400 : AppColors.gray600),
          ),
        ),
      ),
    );
  }
}
