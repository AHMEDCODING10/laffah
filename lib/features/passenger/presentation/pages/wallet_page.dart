import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/laffah_app_bar.dart';
import '../../data/datasources/fake_passenger_core_repository.dart';
import '../widgets/transaction_list_tile.dart';
import '../widgets/wallet_balance_card.dart';

/// WalletPage — Displays Passenger's balance in YER and recent transactions.
/// Emphasizes local payment channels (Al-Kuraimi, Floos, Jawali).
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late final double _balance;
  late final List<WalletTransactionModel> _transactions;

  @override
  void initState() {
    super.initState();
    _balance = FakePassengerCoreRepository.getWalletBalance();
    _transactions = FakePassengerCoreRepository.getWalletTransactions();
  }

  void _showTopUpBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.white,
            borderRadius: AppSpacing.radiusBottomSheet,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              AppSpacing.h16,
              Text(
                'اختر طريقة الشحن الإلكتروني المحلية',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              AppSpacing.h16,
              _buildTopUpOption('حاسب / إيداع بنك الكريمي', Icons.account_balance_rounded, isDark),
              _buildTopUpOption('محفظة فلوس (Floos)', Icons.account_balance_wallet_rounded, isDark),
              _buildTopUpOption('محفظة جوالي (Jawali)', Icons.phone_android_rounded, isDark),
              AppSpacing.h16,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopUpOption(String title, IconData icon, bool isDark) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary500.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary500, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.bold,
          fontSize: 13.5,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'جاري تحويلك لخيار شحن المحفظة عبر $title...',
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
            ),
            backgroundColor: AppColors.primary500,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: const LaffahAppBar(title: 'محفظة لَفَّة'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s20,
            AppSpacing.s20,
            100,
          ),
          children: [
            // Balance Card
            WalletBalanceCard(
              balance: _balance,
              onTopUpPressed: () => _showTopUpBottomSheet(isDark),
            ),

            AppSpacing.h24,

            // Recent Transactions Title
            Text(
              'سجل المعاملات المالية الحديثة',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),

            AppSpacing.h12,

            // Transactions List
            for (final tx in _transactions)
              TransactionListTile(
                isDark: isDark,
                transaction: tx,
              ),
          ],
        ),
      ),
    );
  }
}
