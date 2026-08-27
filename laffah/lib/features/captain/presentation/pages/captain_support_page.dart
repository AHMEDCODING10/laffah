import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class CaptainSupportPage extends StatelessWidget {
  const CaptainSupportPage({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: isDark ? AppColors.white : AppColors.gray900),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'الدعم الفني للكباتن',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.s20),
          children: [
            // Contact Support Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.s20),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.1),
                borderRadius: AppSpacing.radiusLG,
                border: Border.all(
                    color: AppColors.primary500.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.headset_mic_rounded,
                      color: AppColors.primary500, size: 48),
                  AppSpacing.h16,
                  Text(
                    'كيف يمكننا مساعدتك يا كابتن؟',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                  AppSpacing.h8,
                  Text(
                    'فريق دعم لَفَّة متاح على مدار الساعة لحل أي مشكلة تواجهك أثناء العمل.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 13,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                  AppSpacing.h20,
                  ElevatedButton.icon(
                    onPressed: () => _launchUrl(
                        'https://wa.me/967777123456'), // WhatsApp mock link
                    icon:
                        const Icon(Icons.chat_rounded, color: AppColors.white),
                    label: const Text(
                      'ابدأ محادثة مع الدعم',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      minimumSize: const Size(double.infinity, 48),
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppSpacing.radiusMD),
                    ),
                  ),
                  AppSpacing.h12,
                  OutlinedButton.icon(
                    onPressed: () => _launchUrl('tel:+967777123456'),
                    icon: const Icon(Icons.call_rounded,
                        color: AppColors.primary500),
                    label: const Text(
                      'اتصل هاتفياً (للحالات الطارئة)',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary500),
                      minimumSize: const Size(double.infinity, 48),
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppSpacing.radiusMD),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.h32,

            Text(
              'الأسئلة الشائعة',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),
            AppSpacing.h16,
            _buildFaqItem(
              title: 'كيف يتم احتساب نسبة المنصة؟',
              content:
                  'نسبة المنصة هي 15% من إجمالي قيمة الرحلة وتُخصم تلقائياً من محفظتك بعد انتهاء الرحلة.',
              isDark: isDark,
            ),
            _buildFaqItem(
              title: 'الراكب لم يدفع الأجرة، ماذا أفعل؟',
              content:
                  'يمكنك رفع بلاغ (رحلة غير مدفوعة) من شاشة تفاصيل الرحلة، وسيقوم فريق الدعم بالتحقق وتعويضك.',
              isDark: isDark,
            ),
            _buildFaqItem(
              title: 'كيف أستلم أرباحي؟',
              content:
                  'يمكنك سحب أرباحك أسبوعياً من شاشة السحب المالي لحسابك البنكي أو لمحفظة فلوس/جيب.',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(
      {required String title, required String content, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.white,
        borderRadius: AppSpacing.radiusSM,
        border: Border.all(
            color: isDark
                ? AppColors.white.withValues(alpha: 0.05)
                : AppColors.gray200),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        iconColor: AppColors.primary500,
        collapsedIconColor: isDark ? AppColors.gray500 : AppColors.gray400,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s16),
            child: Text(
              content,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 13,
                height: 1.6,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
