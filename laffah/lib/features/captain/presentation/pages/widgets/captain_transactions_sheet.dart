import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/captain_transaction_entity.dart';
import 'captain_transaction_receipt_sheet.dart';

/// CaptainTransactionsSheet — Comprehensive transaction history bottom sheet.
/// Displays all ride earnings, payout withdrawals, and platform commissions with
/// filter tabs and full Uber Driver-style receipts.
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
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: CaptainTransactionsSheet(transactions: transactions),
      ),
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
    } else if (_selectedFilter == 'COMMISSIONS') {
      return widget.transactions.where((t) => t.isNegative).toList();
    }
    return widget.transactions;
  }

  void _showTransactionDetails(CaptainTransactionEntity item, bool isDark) {
    CaptainTransactionReceiptSheet.show(context, item, isDark);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final list = _filteredTransactions;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141822) : Colors.white,
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

              // Filter Tabs Bar (الكل, أرباح المشاوير, العمولات والمسحوبات)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabChip(
                      'الكل (${widget.transactions.length})',
                      'ALL',
                      _selectedFilter == 'ALL',
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildTabChip(
                      'أرباح المشاوير (+) (${widget.transactions.where((t) => !t.isNegative).length})',
                      'EARNINGS',
                      _selectedFilter == 'EARNINGS',
                      isDark,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    _buildTabChip(
                      'العمولات والمسحوبات (-) (${widget.transactions.where((t) => t.isNegative).length})',
                      'COMMISSIONS',
                      _selectedFilter == 'COMMISSIONS',
                      isDark,
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ),

              AppSpacing.h16,

              // Transactions List
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text(
                          _selectedFilter == 'ALL'
                              ? 'لا توجد معاملات مسجلة حتى الآن'
                              : (_selectedFilter == 'EARNINGS'
                                  ? 'لا توجد أرباح مشاوير مسجلة في هذا القسم'
                                  : 'لا توجد عمولات أو مسحوبات مسجلة'),
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 13,
                            color:
                                isDark ? AppColors.gray400 : AppColors.gray600,
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
                              ? const Color(0xFFF59E0B)
                              : AppColors.success;

                          return GestureDetector(
                            onTap: () =>
                                _showTransactionDetails(item, isDark),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E2433)
                                    : AppColors.gray50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.03),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isNegative
                                          ? const Color(0xFFF59E0B)
                                              .withValues(alpha: 0.12)
                                          : AppColors.success
                                              .withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      item.categoryIcon,
                                      size: 20,
                                      color: isNegative
                                          ? const Color(0xFFD97706)
                                          : AppColors.success,
                                    ),
                                  ),
                                  AppSpacing.w12,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.displayTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'IBM Plex Sans Arabic',
                                            color: isDark
                                                ? Colors.white
                                                : AppColors.gray900,
                                          ),
                                        ),
                                        AppSpacing.h4,
                                        Text(
                                          item.displaySubtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: AppColors.gray500,
                                            fontFamily: 'IBM Plex Sans Arabic',
                                          ),
                                        ),
                                        if (item.date.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            item.date,
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              color: AppColors.gray500,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${isNegative ? '-' : '+'}${item.amount.toStringAsFixed(1)} ريال',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: isNegative
                                              ? (isDark
                                                  ? const Color(0xFFF87171)
                                                  : AppColors.danger)
                                              : AppColors.success,
                                          fontFamily: 'IBM Plex Sans Arabic',
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
                                            fontFamily: 'IBM Plex Sans Arabic',
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
    );
  }

  Widget _buildTabChip(String label, String value, bool isSelected, bool isDark,
      {Color? color}) {
    final chipColor = color ?? AppColors.primary500;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.15)
              : (isDark
                  ? const Color(0xFF1E2433)
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
            fontSize: 11.5,
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
