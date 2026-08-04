import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// Base custom glassmorphic bottom sheet wrapper for unified design aesthetics
Widget _buildGlassSheetWrapper({
  required BuildContext context,
  required Widget child,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF141822).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.96),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(
                color: const Color(0xFFFF6B00).withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  AppSpacing.h20,
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// 1. Edit Profile Modal Sheet
class EditProfileSheet extends StatefulWidget {
  final String currentName;
  final String currentPhone;
  final Function(String name, String phone) onSave;

  const EditProfileSheet({
    super.key,
    required this.currentName,
    required this.currentPhone,
    required this.onSave,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تعديل الملف الشخصي',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h20,
          // Full Name
          _buildTextFieldLabel('الاسم الكامل للكابتن'),
          _buildInputField(
            controller: _nameController,
            hint: 'أدخل الاسم الثلاثي',
            icon: Icons.person_outline_rounded,
            isDark: isDark,
          ),
          AppSpacing.h16,
          // Phone Number
          _buildTextFieldLabel('رقم الهاتف الجوال'),
          _buildInputField(
            controller: _phoneController,
            hint: '77XXXXXXX',
            icon: Icons.phone_android_rounded,
            isDark: isDark,
            keyboardType: TextInputType.phone,
          ),
          AppSpacing.h24,
          // Save Button
          ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
              widget.onSave(_nameController.text, _phoneController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'حفظ التعديلات 💾',
              style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
          AppSpacing.h16,
        ],
      ),
    );
  }
}

/// 2. Vehicle Details Modal Sheet
class VehicleDetailsSheet extends StatelessWidget {
  final Map<String, String> vehicleInfo;

  const VehicleDetailsSheet({super.key, required this.vehicleInfo});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'بيانات دراجة النقل / المركبة',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h16,
          _buildInfoRow('نوع الدراجة النارية', vehicleInfo['type'] ?? '', isDark),
          _buildInfoRow('الموديل وسنة الصنع', vehicleInfo['model'] ?? '', isDark),
          _buildInfoRow('رقم لوحة الأرقام', vehicleInfo['plate'] ?? '', isDark),
          _buildInfoRow('نوع رخصة القيادة', vehicleInfo['license'] ?? '', isDark),
          _buildInfoRow('الفحص الدوري الفني', 'سليم وموثق ✔️', isDark, color: AppColors.success),
          AppSpacing.h24,
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF6B00)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'إغلاق',
              style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', color: Color(0xFFFF6B00), fontWeight: FontWeight.bold),
            ),
          ),
          AppSpacing.h16,
        ],
      ),
    );
  }
}

/// 3. Official Documents Modal Sheet
class OfficialDocumentsSheet extends StatelessWidget {
  const OfficialDocumentsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'الوثائق والأوراق الرسمية الموثقة',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h16,
          _buildDocumentTile('بطاقة الهوية الشخصية (اليمنية)', 'مقبولة ومعتمدة ✔️', isDark),
          _buildDocumentTile('رخصة القيادة البارية', 'مقبولة وصالحة ✔️', isDark),
          _buildDocumentTile('كرت ملكية الدراجة النارية', 'مقبول وموثق ✔️', isDark),
          _buildDocumentTile('صحيفة الحالة الجنائية (الفيش والتشبيه)', 'مقبول ونظيف ✔️', isDark),
          AppSpacing.h24,
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'حسناً',
              style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w900),
            ),
          ),
          AppSpacing.h16,
        ],
      ),
    );
  }

  Widget _buildDocumentTile(String name, String status, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          Text(
            status,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

/// 4. Change Password Modal Sheet
class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تغيير كلمة المرور',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h16,
          _buildTextFieldLabel('كلمة المرور الحالية'),
          _buildInputField(controller: _oldController, hint: 'أدخل كلمة المرور الحالية', icon: Icons.lock_outline_rounded, isDark: isDark, obscureText: true),
          AppSpacing.h12,
          _buildTextFieldLabel('كلمة المرور الجديدة'),
          _buildInputField(controller: _newController, hint: 'أدخل كلمة المرور الجديدة', icon: Icons.lock_open_rounded, isDark: isDark, obscureText: true),
          AppSpacing.h12,
          _buildTextFieldLabel('تأكيد كلمة المرور الجديدة'),
          _buildInputField(controller: _confirmController, hint: 'أعد إدخال كلمة المرور الجديدة', icon: Icons.verified_user_outlined, isDark: isDark, obscureText: true),
          AppSpacing.h24,
          ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.success,
                  content: Text(
                    'تم تحديث كلمة المرور بنجاح 🔒',
                    style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'تأكيد التغيير الآن',
              style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w900),
            ),
          ),
          AppSpacing.h16,
        ],
      ),
    );
  }
}

/// 5. Help Center Modal Sheet
class HelpCenterSheet extends StatelessWidget {
  const HelpCenterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'مركز مساعدة الكباتن',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h16,
          _buildHelpCard('طرق زيادة الدخل اليومي والأسبوعي 📈', 'الالتزام بقبول الطلبات المتتالية وتفعيل خدمات الطرود في أوقات الذروة يزيد أرباحك بنسبة 35%.', isDark),
          _buildHelpCard('دليل نقل وتوصيل الطرود بأمان 📦', 'تأكد دائماً من تغليف الطرد بشكل جيد ومراجعته مع العميل المرسل قبل الاستلام وتسليمه للمستلم.', isDark),
          _buildHelpCard('قواعد السلامة المرورية والقيادة الآمنة 🏍️', 'التزم بالخوذة الواقية والسرعة المحددة في شوارع صنعاء وتجنب السرعة الزائدة حفاظاً على سلامتك.', isDark),
          AppSpacing.h24,
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF6B00)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('فهمت', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', color: Color(0xFFFF6B00), fontWeight: FontWeight.bold)),
          ),
          AppSpacing.h16,
        ],
      ),
    );
  }

  Widget _buildHelpCard(String title, String body, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 11,
              color: AppColors.gray500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// 6. FAQ Modal Sheet
class FAQSheet extends StatefulWidget {
  const FAQSheet({super.key});

  @override
  State<FAQSheet> createState() => _FAQSheetState();
}

class _FAQSheetState extends State<FAQSheet> {
  int _expandedIndex = -1;

  final List<Map<String, String>> _faqs = const [
    {
      'q': 'ما هي عمولة تطبيق لَفَّة المخصومة من الكابتن؟',
      'a': 'عمولة المنصة ثابتة وهي 10% فقط من إجمالي قيمة الأجرة الفعلية للرحلة لضمان توفير أعلى ربح ممكن لكابتن الدراجة النارية.',
    },
    {
      'q': 'متى وبأي وسيلة يتم تحويل رصيد الأرباح؟',
      'a': 'يتم تحويل الأرباح فوريّاً عند تقديم الطلب عبر صرافة الكريمي (أم فلوس)، أو محافظ جيب، أو فلوسك، أو جوالي، أو ون كاش في اليمن.',
    },
    {
      'q': 'ماذا يحدث في حال إلغاء العميل للمشوار بعد وصولي؟',
      'a': 'يتم احتساب تعويض مالي مباشر لصالح الكابتن (رسوم إلغاء العميل) ويضاف تلقائياً إلى رصيد محفظتك القابل للسحب.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'الأسئلة الشائعة والأجوبة',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h16,
          ..._faqs.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isExpanded = _expandedIndex == idx;

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _expandedIndex = isExpanded ? -1 : idx;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isExpanded
                        ? const Color(0xFFFF6B00)
                        : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['q']!,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: isExpanded ? const Color(0xFFFF6B00) : (isDark ? Colors.white : AppColors.gray900),
                            ),
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFFFF6B00),
                          size: 20,
                        ),
                      ],
                    ),
                    if (isExpanded) ...[
                      const SizedBox(height: 8),
                      Text(
                        item['a']!,
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 11.5,
                          color: AppColors.gray500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          AppSpacing.h24,
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF6B00)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('إغلاق', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', color: Color(0xFFFF6B00), fontWeight: FontWeight.bold)),
          ),
          AppSpacing.h16,
        ],
      ),
    );
  }
}

/// 7. Direct Support Modal Sheet
class DirectSupportSheet extends StatelessWidget {
  const DirectSupportSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تواصل معنا مباشرة',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h12,
          const Text(
            'فريق دعم الكباتن المخصص في صنعاء متواجد لمساعدتك 24 ساعة طوال أيام الأسبوع.',
            style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 11.5, color: AppColors.gray500, height: 1.4),
          ),
          AppSpacing.h16,
          // Phone Support
          _buildContactButton(
            isDark: isDark,
            label: 'اتصال هاتفي مباشر بالدعم',
            icon: Icons.phone_in_talk_rounded,
            color: const Color(0xFFFF6B00),
            onTap: () async {
              Navigator.pop(context);
              final uri = Uri.parse('tel:770291452');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          AppSpacing.h10,
          // WhatsApp Support
          _buildContactButton(
            isDark: isDark,
            label: 'مراسلة عبر واتساب الدعم',
            icon: Icons.chat_rounded,
            color: const Color(0xFF25D366),
            onTap: () async {
              Navigator.pop(context);
              final uri = Uri.parse('whatsapp://send?phone=967770291452');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          AppSpacing.h24,
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required bool isDark,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 8. Terms and Privacy Modal Sheet
class TermsAndPrivacySheet extends StatelessWidget {
  final bool isPrivacy;

  const TermsAndPrivacySheet({super.key, required this.isPrivacy});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isPrivacy ? 'سياسة الخصوصية وسرية البيانات' : 'الشروط والأحكام ووثيقة الاستخدام',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h16,
          Text(
            isPrivacy
                ? 'يلتزم تطبيق لَفَّة بحفظ كامل خصوصية بيانات كباتن الدراجات النارية والعملاء في صنعاء. نقوم بجمع إحداثيات الموقع الجغرافي فقط أثناء تشغيل حالة الاتصال وجاري العمل لتقديم أفضل مسار ومطابقة للرحلات. لا نقوم بمشاركة أي بيانات مع أي طرف ثالث على الإطلاق.'
                : 'يقر الكابتن المسجل في لَفَّة بضرورة الالتزام بقواعد المرور والتعليمات المنصوص عليها في اليمن، وضمان سلامة الطرود المنقولة والالتزام بالتسعيرة الرسمية المحسوبة عبر خوارزميات التطبيق دون زيادة أو تغيير. تحتفظ المنصة بحق إيقاف الحسابات المخالفة للبنود.',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              height: 1.5,
              color: isDark ? AppColors.gray300 : AppColors.gray800,
            ),
          ),
          AppSpacing.h24,
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('أوافق', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w900)),
          ),
          AppSpacing.h16,
        ],
      ),
    );
  }
}

/// 9. Language Selector Modal Sheet
class LanguageSelectorSheet extends StatelessWidget {
  final String currentLang;
  final Function(String lang) onSelected;

  const LanguageSelectorSheet({
    super.key,
    required this.currentLang,
    required this.onSelected,
  });

  static void show({
    required BuildContext context,
    required String currentLang,
    required Function(String lang) onSelected,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSelectorSheet(
        currentLang: currentLang,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اختر لغة التطبيق / Select Language',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h20,
          _buildLangOption(context, 'العربية (🇾🇪 العربية)', 'ar', isDark),
          _buildLangOption(context, 'English (🇬🇧 English)', 'en', isDark),
          AppSpacing.h16,
        ],
      ),
    );
  }

  Widget _buildLangOption(BuildContext context, String name, String code, bool isDark) {
    final isSelected = currentLang == code;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pop(context);
        onSelected(code);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF6B00).withValues(alpha: 0.12)
              : (isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B00) : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                fontSize: 13,
                color: isSelected ? const Color(0xFFFF6B00) : (isDark ? Colors.white : AppColors.gray900),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFFFF6B00), size: 20),
          ],
        ),
      ),
    );
  }
}

/// Helper Label widgets
Widget _buildTextFieldLabel(String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6, right: 4),
    child: Text(
      label,
      style: const TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.gray500,
      ),
    ),
  );
}

/// Helper Input Field
Widget _buildInputField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  required bool isDark,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.gray200),
    ),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.gray900,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12, color: AppColors.gray500),
        icon: Icon(icon, color: const Color(0xFFFF6B00), size: 18),
      ),
    ),
  );
}

/// Helper Row Info renderer
Widget _buildInfoRow(String label, String value, bool isDark, {Color? color}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12.5, color: AppColors.gray500, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            color: color ?? (isDark ? Colors.white : AppColors.gray900),
          ),
        ),
      ],
    ),
  );
}
