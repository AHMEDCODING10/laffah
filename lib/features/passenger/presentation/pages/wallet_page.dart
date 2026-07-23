import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// WalletPage — Displays Passenger's balance in YER (Yemeni Rial) and recent transactions.
/// Emphasizes local payment channels (Al-Kuraimi, Floos, Jawali).
class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.white : AppColors.gray900, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'المحفظة',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.s24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8C00), Color(0xFFFF6B00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppSpacing.radiusLG,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B00).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الرصيد المتاح',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    AppSpacing.h8,
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '4,500',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        SizedBox(width: 8),
                        Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text(
                            'ريال (YER)',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.h24,
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFFF6B00),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppSpacing.radiusMD,
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: const Text(
                              'شحن الرصيد',
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              AppSpacing.h32,
              
              Text(
                'سجل العمليات',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              AppSpacing.h16,
              
              // Transactions List
              _buildTransactionItem(
                title: 'رحلة دراجة نارية - شارع الستين',
                date: 'اليوم، 10:30 صباحاً',
                amount: '- 1,200',
                isNegative: true,
                isDark: isDark,
              ),
              _buildTransactionItem(
                title: 'شحن رصيد - الكريمي إكسبرس',
                date: 'أمس، 04:15 عصراً',
                amount: '+ 5,000',
                isNegative: false,
                isDark: isDark,
              ),
              _buildTransactionItem(
                title: 'رحلة دراجة نارية - حدة',
                date: '18 يوليو 2026',
                amount: '- 800',
                isNegative: true,
                isDark: isDark,
              ),
              _buildTransactionItem(
                title: 'توصيل طرد - الجامعة',
                date: '15 يوليو 2026',
                amount: '- 1,500',
                isNegative: true,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String date,
    required String amount,
    required bool isNegative,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isNegative 
                  ? AppColors.danger.withOpacity(0.1)
                  : AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isNegative ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: isNegative ? AppColors.danger : AppColors.success,
              size: 20,
            ),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isNegative ? AppColors.danger : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

