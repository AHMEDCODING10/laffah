import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

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
            'الشروط والأحكام',
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
              _buildSectionTitle('قبول الشروط', isDark),
              _buildSectionText(
                'باستخدامك لتطبيق "لَفَّة"، فإنك توافق على الالتزام بجميع الشروط والأحكام الموضحة هنا. إذا كنت لا توافق على أي من هذه الشروط، يُرجى التوقف عن استخدام التطبيق فوراً.',
                isDark,
              ),
              AppSpacing.h24,
              
              _buildSectionTitle('التزامات المستخدم (الراكب/الكابتن)', isDark),
              _buildSectionText(
                '• يجب تقديم معلومات صحيحة ودقيقة أثناء التسجيل.\n'
                '• يمنع استخدام التطبيق لأي أغراض غير قانونية أو نقل مواد محظورة.\n'
                '• يلتزم الكابتن بمعايير السلامة والنظافة والأخلاق العامة أثناء الرحلة.',
                isDark,
              ),
              AppSpacing.h24,

              _buildSectionTitle('الأجور والدفع', isDark),
              _buildSectionText(
                'تُحسب الأجرة بناءً على المسافة والوقت الفعلي للرحلة. الركاب ملزمون بدفع القيمة المحددة نقداً أو عبر المحفظة الإلكترونية المعتمدة فور انتهاء الرحلة.',
                isDark,
              ),
              AppSpacing.h24,

              _buildSectionTitle('إخلاء المسؤولية', isDark),
              _buildSectionText(
                'يعمل تطبيق لَفَّة كوسيط تقني بين الراكب والكابتن، ولا يتحمل مسؤولية مباشرة عن أي مفقودات شخصية داخل المركبة، مع التزامنا بالتعاون التام مع الجهات الأمنية إذا لزم الأمر.',
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
