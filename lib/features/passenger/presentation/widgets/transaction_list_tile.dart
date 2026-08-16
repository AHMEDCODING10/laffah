import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../domain/entities/wallet_entity.dart';

/// TransactionListTile — Displays a single wallet transaction item from the backend.
class TransactionListTile extends StatelessWidget {
  final bool isDark;
  final TransactionEntity transaction;

  const TransactionListTile({
    super.key,
    required this.isDark,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.type == 'credit';

    return GlassBox(
      borderRadius: AppSpacing.radiusMD,
      margin: const EdgeInsets.only(bottom: AppSpacing.s10),
      padding: const EdgeInsets.all(AppSpacing.s14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s10),
            decoration: BoxDecoration(
              color: isDeposit
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.danger.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDeposit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isDeposit ? AppColors.success : AppColors.danger,
              size: 18,
            ),
          ),
          AppSpacing.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h2,
                Text(
                  transaction.date,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            AppLocalizations.of(context)!.pass_tx_amount(
                isDeposit ? '+' : '-', transaction.amount.toStringAsFixed(0)),
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: isDeposit ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
