import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/captain_action_button.dart';

/// CaptainEarningsPage - Premium financial dashboard wallet layout for Laffah Captains.
class CaptainEarningsPage extends StatefulWidget {
  const CaptainEarningsPage({super.key});

  @override
  State<CaptainEarningsPage> createState() => _CaptainEarningsPageState();
}

class _CaptainEarningsPageState extends State<CaptainEarningsPage> {
  // Target daily earnings simulation (Target = 5,000 YER, Current = 4,250 YER)
  final double _dailyTarget = 5000.0;
  final double _currentEarnings = 4250.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (_currentEarnings / _dailyTarget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.s12, top: AppSpacing.s8, bottom: AppSpacing.s8),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.white.withOpacity(0.12) : AppColors.gray200,
                width: 1.5,
              ),
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary500,
              child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
        title: Text(
          'الأرباح المحفظة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: 'IBM Plex Sans Arabic',
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          children: [
            // Net Earnings Card with Brand Gradient Highlight
            Container(
              padding: const EdgeInsets.all(AppSpacing.s20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.white,
                borderRadius: AppSpacing.borderXL,
                border: Border.all(
                  color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray100,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'الرصيد القابل للتحويل',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray500,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                  AppSpacing.h8,
                  Text(
                    '${_currentEarnings.toStringAsFixed(0)} ر.ي',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary900,
                      letterSpacing: 0.5,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                  AppSpacing.h12,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up_rounded, color: AppColors.success, size: 14),
                        AppSpacing.w6,
                        Text(
                          'أعلى بنسبة 12% من الأسبوع الماضي',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.h20,

                  // Daily Target Dynamic Progress Bar (Innovation Feature)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'هدف الأرباح اليومي',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray500,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}% (${_dailyTarget.toInt()} ر.ي)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary500,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.h8,
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: isDark ? AppColors.gray850 : AppColors.gray200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            AppSpacing.h16,

            // Stats row with two cards: أرباح اليوم and أرباح الأسبوع
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.white,
                      borderRadius: AppSpacing.borderLG,
                      border: Border.all(
                        color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray100,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أرباح الأسبوع',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray500,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                        AppSpacing.h4,
                        Text(
                          '21,500 ر.ي',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                        AppSpacing.h8,
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, color: AppColors.primary500, size: 12),
                            AppSpacing.w6,
                            Text(
                              'الأسبوع الحالي',
                              style: TextStyle(
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
                AppSpacing.w12,
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.white,
                      borderRadius: AppSpacing.borderLG,
                      border: Border.all(
                        color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray100,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
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
                          '4,250 ر.ي',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                        AppSpacing.h8,
                        Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 12),
                            AppSpacing.w6,
                            Text(
                              '12 رحلة مكتملة',
                              style: TextStyle(
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
              ],
            ),

            AppSpacing.h16,

            // Payout Request Action
            CaptainActionButton(
              label: 'طلب تحويل الأرباح',
              icon: Icons.account_balance_wallet_rounded,
              onPressed: () => _showPayoutBottomSheet(context, isDark),
            ),

            AppSpacing.h8,
            const Center(
              child: Text(
                'يتم معالجة الطلبات عبر الكريمي/جوالي خلال 24 ساعة',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.gray500,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
            ),

            AppSpacing.h24,

            // History Records Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'سجل المعاملات والأرباح',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'عرض الكل >',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary500,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.h12,

            // Transactions
            _buildTransactionItem(
              title: 'تحويل بنكي ناجح (الكريمي)',
              time: 'اليوم • 10:30 صباحاً',
              amount: '- 3,500',
              statusText: 'مكتمل',
              statusColor: AppColors.success,
              icon: Icons.account_balance_rounded,
              iconBgColor: AppColors.success.withOpacity(0.12),
              iconColor: AppColors.success,
              isNegative: true,
            ),
            _buildTransactionItem(
              title: 'رحلة رقم #LF-8829',
              time: 'اليوم • 09:15 صباحاً',
              amount: '+ 1,800',
              statusText: 'تمت الإضافة',
              statusColor: AppColors.primary500,
              icon: Icons.motorcycle_rounded,
              iconBgColor: AppColors.primary500.withOpacity(0.12),
              iconColor: AppColors.primary500,
              isNegative: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String time,
    required String amount,
    required String statusText,
    required Color statusColor,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool isNegative,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppSpacing.borderLG,
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray100,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              AppSpacing.w16,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 10,
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
                '$amount ر.ي',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isNegative ? AppColors.danger : AppColors.primary500,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              AppSpacing.h4,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 9,
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

  void _showPayoutBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.s24),
          topRight: Radius.circular(AppSpacing.s24),
        ),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.s20,
              right: AppSpacing.s20,
              top: AppSpacing.s20,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.gray400,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
                AppSpacing.h16,
                const Text(
                  'اختر طريقة تحويل الأرباح',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic'),
                ),
                AppSpacing.h20,
                _buildPayoutOption(
                  icon: Icons.account_balance_rounded,
                  title: 'صرافة الكريمي (حساب أم فلوس)',
                  subtitle: 'سحب نقدي فوري برقم الهوية الوطنية',
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                    _showSuccessMessage(context);
                  },
                ),
                _buildPayoutOption(
                  icon: Icons.wallet_rounded,
                  title: 'محفظة جوالي / كاش اليمن',
                  subtitle: 'تصل مباشرة لحساب محفظتك المسجل',
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                    _showSuccessMessage(context);
                  },
                ),
                AppSpacing.h12,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPayoutOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.s10),
      color: AppColors.primary500.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderMD,
        side: BorderSide(color: AppColors.primary500.withOpacity(0.12)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary500),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic'),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 10, color: AppColors.gray500, fontFamily: 'IBM Plex Sans Arabic'),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.success,
        content: Text(
          'تم تقديم طلب سحب الأرباح بنجاح! جاري المعالجة وإعلامك فور الإيداع.',
          style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
