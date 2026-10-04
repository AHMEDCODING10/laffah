import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/laffah_glass_snackbar.dart';

class PassengerSupportPage extends StatelessWidget {
  const PassengerSupportPage({super.key});

  static const String _supportPhone = '967770291452';
  static const String _supportEmail = 'support@laffah.com';

  Future<void> _launchWhatsApp(BuildContext context) async {
    HapticFeedback.lightImpact();
    final message = Uri.encodeComponent('السلام عليكم، أحتاج مساعدة في تطبيق لَفَّة.');
    final Uri webUrl = Uri.parse('https://wa.me/$_supportPhone?text=$message');
    final Uri appUrl = Uri.parse('whatsapp://send?phone=$_supportPhone&text=$message');

    try {
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    // Fallback if WhatsApp is not installed
    await Clipboard.setData(const ClipboardData(text: _supportPhone));
    if (context.mounted) {
      LaffahSnackBar.showSuccess(
        context,
        'تم نسخ رقم الدعم الفني: +$_supportPhone',
      );
    }
  }

  Future<void> _launchCall(BuildContext context) async {
    HapticFeedback.lightImpact();
    final Uri uri = Uri.parse('tel:+$_supportPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    await Clipboard.setData(const ClipboardData(text: '+$_supportPhone'));
    if (context.mounted) {
      LaffahSnackBar.showSuccess(
        context,
        'تم نسخ رقم الهاتف: +$_supportPhone',
      );
    }
  }

  Future<void> _launchEmail(BuildContext context) async {
    HapticFeedback.lightImpact();
    final subject = Uri.encodeComponent('دعم فني - تطبيق لَفَّة');
    final Uri uri = Uri.parse('mailto:$_supportEmail?subject=$subject');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    await Clipboard.setData(const ClipboardData(text: _supportEmail));
    if (context.mounted) {
      LaffahSnackBar.showSuccess(
        context,
        'تم نسخ البريد الإلكتروني: $_supportEmail',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.gray50,
      appBar: AppBar(
        title: const Text(
          'الدعم الفني',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
            ),
            AppSpacing.h24,
            Text(
              'كيف يمكننا مساعدتك؟',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.gray900,
              ),
            ),
            AppSpacing.h8,
            Text(
              'فريق الدعم الفني متواجد على مدار الساعة للرد على استفساراتكم وحل أي مشكلة تواجهونها.',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 14,
                color: isDark ? Colors.grey[400] : AppColors.gray600,
              ),
            ),
            AppSpacing.h32,
            _SupportOption(
              icon: Icons.chat_outlined,
              title: 'مراسلة عبر واتساب',
              subtitle: 'أسرع طريقة للتواصل مع فريق الدعم',
              onTap: () => _launchWhatsApp(context),
              isDark: isDark,
              iconColor: const Color(0xFF25D366),
            ),
            AppSpacing.h16,
            _SupportOption(
              icon: Icons.phone_outlined,
              title: 'اتصال هاتفي',
              subtitle: 'للحالات الطارئة والمستعجلة',
              onTap: () => _launchCall(context),
              isDark: isDark,
              iconColor: AppColors.primary,
            ),
            AppSpacing.h16,
            _SupportOption(
              icon: Icons.email_outlined,
              title: 'البريد الإلكتروني',
              subtitle: 'للاستفسارات العامة والاقتراحات',
              onTap: () => _launchEmail(context),
              isDark: isDark,
              iconColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;
  final Color iconColor;

  const _SupportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray850 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
