import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'سياسة الخصوصية',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('مقدمة', isDark),
              _buildSectionText(
                'نحن في تطبيق "لَفَّة" نقدر خصوصيتك بشكل كبير ونلتزم بحماية بياناتك الشخصية. توضح هذه السياسة كيف نقوم بجمع واستخدام وحماية معلوماتك عند استخدام تطبيقنا المخصص للنقل في اليمن وتحديداً صنعاء.',
                isDark,
              ),
              AppSpacing.h24,
              
              _buildSectionTitle('المعلومات التي نجمعها', isDark),
              _buildSectionText(
                '• بيانات التسجيل: الاسم، رقم الهاتف، والبريد الإلكتروني.\n'
                '• بيانات الموقع (GPS): نجمع بيانات موقعك الحالي لربطك بأقرب كابتن متاح.\n'
                '• بيانات المعاملات: تفاصيل الرحلات، المبالغ المدفوعة، وتقييمات الكباتن.',
                isDark,
              ),
              AppSpacing.h24,

              _buildSectionTitle('كيف نستخدم معلوماتك', isDark),
              _buildSectionText(
                'نستخدم هذه المعلومات لتقديم خدماتنا وتحسينها، لضمان سلامتك أثناء الرحلة، ולتوفير دعم فني سريع وفعال.',
                isDark,
              ),
              AppSpacing.h24,

              _buildSectionTitle('حماية البيانات', isDark),
              _buildSectionText(
                'يتم تشفير كافة بياناتك الحساسة وحفظها في خوادم آمنة. نحن لا نشارك بياناتك مع أي جهات خارجية لأغراض تسويقية.',
                isDark,
              ),
              AppSpacing.h32,
              
              const Center(
                child: Text(
                  'آخر تحديث: 2026',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: AppColors.gray500,
                    fontSize: 12,
                  ),
                ),
              ),
              AppSpacing.h32,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.w900,
          fontSize: 16,
          color: isDark ? AppColors.primary400 : AppColors.primary600,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        fontSize: 14,
        height: 1.6,
        color: isDark ? AppColors.gray400 : AppColors.gray700,
      ),
    );
  }
}
