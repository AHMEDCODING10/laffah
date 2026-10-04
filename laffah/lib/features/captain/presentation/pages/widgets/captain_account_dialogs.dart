import '../../../../../l10n/app_localizations.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/laffah_glass_snackbar.dart';
import '../../../../profile/presentation/widgets/faq_bottom_sheet.dart';
import '../../../../profile/presentation/pages/legal/terms_of_service_page.dart';
import '../../../../profile/presentation/pages/legal/privacy_policy_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// Base custom glassmorphic bottom sheet wrapper for unified design aesthetics
Widget _buildGlassSheetWrapper({
  required BuildContext context,
  required Widget child,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

  return Directionality(
    textDirection: TextDirection.rtl,
    child: AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutQuad,
      padding: EdgeInsets.only(bottom: keyboardHeight),
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
class OfficialDocumentsSheet extends StatefulWidget {
  const OfficialDocumentsSheet({super.key});

  @override
  State<OfficialDocumentsSheet> createState() => _OfficialDocumentsSheetState();
}

class _OfficialDocumentsSheetState extends State<OfficialDocumentsSheet> {
  final List<Map<String, dynamic>> _documents = [
    {
      'id': 'id_card',
      'name': 'البطاقة الشخصية اليمنية',
      'number': '01010048291',
      'validity': 'سارية حتى 2028/11',
      'isVerified': true,
      'statusLabel': 'معتمد وموثق',
      'icon': Icons.badge_outlined,
    },
    {
      'id': 'vehicle_card',
      'name': 'كرت ملكية الدراجة النارية',
      'number': '1/ص 48291 - صنعاء',
      'validity': 'سارية حتى 2027/08',
      'isVerified': true,
      'statusLabel': 'معتمد وموثق',
      'icon': Icons.two_wheeler_rounded,
    },
    {
      'id': 'license',
      'name': 'رخصة قيادة دراجة نارية',
      'number': 'DL-967-382910',
      'validity': 'سارية حتى 2029/04',
      'isVerified': true,
      'statusLabel': 'معتمد وموثق',
      'icon': Icons.card_membership_rounded,
    },
    {
      'id': 'inspection',
      'name': 'شهادة الفحص الفني الدوري',
      'number': 'INSP-2026-8812',
      'validity': 'ساري حتى 2027/01',
      'isVerified': true,
      'statusLabel': 'معتمد وموثق',
      'icon': Icons.fact_check_outlined,
    },
  ];

  void _showDocumentPreview(Map<String, dynamic> doc, bool isDark) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF141822) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(doc['icon'] as IconData,
                    color: AppColors.primary500, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  doc['name'] as String,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: isDark ? Colors.white : AppColors.gray900,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : AppColors.gray100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.gray200,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      size: 40,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'وثيقة رسمية معتمدة ومطابقة للمعايير',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.gray300 : AppColors.gray700,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.h16,
              _buildModalDetailRow('رقم الوثيقة:', doc['number'] as String, isDark),
              AppSpacing.h8,
              _buildModalDetailRow('فترة الصلاحية:', doc['validity'] as String, isDark),
              AppSpacing.h8,
              _buildModalDetailRow('حالة التحقق:', doc['statusLabel'] as String, isDark,
                  valueColor: AppColors.success),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'إغلاق',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalDetailRow(String label, String value, bool isDark,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            color: AppColors.gray500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isDark ? Colors.white : AppColors.gray900),
          ),
        ),
      ],
    );
  }

  void _showUploadOption(Map<String, dynamic> doc) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141822) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                AppSpacing.h16,
                Text(
                  'تحديث ${doc['name']}',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h16,
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.primary500),
                  title: const Text('التقاط صورة عبر الكاميرا',
                      style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    LaffahSnackBar.success(
                      context,
                      'تم التقاط الوثيقة وجاري التحقق من مطابقتها عبر النظام',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded,
                      color: AppColors.primary500),
                  title: const Text('اختيار ملف من المعرض',
                      style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    LaffahSnackBar.success(
                      context,
                      'تم رفع الوثيقة بنجاح وسيتم اعتمادها خلال وقت وجيز',
                    );
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.folder_shared_rounded,
                      color: AppColors.primary500,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'الوثائق والأوراق الرسمية',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'مكتملة وموثقة',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.h8,
          const Text(
            'جميع وثائق اعتماد كابتن لَفَّة الرسمية وفق اشتراطات السلامة واللوائح في الجمهورية اليمنية.',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 11.5,
              color: AppColors.gray500,
              height: 1.4,
            ),
          ),
          AppSpacing.h16,
          ..._documents.map((doc) => _buildDocumentCard(doc, isDark)),
          AppSpacing.h20,
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'حسناً، فهمت',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          AppSpacing.h16,
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : AppColors.gray50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  doc['icon'] as IconData,
                  color: AppColors.primary500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['name'] as String,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${doc['number']} • ${doc['validity']}',
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  doc['statusLabel'] as String,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showDocumentPreview(doc, isDark),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text(
                    'عرض الوثيقة',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary500,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
              Container(width: 1, height: 18, color: AppColors.gray300),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showUploadOption(doc),
                  icon: const Icon(Icons.file_upload_outlined, size: 16),
                  label: const Text(
                    'تحديث / تعديل',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? AppColors.gray300 : AppColors.gray700,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
            ],
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
class FAQSheet extends StatelessWidget {
  const FAQSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const LaffahFaqBottomSheet(initialCategory: 'captain');
  }
}

/// 7. Direct Support Modal Sheet
class DirectSupportSheet extends StatelessWidget {
  const DirectSupportSheet({super.key});

  static const String _supportPhone = '770291452';
  static const String _fullPhone = '+967770291452';
  static const String _supportEmail = 'support@laffah.com';

  Future<void> _launchOrCopy(
    BuildContext context, {
    required String urlString,
    required String fallbackCopyText,
    required String fallbackMessage,
  }) async {
    Navigator.pop(context);
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await Clipboard.setData(ClipboardData(text: fallbackCopyText));
        if (context.mounted) {
          LaffahSnackBar.info(context, fallbackMessage);
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: fallbackCopyText));
      if (context.mounted) {
        LaffahSnackBar.info(context, fallbackMessage);
      }
    }
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
            'تواصل مع الدعم الفني للكباتن',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h8,
          const Text(
            'فريق دعم لَفَّة متاح لمساعدتك على مدار 24 ساعة في جميع مشاكل الرحلات، الحساب والمحفظة.',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              color: AppColors.gray500,
              height: 1.4,
            ),
          ),
          AppSpacing.h16,
          // Phone Support
          _buildContactButton(
            isDark: isDark,
            label: 'اتصال هاتفي مباشر ($_supportPhone)',
            icon: Icons.phone_in_talk_rounded,
            color: AppColors.primary500,
            onTap: () => _launchOrCopy(
              context,
              urlString: 'tel:$_fullPhone',
              fallbackCopyText: _supportPhone,
              fallbackMessage: 'تم نسخ رقم الهاتف للحافظة: $_supportPhone',
            ),
          ),
          AppSpacing.h10,
          // WhatsApp Support
          _buildContactButton(
            isDark: isDark,
            label: 'محادثة واتساب سريعة',
            icon: Icons.chat_rounded,
            color: const Color(0xFF25D366),
            onTap: () => _launchOrCopy(
              context,
              urlString: 'https://wa.me/967$_supportPhone',
              fallbackCopyText: _supportPhone,
              fallbackMessage: 'تم نسخ رقم الواتساب للحافظة: $_supportPhone',
            ),
          ),
          AppSpacing.h10,
          // Email Support
          _buildContactButton(
            isDark: isDark,
            label: 'مراسلة عبر البريد الإلكتروني',
            icon: Icons.email_outlined,
            color: const Color(0xFF3B82F6),
            onTap: () => _launchOrCopy(
              context,
              urlString: 'mailto:$_supportEmail',
              fallbackCopyText: _supportEmail,
              fallbackMessage: 'تم نسخ البريد الإلكتروني للحافظة: $_supportEmail',
            ),
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => isPrivacy
                            ? const PrivacyPolicyPage()
                            : const TermsOfServicePage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'قراءة الوثيقة الكاملة',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.capt_agree,
                    style: const TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
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
