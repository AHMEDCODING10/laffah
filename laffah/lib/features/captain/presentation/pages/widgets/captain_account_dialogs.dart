import '../../../../../l10n/app_localizations.dart';
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(
                color: AppColors.primary500.withValues(alpha: 0.25),
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
            AppLocalizations.of(context)!.capt_edit_profile,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h20,
          // Full Name
          _buildTextFieldLabel(AppLocalizations.of(context)!.capt_full_name),
          _buildInputField(
            controller: _nameController,
            hint: AppLocalizations.of(context)!.capt_enter_name_3,
            icon: Icons.person_outline_rounded,
            isDark: isDark,
          ),
          AppSpacing.h16,
          // Phone Number
          _buildTextFieldLabel(
              AppLocalizations.of(context)!.capt_mobile_number),
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
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              AppLocalizations.of(context)!.capt_save_changes,
              style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 14),
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
            AppLocalizations.of(context)!.capt_bike_data,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h16,
          _buildInfoRow(AppLocalizations.of(context)!.capt_bike_type,
              vehicleInfo['type'] ?? '', isDark),
          _buildInfoRow(AppLocalizations.of(context)!.capt_model_year,
              vehicleInfo['model'] ?? '', isDark),
          _buildInfoRow(AppLocalizations.of(context)!.capt_plate_num,
              vehicleInfo['plate'] ?? '', isDark),
          _buildInfoRow(AppLocalizations.of(context)!.capt_license_type,
              vehicleInfo['license'] ?? '', isDark),
          _buildInfoRow(AppLocalizations.of(context)!.capt_periodic_inspection,
              AppLocalizations.of(context)!.capt_valid_documented, isDark,
              color: AppColors.success),
          AppSpacing.h24,
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary500),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'إغلاق',
              style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: AppColors.primary500,
                  fontWeight: FontWeight.bold),
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
            'الوثائق والأوراق الرسمية',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h16,
          _buildDocumentTile(context,
              AppLocalizations.of(context)!.capt_yemeni_id, 'id_card', isDark),
          _buildDocumentTile(
              context,
              AppLocalizations.of(context)!.capt_bike_ownership_card,
              'vehicle_registration',
              isDark),
          AppSpacing.h24,
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'حسناً',
              style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900),
            ),
          ),
          AppSpacing.h16,
        ],
      ),
    );
  }

  Widget _buildDocumentTile(
      BuildContext context, String name, String type, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.gray900,
              ),
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
          _buildTextFieldLabel(
              AppLocalizations.of(context)!.capt_current_password),
          _buildInputField(
              controller: _oldController,
              hint: AppLocalizations.of(context)!.capt_enter_current_pass,
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              obscureText: true),
          AppSpacing.h12,
          _buildTextFieldLabel('كلمة المرور الجديدة'),
          _buildInputField(
              controller: _newController,
              hint: AppLocalizations.of(context)!.capt_enter_new_pass,
              icon: Icons.lock_open_rounded,
              isDark: isDark,
              obscureText: true),
          AppSpacing.h12,
          _buildTextFieldLabel(
              AppLocalizations.of(context)!.capt_confirm_new_pass),
          _buildInputField(
              controller: _confirmController,
              hint: AppLocalizations.of(context)!.capt_reenter_new_pass,
              icon: Icons.verified_user_outlined,
              isDark: isDark,
              obscureText: true),
          AppSpacing.h24,
          ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.success,
                  content: Text(
                    AppLocalizations.of(context)!.capt_pass_updated_success,
                    style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              AppLocalizations.of(context)!.capt_confirm_change_now,
              style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900),
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
            AppLocalizations.of(context)!.capt_help_center,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h16,
          _buildHelpCard(
              AppLocalizations.of(context)!.capt_ways_increase_income,
              AppLocalizations.of(context)!.capt_increase_income_desc,
              isDark),
          _buildHelpCard(AppLocalizations.of(context)!.capt_guide_parcels,
              AppLocalizations.of(context)!.capt_guide_parcels_desc, isDark),
          _buildHelpCard(AppLocalizations.of(context)!.capt_safety_rules,
              AppLocalizations.of(context)!.capt_safety_rules_desc, isDark),
          AppSpacing.h24,
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary500),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(AppLocalizations.of(context)!.capt_understood,
                style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: AppColors.primary500,
                    fontWeight: FontWeight.bold)),
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
          color:
              isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200,
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

  List<Map<String, String>> get _faqs => [
        {
          'q': AppLocalizations.of(context)!.capt_faq_q1,
          'a': AppLocalizations.of(context)!.capt_faq_a1,
        },
        {
          'q': AppLocalizations.of(context)!.capt_faq_q2,
          'a': AppLocalizations.of(context)!.capt_faq_a2,
        },
        {
          'q': AppLocalizations.of(context)!.capt_faq_q3,
          'a': AppLocalizations.of(context)!.capt_faq_a3,
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
            AppLocalizations.of(context)!.capt_faqs_title,
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
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : AppColors.gray50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isExpanded
                        ? AppColors.primary500
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : AppColors.gray200),
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
                              color: isExpanded
                                  ? AppColors.primary500
                                  : (isDark ? Colors.white : AppColors.gray900),
                            ),
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary500,
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
              side: const BorderSide(color: AppColors.primary500),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('إغلاق',
                style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: AppColors.primary500,
                    fontWeight: FontWeight.bold)),
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
          Text(
            AppLocalizations.of(context)!.capt_support_desc,
            style: const TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 11.5,
                color: AppColors.gray500,
                height: 1.4),
          ),
          AppSpacing.h16,
          // Phone Support
          _buildContactButton(
            isDark: isDark,
            label: AppLocalizations.of(context)!.capt_call_support,
            icon: Icons.phone_in_talk_rounded,
            color: AppColors.primary500,
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
            label: AppLocalizations.of(context)!.capt_whatsapp_support,
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
            isPrivacy
                ? AppLocalizations.of(context)!.capt_privacy_policy
                : AppLocalizations.of(context)!.capt_terms_conditions,
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
                ? AppLocalizations.of(context)!.capt_privacy_desc
                : AppLocalizations.of(context)!.capt_terms_desc,
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
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(AppLocalizations.of(context)!.capt_agree,
                style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900)),
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
            AppLocalizations.of(context)!.capt_select_language,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h20,
          _buildLangOption(context,
              AppLocalizations.of(context)!.capt_arabic_ye, 'ar', isDark),
          _buildLangOption(context, 'English (🇬🇧 English)', 'en', isDark),
          AppSpacing.h16,
        ],
      ),
    );
  }

  Widget _buildLangOption(
      BuildContext context, String name, String code, bool isDark) {
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
              ? AppColors.primary500.withValues(alpha: 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : AppColors.gray50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary500
                : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.gray200),
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
                color: isSelected
                    ? AppColors.primary500
                    : (isDark ? Colors.white : AppColors.gray900),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary500, size: 20),
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
      border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.gray200),
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
        hintStyle: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            color: AppColors.gray500),
        icon: Icon(icon, color: AppColors.primary500, size: 18),
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
      border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.gray200),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12.5,
              color: AppColors.gray500,
              fontWeight: FontWeight.bold),
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
