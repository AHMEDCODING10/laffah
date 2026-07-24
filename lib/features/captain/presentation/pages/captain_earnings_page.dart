import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// CaptainEarningsPage - Premium financial dashboard wallet layout for Laffah Captains.
/// Displays total earnings, stats grids, interactive target bonus bars, and historic lists.
class CaptainEarningsPage extends StatefulWidget {
  const CaptainEarningsPage({super.key});

  @override
  State<CaptainEarningsPage> createState() => _CaptainEarningsPageState();
}

class _CaptainEarningsPageState extends State<CaptainEarningsPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
            ),
          ),
        ),
        title: Text(
          'الأرباح',
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
            onPressed: () {},
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
                  const Text(
                    '4,250 ر.ي',
                    style: TextStyle(
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.trending_up_rounded, color: AppColors.success, size: 14),
                        AppSpacing.w6,
                        Text(
                          'أعلى بنسبة 12%',
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
                ],
              ),
            ),

            AppSpacing.h16,

            // Stats row with two cards: أرباح اليوم and أرباح الأسبوع
            Row(
              children: [
                // أرباح الأسبوع
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'أرباح الأسبوع',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray500,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                        AppSpacing.h4,
                        const Text(
                          '2,150 ر.ي',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gray900,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                        AppSpacing.h8,
                        Row(
                          children: const [
                            Icon(Icons.calendar_today_rounded, color: AppColors.primary500, size: 12),
                            AppSpacing.w6,
                            Text(
                              'الأسبوع 14',
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
                // أرباح اليوم
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
                        const Text(
                          '320 ر.ي',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gray900,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                        AppSpacing.h8,
                        Row(
                          children: const [
                            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 12),
                            AppSpacing.w6,
                            Text(
                              '12 رحلة',
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

            // Monthly Earnings card with miniature bar chart
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أرباح الشهر',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray500,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      AppSpacing.h4,
                      const Text(
                        '8,900 ر.ي',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.gray900,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ],
                  ),
                  // Compact bar chart graphic
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildMiniBar(40.0, true),
                      _buildMiniBar(20.0, false),
                      _buildMiniBar(32.0, false),
                      _buildMiniBar(12.0, false),
                      _buildMiniBar(25.0, false),
                      _buildMiniBar(18.0, false),
                    ],
                  ),
                ],
              ),
            ),

            AppSpacing.h20,

            // Brand Gradient Button: طلب تحويل الأرباح
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppSpacing.radiusLG,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary500.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showPayoutBottomSheet(context, isDark),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.radiusLG,
                  ),
                ),
                icon: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'طلب تحويل الأرباح',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
              ),
            ),

            AppSpacing.h8,
            const Center(
              child: Text(
                'يتم معالجة الطلبات خلال 24 ساعة عمل',
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
                  'سجل الأرباح',
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

            // Historic records items
            _buildTransactionItem(
              title: 'تحويل بنكي ناجح',
              time: '12 أكتوبر 2023 • 10:30 صباحاً',
              amount: '- 3,500',
              statusText: 'مكتمل',
              statusColor: AppColors.success,
              icon: Icons.account_balance_rounded,
              iconBgColor: AppColors.success.withOpacity(0.12),
              iconColor: AppColors.success,
              isNegative: true,
            ),
            _buildTransactionItem(
              title: 'رحلة رقم #8829',
              time: '12 أكتوبر 2023 • 09:15 صباحاً',
              amount: '+ 450',
              statusText: 'تمت الإضافة',
              statusColor: AppColors.gray500,
              icon: Icons.motorcycle_rounded,
              iconBgColor: AppColors.primary500.withOpacity(0.12),
              iconColor: AppColors.primary500,
              isNegative: false,
            ),
            _buildTransactionItem(
              title: 'رحلة رقم #8821',
              time: '11 أكتوبر 2023 • 11:45 مساءً',
              amount: '+ 620',
              statusText: 'تمت الإضافة',
              statusColor: AppColors.gray500,
              icon: Icons.motorcycle_rounded,
              iconBgColor: AppColors.primary500.withOpacity(0.12),
              iconColor: AppColors.primary500,
              isNegative: false,
            ),
            _buildTransactionItem(
              title: 'طلب تحويل معلق',
              time: '10 أكتوبر 2023 • 08:00 صباحاً',
              amount: '- 1,200',
              statusText: 'قيد المراجعة',
              statusColor: AppColors.warning,
              icon: Icons.history_rounded,
              iconBgColor: AppColors.warning.withOpacity(0.12),
              iconColor: AppColors.warning,
              isNegative: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBar(double height, bool isHighlighted) {
    return Container(
      margin: const EdgeInsets.only(left: 4.0),
      width: 14,
      height: height,
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primary900 : AppColors.primary100,
        borderRadius: BorderRadius.circular(3),
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.white,
        borderRadius: AppSpacing.radiusLG,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.white.withOpacity(0.04)
              : AppColors.gray100,
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
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isNegative ? AppColors.gray900 : AppColors.primary500,
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
            padding: const EdgeInsets.all(AppSpacing.s20),
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
                  'اختر حساب التحويل المالي للكابتن',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic'),
                ),
                AppSpacing.h20,
                _buildPayoutOption(
                  icon: Icons.account_balance_rounded,
                  title: 'صرافة الكريمي (حساب أم فلوس)',
                  subtitle: 'سحب نقدي فوري بالرقم القومي',
                  onTap: () {
                    Navigator.pop(context);
                    _showSuccessMessage(context);
                  },
                ),
                _buildPayoutOption(
                  icon: Icons.wallet_rounded,
                  title: 'محفظة جوالي / كاش اليمن',
                  subtitle: 'تصل مباشرة لرقم هاتفك المسجل',
                  onTap: () {
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
        side: BorderSide(color: AppColors.primary500.withOpacity(0.1)),
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
          'تم تقديم طلب سحب الأرباح بنجاح! جاري معالجة التحويل كأولوية قصوى لكابتن لفة.',
          style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
