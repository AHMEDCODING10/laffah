import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/laffah_app_bar.dart';
import '../../../../core/di/injection_container.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../domain/entities/wallet_entity.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../widgets/transaction_list_tile.dart';
import '../widgets/wallet_balance_card.dart';

/// WalletPage — يعرض رصيد الراكب الحقيقي من قاعدة البيانات عبر WalletBloc
class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WalletBloc>()..add(GetWalletBalanceEvent()),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  void _showTopUpBottomSheet(BuildContext context, bool isDark) {
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
              _buildTopUpOption(ctx, 'حاسب / إيداع بنك الكريمي', Icons.account_balance_rounded, isDark),
              _buildTopUpOption(ctx, 'محفظة فلوس (Floos)', Icons.account_balance_wallet_rounded, isDark),
              _buildTopUpOption(ctx, 'محفظة جوالي (Jawali)', Icons.phone_android_rounded, isDark),
              AppSpacing.h16,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopUpOption(BuildContext context, String title, IconData icon, bool isDark) {
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
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        extendBody: true,
        appBar: const LaffahAppBar(title: 'محفظة لَفَّة'),
        bottomNavigationBar: HomeBottomNavBar(isDark: isDark, currentIndex: 2),
        body: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            if (state is WalletLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary500));
            }

            if (state is WalletError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.gray400),
                    AppSpacing.h12,
                    Text(
                      state.message,
                      style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', color: AppColors.gray600),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.h16,
                    ElevatedButton.icon(
                      onPressed: () => context.read<WalletBloc>().add(GetWalletBalanceEvent()),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary500),
                    ),
                  ],
                ),
              );
            }

            double balance = 0;
            List<TransactionEntity> transactions = [];

            if (state is WalletBalanceLoaded) {
              balance = state.wallet.balance;
              transactions = state.wallet.transactions;
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                100,
              ),
              children: [
                WalletBalanceCard(
                  balance: balance,
                  onTopUpPressed: () => _showTopUpBottomSheet(context, isDark),
                ),
                AppSpacing.h24,
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
                if (transactions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s24),
                      child: Text(
                        'لا توجد معاملات بعد',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: isDark ? AppColors.gray500 : AppColors.gray600,
                        ),
                      ),
                    ),
                  )
                else
                  for (final tx in transactions)
                    TransactionListTile(isDark: isDark, transaction: tx),
              ],
            );
          },
        ),
      ),
    );
  }
}
