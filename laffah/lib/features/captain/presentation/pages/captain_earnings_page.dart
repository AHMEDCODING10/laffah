import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/captain_transaction_entity.dart';
import '../bloc/wallet/captain_wallet_bloc.dart';
import '../bloc/wallet/captain_wallet_event.dart';
import '../bloc/wallet/captain_wallet_state.dart';
import 'widgets/captain_payout_dialog.dart';
import 'widgets/captain_topup_sheet.dart';
import 'widgets/captain_transaction_receipt_sheet.dart';
import 'widgets/captain_transactions_sheet.dart';

/// CaptainEarningsPage - Ultra-Modern, Interactive Financial Dashboard & Wallet for Laffah Captains.
/// Adheres strictly to the Uber Driver financial workflow:
/// 1. Gross Earnings vs Cash-in-hand vs Digital Wallet Balance.
/// 2. Transparent Commission and Ride Receipts.
/// 3. Dual Action: Cash-out Payouts & Top-up/Settle Platform Commissions via local e-wallets.
class CaptainEarningsPage extends StatefulWidget {
  final CaptainWalletBloc? walletBloc;
  const CaptainEarningsPage({super.key, this.walletBloc});

  @override
  State<CaptainEarningsPage> createState() => _CaptainEarningsPageState();
}

class _CaptainEarningsPageState extends State<CaptainEarningsPage> {
  late final CaptainWalletBloc _walletBloc;
  bool _isLocalBloc = false;
  String _selectedTxFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    if (widget.walletBloc != null) {
      _walletBloc = widget.walletBloc!;
      _isLocalBloc = false;
    } else {
      _walletBloc = sl<CaptainWalletBloc>()..add(const FetchWalletDetails());
      _isLocalBloc = true;
    }
  }

  @override
  void dispose() {
    if (_isLocalBloc) {
      _walletBloc.close();
    }
    super.dispose();
  }

  void _handleConfirmPayout(
      double amount, String method, String accountNumber) {
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
          AppLocalizations.of(context)!.capt_wallet_payout_success(
            amount.toStringAsFixed(0),
            method,
            accountNumber,
          ),
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showCashInHandExplanation(
      BuildContext context, double todayEarnings, bool isDark) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF141822) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: AppColors.primary500,
                  size: 32,
                ),
              ),
              AppSpacing.h16,
              Text(
                'كيف تعمل الأرباح النقدية؟',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 16.5,
                  color: isDark ? Colors.white : AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.h10,
              Text(
                'أرباح مشاويرك الأخيرة (${todayEarnings.toStringAsFixed(0)} ريال) قمت بتحصيلها نقداً بالكامل بيدك من الركاب مباشرة عند نزولهم، لذلك لا يوجد رصيد إلكتروني معلق للسحب.\n\nالرصيد الرقمي القابل للتحويل ينشأ فقط عندما يدفع الراكب عبر المحفظة الإلكترونية أو عند حصولك على مكافآت وبونص من لَفَّة.',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12.5,
                  color: isDark ? AppColors.gray300 : AppColors.gray700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.h20,
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'فهمت ذلك',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ],
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
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
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
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            AppSpacing.w12,
            Expanded(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
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
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        AppSpacing.h24,
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _walletBloc,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            AppLocalizations.of(context)!.capt_wallet_title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'IBM Plex Sans Arabic',
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'تحديث المحفظة',
              icon: Icon(
                Icons.refresh_rounded,
                color: isDark ? AppColors.white : AppColors.gray800,
                size: 22,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                _walletBloc.add(const FetchWalletDetails());
              },
            ),
          ],
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<CaptainWalletBloc, CaptainWalletState>(
            builder: (context, state) {
              if (state is CaptainWalletLoading ||
                  state is CaptainWalletInitial) {
                return _buildSkeletonLoading(isDark);
              } else if (state is CaptainWalletError) {
                return Center(
                  child: Text(
                    state.message == 'capt_wallet_err_fetch'
                        ? AppLocalizations.of(context)!.capt_wallet_err_fetch
                        : (state.message == 'capt_wallet_err_payout'
                            ? AppLocalizations.of(context)!
                                .capt_wallet_err_payout
                            : state.message),
                    style: const TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: AppColors.danger,
                    ),
                  ),
                );
              } else if (state is CaptainWalletLoaded) {
                final wallet = state.wallet;
                final targetProgress = wallet.targetProgress;
                final bool hasWithdrawableBalance = wallet.availableBalance > 0;

                // Filter transactions
                final filteredTx = wallet.recentTransactions.where((t) {
                  if (_selectedTxFilter == 'EARNINGS') return !t.isNegative;
                  if (_selectedTxFilter == 'COMMISSIONS') return t.isNegative;
                  return true;
                }).toList();

                return RefreshIndicator(
                  color: AppColors.primary500,
                  onRefresh: () async {
                    _walletBloc.add(const FetchWalletDetails());
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 95),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      // 1. Premium Balance Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s20),
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF1E2433),
                                    Color(0xFF141822),
                                  ],
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
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.03),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.4 : 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .capt_wallet_transferable_balance,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray500,
                                fontFamily: 'IBM Plex Sans Arabic',
                              ),
                            ),
                            AppSpacing.h8,
                            Text(
                              '${wallet.availableBalance.toStringAsFixed(0)} ${AppLocalizations.of(context)!.pass_yer.replaceAll(RegExp(r" \(YER\)"), "")}',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: hasWithdrawableBalance
                                    ? AppColors.success
                                    : (isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A)),
                                letterSpacing: 0.5,
                                fontFamily: 'IBM Plex Sans Arabic',
                              ),
                            ),
                            AppSpacing.h12,

                            // Week over week growth chip
                            if (wallet.weekOverWeekGrowth > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        AppColors.success.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.trending_up_rounded,
                                        color: AppColors.success, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .capt_wallet_growth(
                                              wallet.weekOverWeekGrowth
                                                  .toStringAsFixed(0)),
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

                            AppSpacing.h16,

                            // Honest Financial Status Banner
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: hasWithdrawableBalance
                                    ? AppColors.success.withValues(alpha: 0.08)
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.04)
                                        : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: hasWithdrawableBalance
                                      ? AppColors.success.withValues(alpha: 0.2)
                                      : (isDark
                                          ? Colors.white10
                                          : const Color(0xFFE2E8F0)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    hasWithdrawableBalance
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.info_outline_rounded,
                                    size: 16,
                                    color: hasWithdrawableBalance
                                        ? AppColors.success
                                        : AppColors.primary500,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      hasWithdrawableBalance
                                          ? 'رصيد أرباح متاح للسحب الفوري إلى محفظتك الإلكترونية أو حسابك البنكي.'
                                          : 'أرباح اليوم استلمتها نقداً بالكامل بيدك من الركاب مباشرة.',
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: hasWithdrawableBalance
                                            ? AppColors.success
                                            : (isDark
                                                ? AppColors.gray300
                                                : AppColors.gray700),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            AppSpacing.h20,

                            // Daily Target Dynamic Progress Bar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .capt_wallet_daily_target,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.gray500,
                                        fontFamily: 'IBM Plex Sans Arabic',
                                      ),
                                    ),
                                    Text(
                                      '${(targetProgress * 100).toInt()}% (${wallet.dailyTarget.toInt()} ${AppLocalizations.of(context)!.pass_yer.replaceAll(RegExp(r" \(YER\)"), "")})',
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
                                    backgroundColor: isDark
                                        ? Colors.white12
                                        : AppColors.gray200,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.h16,

                      // 2. Bento Stats Row: Today's Earnings & Weekly Earnings
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.s14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF141822)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .capt_wallet_today_earnings,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gray500,
                                      fontFamily: 'IBM Plex Sans Arabic',
                                    ),
                                  ),
                                  AppSpacing.h4,
                                  Text(
                                    '${wallet.todayEarnings.toStringAsFixed(0)} ${AppLocalizations.of(context)!.pass_yer.replaceAll(RegExp(r" \(YER\)"), "")}',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.gray900,
                                    ),
                                  ),
                                  AppSpacing.h8,
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                          color: AppColors.success, size: 13),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${wallet.completedTripsToday} رحلة • كاش باليد',
                                        style: const TextStyle(
                                          fontSize: 10,
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
                          AppSpacing.w12,
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.s14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF141822)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .capt_wallet_weekly_earnings,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gray500,
                                      fontFamily: 'IBM Plex Sans Arabic',
                                    ),
                                  ),
                                  AppSpacing.h4,
                                  Text(
                                    '${wallet.weeklyEarnings.toStringAsFixed(0)} ${AppLocalizations.of(context)!.pass_yer.replaceAll(RegExp(r" \(YER\)"), "")}',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.gray900,
                                    ),
                                  ),
                                  AppSpacing.h8,
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded,
                                          color: AppColors.primary500, size: 12),
                                      const SizedBox(width: 5),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .capt_wallet_current_week,
                                        style: const TextStyle(
                                          fontSize: 10,
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
                        ],
                      ),

                      AppSpacing.h16,

                      // 3. Dual Action Buttons (Payout / Settle Commissions)
                      Row(
                        children: [
                          // Settle Commissions / Top up
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  CaptainTopUpSheet.show(
                                    context,
                                    isDark,
                                    () => _walletBloc
                                        .add(const FetchWalletDetails()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary500,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(Icons.add_circle_outline_rounded,
                                    size: 18),
                                label: const Text(
                                  'شحن / سداد العمولات',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.w12,

                          // Cash out / Request Payout
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  if (hasWithdrawableBalance) {
                                    CaptainPayoutDialog.show(
                                      context: context,
                                      availableBalance:
                                          wallet.availableBalance,
                                      onConfirmPayout: _handleConfirmPayout,
                                    );
                                  } else {
                                    _showCashInHandExplanation(
                                      context,
                                      wallet.todayEarnings,
                                      isDark,
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: hasWithdrawableBalance
                                      ? AppColors.success
                                      : (isDark
                                          ? AppColors.gray300
                                          : AppColors.gray700),
                                  side: BorderSide(
                                    color: hasWithdrawableBalance
                                        ? AppColors.success
                                        : (isDark
                                            ? Colors.white24
                                            : AppColors.gray300),
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 18,
                                  color: hasWithdrawableBalance
                                      ? AppColors.success
                                      : AppColors.primary500,
                                ),
                                label: Text(
                                  hasWithdrawableBalance
                                      ? 'سحب الأرباح'
                                      : 'تحويل الأرباح',
                                  style: const TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      AppSpacing.h8,
                      Center(
                        child: Text(
                          AppLocalizations.of(context)!
                              .capt_wallet_payout_methods,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.gray500,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                      ),

                      AppSpacing.h24,

                      // 4. Transactions Log Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!
                                .capt_wallet_tx_history,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'IBM Plex Sans Arabic',
                              color: isDark ? Colors.white : AppColors.gray900,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              CaptainTransactionsSheet.show(
                                  context, wallet.recentTransactions);
                            },
                            child: Text(
                              AppLocalizations.of(context)!
                                  .capt_wallet_view_all,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.primary500,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'IBM Plex Sans Arabic',
                              ),
                            ),
                          ),
                        ],
                      ),

                      AppSpacing.h10,

                      // Filter chips row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildPageFilterChip(
                              'الكل (${wallet.recentTransactions.length})',
                              'ALL',
                              _selectedTxFilter == 'ALL',
                              isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildPageFilterChip(
                              'أرباح المشاوير (+) (${wallet.recentTransactions.where((t) => !t.isNegative).length})',
                              'EARNINGS',
                              _selectedTxFilter == 'EARNINGS',
                              isDark,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            _buildPageFilterChip(
                              'العمولات والمسحوبات (-) (${wallet.recentTransactions.where((t) => t.isNegative).length})',
                              'COMMISSIONS',
                              _selectedTxFilter == 'COMMISSIONS',
                              isDark,
                              color: const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.h16,

                      // Transactions List
                      if (filteredTx.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 32, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.02)
                                : AppColors.gray50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white10
                                  : AppColors.gray200,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _selectedTxFilter == 'ALL'
                                  ? 'لا توجد معاملات مسجلة حتى الآن'
                                  : (_selectedTxFilter == 'EARNINGS'
                                      ? 'لا توجد أرباح مشاوير مسجلة في هذا القسم'
                                      : 'لا توجد عمولات أو مسحوبات مسجلة'),
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 12.5,
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.gray600,
                              ),
                            ),
                          ),
                        )
                      else
                        ...filteredTx.take(5).map((item) {
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

  Widget _buildPageFilterChip(
      String label, String value, bool isSelected, bool isDark,
      {Color? color}) {
    final chipColor = color ?? AppColors.primary500;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedTxFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF1E2433) : AppColors.gray100),
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

  Widget _buildTransactionTile(
      BuildContext context, CaptainTransactionEntity item, bool isDark) {
    final bool isNegative = item.isNegative;
    final Color statusColor =
        isNegative ? const Color(0xFFF59E0B) : AppColors.success;

    return GestureDetector(
      onTap: () {
        CaptainTransactionReceiptSheet.show(context, item, isDark);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s10),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s14, vertical: AppSpacing.s12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2433) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isNegative
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                    : AppColors.success.withValues(alpha: 0.12),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 3),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
      ),
    );
  }
}
