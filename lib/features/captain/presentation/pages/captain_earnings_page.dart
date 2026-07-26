import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/captain_action_button.dart';
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
  // Real Financial State Variables
  double _availableBalance = 4250.0;
  double _todayEarnings = 4250.0;
  double _weeklyEarnings = 21500.0;
  int _completedTripsToday = 12;
  final double _dailyTarget = 5000.0;

  // Transactions History List
  late List<Map<String, dynamic>> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = [
      {
        'title': 'تحويل بنكي ناجح (الكريمي)',
        'time': 'اليوم • 10:30 صباحاً',
        'amount': '- 3,500',
        'statusText': 'مكتمل',
        'statusColor': AppColors.success,
        'icon': Icons.account_balance_rounded,
        'iconBgColor': AppColors.success.withValues(alpha: 0.12),
        'iconColor': AppColors.success,
        'isNegative': true,
        'refId': 'KRM-9948102',
      },
      {
        'title': 'أجرة مشوار #LF-88293',
        'time': 'اليوم • 10:15 صباحاً',
        'amount': '+ 2,160',
        'statusText': 'تمت الإضافة',
        'statusColor': const Color(0xFFFF6B00),
        'icon': Icons.motorcycle_rounded,
        'iconBgColor': const Color(0xFFFF6B00).withValues(alpha: 0.12),
        'iconColor': const Color(0xFFFF6B00),
        'isNegative': false,
        'refId': 'TRIP-88293',
      },
      {
        'title': 'أجرة مشوار #LF-88290',
        'time': 'اليوم • 09:15 صباحاً',
        'amount': '+ 1,620',
        'statusText': 'تمت الإضافة',
        'statusColor': const Color(0xFFFF6B00),
        'icon': Icons.motorcycle_rounded,
        'iconBgColor': const Color(0xFFFF6B00).withValues(alpha: 0.12),
        'iconColor': const Color(0xFFFF6B00),
        'isNegative': false,
        'refId': 'TRIP-88290',
      },
    ];
  }

  void _handleConfirmPayout(double amount, String method, String accountNumber) {
    setState(() {
      _availableBalance -= amount;
      _transactions.insert(0, {
        'title': 'تحويل بنكي ($method)',
        'time': 'الآن • طلب سحب',
        'amount': '- ${amount.toStringAsFixed(0)}',
        'statusText': 'قيد المعالجة',
        'statusColor': AppColors.warning,
        'icon': Icons.account_balance_rounded,
        'iconBgColor': AppColors.warning.withValues(alpha: 0.14),
        'iconColor': AppColors.warning,
        'isNegative': true,
        'refId': 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      });
    });

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double targetProgress = (_todayEarnings / _dailyTarget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90), // Bottom padding for floating navbar
          physics: const BouncingScrollPhysics(),
          children: [
            // Net Balance Card with Glowing Highlight
            Container(
              padding: const EdgeInsets.all(AppSpacing.s20),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141822).withValues(alpha: 0.9)
                    : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'الرصيد القابل للتحويل والسحب',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray500,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                  AppSpacing.h8,
                  Text(
                    '${_availableBalance.toStringAsFixed(0)} ر.ي',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF1A1F2C),
                      letterSpacing: 0.5,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                  AppSpacing.h12,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up_rounded, color: AppColors.success, size: 15),
                        SizedBox(width: 6),
                        Text(
                          'أعلى بنسبة 12% من الأسبوع الماضي',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.success,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'IBM Plex Sans Arabic',
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'هدف الأرباح اليومي',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray500,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                          Text(
                            '${(targetProgress * 100).toInt()}% (${_dailyTarget.toInt()} ر.ي)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF6B00),
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
                          minHeight: 9,
                          backgroundColor: isDark ? Colors.white12 : AppColors.gray200,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
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
                          '${_weeklyEarnings.toStringAsFixed(0)} ر.ي',
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
                          '${_todayEarnings.toStringAsFixed(0)} ر.ي',
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
                              '$_completedTripsToday رحلة مكتملة',
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
                  availableBalance: _availableBalance,
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
                    CaptainTransactionsSheet.show(context, _transactions);
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
            ..._transactions.take(3).map((item) {
              return _buildTransactionTile(context, item, isDark);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, Map<String, dynamic> item, bool isDark) {
    final bool isNegative = item['isNegative'] == true;
    final Color statusColor = (item['statusColor'] as Color?) ?? AppColors.success;

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
                  item['icon'] as IconData? ?? Icons.account_balance_rounded,
                  size: 20,
                  color: isNegative ? AppColors.danger : const Color(0xFFFF6B00),
                ),
              ),
              AppSpacing.w12,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    item['time'] ?? '',
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
                '${item['amount']} ر.ي',
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
                  item['statusText'] ?? '',
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
