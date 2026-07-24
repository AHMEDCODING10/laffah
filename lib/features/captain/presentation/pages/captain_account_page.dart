import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// CaptainAccountPage - Complete profile and system configurations screen for Laffah Captains.
class CaptainAccountPage extends StatefulWidget {
  const CaptainAccountPage({super.key});

  @override
  State<CaptainAccountPage> createState() => _CaptainAccountPageState();
}

class _CaptainAccountPageState extends State<CaptainAccountPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الحساب الشخصي',
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
              Icons.notifications_none_rounded,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
          child: Column(
            children: [
              // 1. Profile header visual card
              Container(
                padding: const EdgeInsets.all(AppSpacing.s20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  borderRadius: AppSpacing.borderXL,
                  border: Border.all(
                    color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray100,
                  ),
                ),
                child: Row(
                  children: [
                    // Offline safe Custom avatar frame
                    Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const CircleAvatar(
                        radius: 34,
                        backgroundColor: AppColors.primary500,
                        child: Icon(Icons.person_rounded, size: 38, color: Colors.white),
                      ),
                    ),
                    AppSpacing.w16,
                    // Captain detail titles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'أحمد محمد يحيى',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                          AppSpacing.h4,
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary500.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'كابتن متميز',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primary500,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'IBM Plex Sans Arabic',
                                  ),
                                ),
                              ),
                              AppSpacing.w8,
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                              AppSpacing.w2,
                              const Text(
                                '4.9',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.h8,
                          const Text(
                            'دراجة ياماهي • رقم اللوحة: 77213',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.gray500,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary500, size: 28),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ],
                ),
              ),

              AppSpacing.h24,

              // 2. GENERAL SETTINGS MODULE
              _buildSectionTitle('الإعدادات العامة'),
              AppSpacing.h8,
              _buildSettingItem(
                icon: Icons.person_outline_rounded,
                title: 'الملف الشخصي',
                subtitle: 'إعدادات الحساب والبيانات الأساسية',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.motorcycle_rounded,
                title: 'بيانات الدراجة / المركبة',
                subtitle: 'الموديل، لوحة الأرقام، نوع الرخصة',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.description_outlined,
                title: 'الوثائق والأوراق الرسمية',
                subtitle: 'بطاقة الهوية، رخصة القيادة، الفيش والتشبيه',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.lock_outline_rounded,
                title: 'تغيير كلمة المرور',
                subtitle: 'تحديث تفاصيل الأمان للمستودع',
                onTap: () {},
              ),

              AppSpacing.h16,

              // 3. HELP & SUPPORT MODULE
              _buildSectionTitle('الدعم والمساعدة'),
              AppSpacing.h8,
              _buildSettingItem(
                icon: Icons.support_agent_rounded,
                title: 'مركز مساعدة كباتن لفة',
                subtitle: 'تواصل مع الدعم الفني لحل المشاكل التقنية',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.help_outline_rounded,
                title: 'الأسئلة الشائعة',
                subtitle: 'دليل شامل لاستخدام التطبيق وزيادة الدخل',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.contact_support_outlined,
                title: 'تواصل معنا مباشرة',
                subtitle: 'رقم الطوارئ المباشر والمحادثة الحية',
                onTap: () {},
              ),

              AppSpacing.h16,

              // 4. LEGAL MODULE
              _buildSectionTitle('القانونية'),
              AppSpacing.h8,
              _buildSettingItem(
                icon: Icons.gavel_rounded,
                title: 'الشروط والأحكام',
                subtitle: 'اتفاقية الاستخدام وحقوق كابتن لفة',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.security_rounded,
                title: 'سياسة الخصوصية وحماية البيانات',
                subtitle: 'كيف نتعامل مع سرية معلومات كباتننا',
                onTap: () {},
              ),

              AppSpacing.h24,

              // 5. LOG OUT & EXIT BUTTON
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.s12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.06),
                  borderRadius: AppSpacing.borderLG,
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.12),
                  ),
                ),
                child: ListTile(
                  onTap: () => _showLogoutConfirmDialog(context),
                  leading: Container(
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  ),
                  title: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                  subtitle: const Text(
                    'قم بالخروج الآمن من النظام وإلغاء الاستقبال',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.gray500,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.error),
                ),
              ),

              AppSpacing.h24,

              // Footer App Logo & Build Version Details (Using IBM Plex Sans Arabic typography)
              Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'لفّة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary900,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.h8,
                  const Text(
                    'لفة - Laffah Mobile',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: AppColors.gray800,
                    ),
                  ),
                  const Text(
                    'إصدار تطبيق الكابتن 2.4.0 (2026)',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray500,
                    ),
                  ),
                  AppSpacing.h32,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.gray500,
          fontFamily: 'IBM Plex Sans Arabic',
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppSpacing.borderLG,
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray100,
        ),
      ),
      child: ListTile(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.s8),
          decoration: BoxDecoration(
            color: AppColors.primary500.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary500, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.gray500,
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderLG),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic', fontSize: 16),
            ),
            content: const Text(
              'هل أنت متأكد من رغبتك في تسجيل الخروج من تطبيق كابتن لفة؟ سيتم إيقاف استقبال طلبات الركاب والطرود تلقائياً.',
              style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 13, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: AppColors.gray600, fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم الخروج بأمان. نتمنى لك عودة قريبة كابتن لفة!'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'تأكيد الخروج',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
