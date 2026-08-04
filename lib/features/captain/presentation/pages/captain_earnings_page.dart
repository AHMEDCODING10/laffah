import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/captain_action_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/wallet/captain_wallet_bloc.dart';
import '../bloc/wallet/captain_wallet_event.dart';
import '../bloc/wallet/captain_wallet_state.dart';
import '../../domain/entities/captain_transaction_entity.dart';
import 'widgets/captain_payout_dialog.dart';
import 'widgets/captain_transactions_sheet.dart';

/// CaptainEarningsPage - Ultra-Modern, Interactive Financial Dashboard & Wallet for Laffah Captains.
/// Features dynamic balance state calculations, authentic Yemeni payout integration (الكريمي/جوالي/ون كاش),
/// and comprehensive transaction history.
class CaptainEarningsPage extends StatefulWidget {
  const CaptainEarningsPage({super.key});

  @override
  State<CaptainEarningsPage> createState() => _CaptainEarningsPageState();
}

class _CaptainEarningsPageState extends State<CaptainEarningsPage> {
  late final CaptainWalletBloc _walletBloc;

  @override
  void initState() {
    super.initState();
    _walletBloc = sl<CaptainWalletBloc>()..add(FetchWalletDetails());
  }

  @override
  void dispose() {
    _walletBloc.close();
    super.dispose();
  }

  void _handleConfirmPayout(double amount, String method, String accountNumber) {
    _walletBloc.add(RequestPayoutEvent(
      amount: amount,
      method: method,
      accountNumber: accountNumber,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          'تم إرسال طلب تحويل ${amount.toStringAsFixed(0)} ر.ي عبر $method إلى الحساب ($accountNumber) بنجاح!',
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading(bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        AppSpacing.h16,
        Row(
          children: [
            Expanded(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            AppSpacing.w12,
            Expanded(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
        AppSpacing.h16,
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        AppSpacing.h24,
        ...List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        )),
      ],
    );
  }

  // Removed duplicated _handleConfirmPayout

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _walletBloc,
      child: Scaffold(
appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'محفظة الأرباح المالية',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'IBM Plex Sans Arabic',
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocBuilder<CaptainWalletBloc, CaptainWalletState>(
          builder: (context, state) {
            if (state is CaptainWalletLoading || state is CaptainWalletInitial) {
              return _buildSkeletonLoading(isDark);
            } else if (state is CaptainWalletError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', color: AppColors.danger),
                ),
              );
            } else if (state is CaptainWalletLoaded) {
              final wallet = state.wallet;
              final targetProgress = wallet.targetProgress;
              
              return RefreshIndicator(
                onRefresh: () async {
                  _walletBloc.add(FetchWalletDetails());
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  children: [
                    // Premium Balance Card with Gradient
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s20),
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? const LinearGradient(
                                colors: [Color(0xFF1E2433), Color(0xFF141822)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [Colors.white, Color(0xFFF8FAFC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'الرصيد القابل للتحويل والسحب',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray500,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                          AppSpacing.h8,
                          Text(
                            '${wallet.availableBalance.toStringAsFixed(0)} ر.ي',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              letterSpacing: 0.5,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                          AppSpacing.h12,
                          if (wallet.weekOverWeekGrowth > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.trending_up_rounded, color: AppColors.success, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'أعلى بنسبة ${wallet.weekOverWeekGrowth.toStringAsFixed(0)}% من الأسبوع الماضي',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'IBM Plex Sans Arabic',
                                    ),
                                  ),
                                ],
                              ),
                            ),
        
                          AppSpacing.h24,
        
                          // Daily Target Dynamic Progress Bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'هدف الأرباح اليومي',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gray500,
                                      fontFamily: 'IBM Plex Sans Arabic',
                                    ),
                                  ),
                                  Text(
                                    '${(targetProgress * 100).toInt()}% (${wallet.dailyTarget.toInt()} ر.ي)',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                      fontFamily: 'IBM Plex Sans Arabic',
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.h8,
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: targetProgress,
                                  minHeight: 8,
                                  backgroundColor: isDark ? Colors.white12 : AppColors.gray200,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

            AppSpacing.h16,

            // Bento Stats Row: Today's Earnings & Weekly Earnings
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141822).withValues(alpha: 0.9)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'أرباح الأسبوع الحالي',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray500,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                        AppSpacing.h4,
                        Text(
                          '${wallet.weeklyEarnings.toStringAsFixed(0)} ر.ي',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: isDark ? Colors.white : AppColors.gray900,
                          ),
                        ),
                        AppSpacing.h8,
                        const Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, color: Color(0xFFFF6B00), size: 13),
                            SizedBox(width: 6),
                            Text(
                              'الأسبوع الحالي',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: AppColors.gray500,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'IBM Plex Sans Arabic',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141822).withValues(alpha: 0.9)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'أرباح اليوم',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray500,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                        AppSpacing.h4,
                        Text(
                          '${wallet.todayEarnings.toStringAsFixed(0)} ر.ي',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: isDark ? Colors.white : AppColors.gray900,
                          ),
                        ),
                        AppSpacing.h8,
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 13),
                            const SizedBox(width: 6),
                            Text(
                              '${wallet.completedTripsToday} رحلة مكتملة',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'IBM Plex Sans Arabic',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.h16,

            // Payout Request Action Button
            CaptainActionButton(
              label: 'طلب تحويل الأرباح',
              icon: Icons.account_balance_wallet_rounded,
              onPressed: () {
                CaptainPayoutDialog.show(
                  context: context,
                  availableBalance: wallet.availableBalance,
                  onConfirmPayout: _handleConfirmPayout,
                );
              },
            ),

            AppSpacing.h8,
            const Center(
              child: Text(
                'يتم معالجة الطلبات عبر (الكريمي / جيب / فلوسك / جوالي / ون كاش) بنجاح فوري في اليمن',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.gray500,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
            ),

            AppSpacing.h24,

            // Transactions Log Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سجل المعاملات والأرباح',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: isDark ? Colors.white : AppColors.gray900,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    CaptainTransactionsSheet.show(context, wallet.recentTransactions);
                  },
                  child: const Text(
                    'عرض الكل >',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFFFF6B00),
                      fontWeight: FontWeight.w900,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.h12,

            // Display Recent 3 Transactions
            ...wallet.recentTransactions.take(3).map((item) {
              return _buildTransactionTile(context, item, isDark);
            }),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  },
),
      ),
    ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, CaptainTransactionEntity item, bool isDark) {
    final bool isNegative = item.isNegative;
    final Color statusColor = isNegative ? AppColors.warning : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF141822).withValues(alpha: 0.9)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isNegative
                      ? AppColors.danger.withValues(alpha: 0.12)
                      : const Color(0xFFFF6B00).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNegative ? Icons.account_balance_rounded : Icons.motorcycle_rounded,
                  size: 20,
                  color: isNegative ? AppColors.danger : const Color(0xFFFF6B00),
                ),
              ),
              AppSpacing.w12,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    item.date,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.gray500,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isNegative ? '-' : '+'} ${item.amount} ر.ي',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: isNegative ? AppColors.danger : const Color(0xFFFF6B00),
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              AppSpacing.h4,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
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
    );
  }
}
