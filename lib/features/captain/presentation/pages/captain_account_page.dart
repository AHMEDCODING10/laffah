import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/di/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import 'widgets/captain_account_dialogs.dart';
import '../../../../core/bloc/locale/locale_bloc.dart';
import '../../../../core/bloc/locale/locale_event.dart';

/// CaptainAccountPage - Overhauled interactive profile dashboard for Laffah Captains.
/// Integrates all 9 modal sheets (Profile, Vehicle, Documents, Password, Help, FAQ, Support, terms, language),
/// top notification center overlay, theme toggler, and safe logout sequence.
class CaptainAccountPage extends StatefulWidget {
  const CaptainAccountPage({super.key});

  @override
  State<CaptainAccountPage> createState() => _CaptainAccountPageState();
}

class _CaptainAccountPageState extends State<CaptainAccountPage> {
  late ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = sl<ProfileBloc>()..add(GetProfileEvent());
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  // Fallback Avatar Widget extracting the first letter
  Widget _buildFallbackAvatar(String name) {
    String firstLetter = 'ك'; // default fallback 'كابتن'
    if (name.isNotEmpty && name != 'جاري التحميل...') {
      firstLetter = name.trim().characters.first.toUpperCase();
    }
    return Text(
      firstLetter,
      style: const TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  String _selectedLang = 'ar'; // Default language Arabic

  // Fallback vehicle info if not available
  final Map<String, String> _defaultVehicleInfo = {
    'type': 'غير محدد',
    'model': 'غير محدد',
    'plate': 'غير محدد',
    'license': 'رخصة قيادة دراجات نارية سارية',
  };

  void _showNotificationCenterSheet(BuildContext context, bool isDark) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            color: isDark ? const Color(0xFF141822) : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(10))),
              ),
              AppSpacing.h16,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.capt_acc_notif_center,
                      style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              AppSpacing.h16,
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildNotifItem(
                        AppLocalizations.of(context)!.capt_notif_1_title,
                        AppLocalizations.of(context)!.capt_notif_1_desc,
                        AppLocalizations.of(context)!.capt_notif_yesterday,
                        isDark),
                    _buildNotifItem(
                        AppLocalizations.of(context)!.capt_notif_2_title,
                        AppLocalizations.of(context)!.capt_notif_2_desc,
                        AppLocalizations.of(context)!.capt_notif_yesterday,
                        isDark),
                    _buildNotifItem(
                        AppLocalizations.of(context)!.capt_notif_3_title,
                        AppLocalizations.of(context)!.capt_notif_3_desc,
                        AppLocalizations.of(context)!.capt_notif_2_days_ago,
                        isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifItem(String title, String desc, String time, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              Text(time,
                  style: const TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 10,
                      color: AppColors.gray500)),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc,
              style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11.5,
                  color: AppColors.gray600,
                  height: 1.4)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.capt_acc_title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'IBM Plex Sans Arabic',
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        actions: [
          BlocListener<ProfileBloc, ProfileState>(
            bloc: _profileBloc,
            listener: (context, state) {
              if (state is ProfileLoaded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.success,
                    content: Text(AppLocalizations.of(context)!.capt_acc_profile_updated,
                        style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.bold)),
                  ),
                );
              }
            },
            child: IconButton(
              icon: Icon(
                Icons.notifications_none_rounded,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
              onPressed: () => _showNotificationCenterSheet(context, isDark),
            ),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              16, 8, 16, 90), // Bottom padding for floating bar
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 1. Profile Visual Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141822).withValues(alpha: 0.9)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                        blurRadius: 10),
                  ],
                ),
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  bloc: _profileBloc,
                  builder: (context, state) {
                    String name = AppLocalizations.of(context)!.capt_acc_loading;
                    String rating = '0.0';
                    String? avatarUrl;
                    String vehicleType = AppLocalizations.of(context)!.capt_acc_vehicle;
                    String vehiclePlate = AppLocalizations.of(context)!.capt_acc_unspecified;

                    bool isVerified = false;

                    if (state is ProfileLoaded) {
                      name = state.profile.name;
                      rating =
                          state.profile.rating?.toStringAsFixed(1) ?? '5.0';
                      avatarUrl = state.profile.avatarUrl;
                      vehicleType = state.profile.vehicleType ?? AppLocalizations.of(context)!.capt_acc_vehicle;
                      vehiclePlate = state.profile.plateNumber ?? AppLocalizations.of(context)!.capt_acc_unspecified;
                      isVerified = state.profile.isVerified;
                    } else if (state is ProfileError) {
                      name = AppLocalizations.of(context)!.capt_acc_default_name;
                    }

                    Widget avatarChild;
                    if (avatarUrl != null && avatarUrl.isNotEmpty) {
                      avatarChild = ClipOval(
                        child: Image.network(
                          avatarUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackAvatar(name),
                        ),
                      );
                    } else {
                      avatarChild = _buildFallbackAvatar(name);
                    }

                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: const Color(0xFFFF6B00),
                            child: avatarChild,
                          ),
                        ),
                        AppSpacing.w16,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  color:
                                      isDark ? Colors.white : AppColors.gray900,
                                ),
                              ),
                              AppSpacing.h4,
                              Row(
                                children: [
                                  if (isVerified)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.success
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.verified_rounded,
                                              color: AppColors.success,
                                              size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            AppLocalizations.of(context)!.capt_acc_verified,
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              color: AppColors.success,
                                              fontWeight: FontWeight.w900,
                                              fontFamily:
                                                  'IBM Plex Sans Arabic',
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) =>
                                              const OfficialDocumentsSheet(),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.error
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: AppColors.error
                                                  .withValues(alpha: 0.5)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.warning_rounded,
                                                color: AppColors.error,
                                                size: 12),
                                            const SizedBox(width: 4),
                                            Text(
                                              AppLocalizations.of(context)!.capt_acc_unverified,
                                              style: const TextStyle(
                                                fontSize: 9.5,
                                                color: AppColors.error,
                                                fontWeight: FontWeight.w900,
                                                fontFamily:
                                                    'IBM Plex Sans Arabic',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  AppSpacing.w8,
                                  const Icon(Icons.star_rounded,
                                      color: Colors.amber, size: 16),
                                  AppSpacing.w2,
                                  Text(
                                    rating,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.gray300
                                          : AppColors.gray700,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.h8,
                              Text(
                                '$vehicleType • ${AppLocalizations.of(context)!.capt_plate_num}: $vehiclePlate',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.gray500,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_note_rounded,
                              color: Color(0xFFFF6B00), size: 28),
                          onPressed: () {
                            HapticFeedback.lightImpact();

                            String currentName = '';
                            String currentPhone = '';
                            if (_profileBloc.state is ProfileLoaded) {
                              final profile =
                                  (_profileBloc.state as ProfileLoaded).profile;
                              currentName = profile.name;
                              currentPhone = profile.phone;
                            }

                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => EditProfileSheet(
                                currentName: currentName,
                                currentPhone: currentPhone,
                                onSave: (newName, newPhone) {
                                  _profileBloc
                                      .add(UpdateProfileEvent(name: newName));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.success,
                                      content: Text(
                                          AppLocalizations.of(context)!.capt_acc_updating_profile,
                                          style: const TextStyle(
                                              fontFamily:
                                                  'IBM Plex Sans Arabic',
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),

              AppSpacing.h20,

              // 2. GENERAL SETTINGS
              _buildSectionTitle(AppLocalizations.of(context)!.capt_acc_general_settings),
              AppSpacing.h8,
              _buildSettingItem(
                icon: Icons.person_outline_rounded,
                title: AppLocalizations.of(context)!.capt_acc_profile,
                subtitle: AppLocalizations.of(context)!.capt_acc_profile_desc,
                onTap: () {
                  String currentName = '';
                  String currentPhone = '';
                  if (_profileBloc.state is ProfileLoaded) {
                    final profile =
                        (_profileBloc.state as ProfileLoaded).profile;
                    currentName = profile.name;
                    currentPhone = profile.phone;
                  }
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => EditProfileSheet(
                      currentName: currentName,
                      currentPhone: currentPhone,
                      onSave: (newName, newPhone) {
                        _profileBloc.add(UpdateProfileEvent(name: newName));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.success,
                            content: Text('جاري تحديث الملف الشخصي... ⏳',
                                style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.motorcycle_rounded,
                title: AppLocalizations.of(context)!.capt_acc_bike_data,
                subtitle: AppLocalizations.of(context)!.capt_acc_bike_desc,
                onTap: () {
                  Map<String, String> currentVehicleInfo =
                      Map.from(_defaultVehicleInfo);
                  if (_profileBloc.state is ProfileLoaded) {
                    final profile =
                        (_profileBloc.state as ProfileLoaded).profile;
                    currentVehicleInfo['type'] =
                        profile.vehicleType ?? 'غير محدد';
                    currentVehicleInfo['model'] =
                        profile.vehicleModel ?? 'غير محدد';
                    currentVehicleInfo['plate'] =
                        profile.plateNumber ?? 'غير محدد';
                  }

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        VehicleDetailsSheet(vehicleInfo: currentVehicleInfo),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.description_outlined,
                title: AppLocalizations.of(context)!.capt_acc_docs,
                subtitle: AppLocalizations.of(context)!.capt_acc_docs_desc,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const OfficialDocumentsSheet(),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.lock_outline_rounded,
                title: AppLocalizations.of(context)!.capt_acc_change_pass,
                subtitle: AppLocalizations.of(context)!.capt_acc_change_pass_desc,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const ChangePasswordSheet(),
                  );
                },
              ),

              AppSpacing.h16,

              // 3. THEME & LANGUAGE PREFERENCES
              _buildSectionTitle(AppLocalizations.of(context)!.capt_acc_prefs),
              AppSpacing.h8,
              _buildSwitchSettingItem(
                icon: Icons.dark_mode_rounded,
                title: AppLocalizations.of(context)!.capt_acc_dark_mode,
                subtitle: AppLocalizations.of(context)!.capt_acc_dark_mode_desc,
                value: ThemeController.instance.isDarkMode,
                onChanged: (val) {
                  ThemeController.instance.toggleTheme(val);
                  setState(() {});
                },
                isDark: isDark,
              ),
              _buildSettingItem(
                icon: Icons.translate_rounded,
                title: AppLocalizations.of(context)!.capt_acc_change_lang,
                subtitle: _selectedLang == 'ar'
                    ? AppLocalizations.of(context)!.capt_arabic_ye
                    : 'English (🇬🇧 English)',
                onTap: () {
                  LanguageSelectorSheet.show(
                    context: context,
                    currentLang: _selectedLang,
                    onSelected: (code) {
                      setState(() {
                        _selectedLang = code;
                      });
                      context.read<LocaleBloc>().add(ChangeLocale(Locale(code)));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFFFF6B00),
                          content: Text(
                            code == 'ar'
                                ? 'تم تغيير لغة التطبيق إلى العربية بنجاح'
                                : 'App language changed to English successfully!',
                            style: const TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              AppSpacing.h16,

              // 4. HELP & SUPPORT
              _buildSectionTitle(AppLocalizations.of(context)!.capt_acc_support),
              AppSpacing.h8,
              _buildSettingItem(
                icon: Icons.support_agent_rounded,
                title: AppLocalizations.of(context)!.capt_acc_help_center,
                subtitle: AppLocalizations.of(context)!.capt_acc_help_center_desc,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const HelpCenterSheet(),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.help_outline_rounded,
                title: AppLocalizations.of(context)!.capt_acc_faq,
                subtitle: AppLocalizations.of(context)!.capt_acc_faq_desc,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const FAQSheet(),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.contact_support_outlined,
                title: AppLocalizations.of(context)!.capt_acc_contact,
                subtitle: AppLocalizations.of(context)!.capt_acc_contact_desc,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const DirectSupportSheet(),
                  );
                },
              ),

              AppSpacing.h16,

              // 5. LEGAL
              _buildSectionTitle(AppLocalizations.of(context)!.capt_acc_legal),
              AppSpacing.h8,
              _buildSettingItem(
                icon: Icons.gavel_rounded,
                title: AppLocalizations.of(context)!.capt_acc_terms,
                subtitle: AppLocalizations.of(context)!.capt_acc_terms_desc,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        const TermsAndPrivacySheet(isPrivacy: false),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.security_rounded,
                title: AppLocalizations.of(context)!.capt_acc_privacy,
                subtitle: AppLocalizations.of(context)!.capt_acc_privacy_desc,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        const TermsAndPrivacySheet(isPrivacy: true),
                  );
                },
              ),

              AppSpacing.h24,

              // 6. LOG OUT BUTTON
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.12)),
                  ),
                  child: ListTile(
                    onTap: () => _showLogoutConfirmDialog(context),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    leading: Container(
                      padding: const EdgeInsets.all(AppSpacing.s8),
                      decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.logout_rounded,
                          color: AppColors.error, size: 20),
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.capt_acc_logout,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                          fontFamily: 'IBM Plex Sans Arabic'),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.capt_acc_logout_desc,
                      style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.gray500,
                          fontFamily: 'IBM Plex Sans Arabic'),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.error),
                  ),
                ),
              ),

              AppSpacing.h24,

              // Footer Details
              Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: const Color(0xFFFF6B00).withValues(alpha: 0.08),
                        shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.capt_acc_laffah,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF6B00),
                            fontFamily: 'IBM Plex Sans Arabic'),
                      ),
                    ),
                  ),
                  AppSpacing.h8,
                  Text(
                    AppLocalizations.of(context)!.capt_acc_app_name,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: isDark ? AppColors.gray300 : AppColors.gray800),
                  ),
                  Text(
                    AppLocalizations.of(context)!.capt_acc_version,
                    style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray500),
                  ),
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
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: AppColors.gray500,
            fontFamily: 'IBM Plex Sans Arabic'),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF141822).withValues(alpha: 0.9)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFFFF6B00).withValues(alpha: 0.08),
                  shape: BoxShape.circle),
              child: Icon(icon, color: const Color(0xFFFF6B00), size: 20),
            ),
            title: Text(
              title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBM Plex Sans Arabic'),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.gray500,
                  fontFamily: 'IBM Plex Sans Arabic'),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s10),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF141822).withValues(alpha: 0.9)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: SwitchListTile.adaptive(
            value: value,
          onChanged: (val) {
            HapticFeedback.selectionClick();
            onChanged(val);
          },
          activeTrackColor: const Color(0xFFFF6B00),
          title: Text(
            title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBM Plex Sans Arabic'),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.gray500,
                fontFamily: 'IBM Plex Sans Arabic'),
          ),
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFFFF6B00).withValues(alpha: 0.08),
                shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFFFF6B00), size: 20),
          ),
        ),
        ),
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
                ? const Color(0xFF141822)
                : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              AppLocalizations.of(context)!.capt_logout,
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 16),
            ),
            content: Text(
              AppLocalizations.of(context)!.capt_logout_confirm_msg,
              style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 13,
                  height: 1.5),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppLocalizations.of(context)!.capt_cancel,
                    style: const TextStyle(
                        color: AppColors.gray600,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.go(LaffahRoutes.authLanding);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text(AppLocalizations.of(context)!.capt_confirm_logout,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic')),
              ),
            ],
          ),
        );
      },
    );
  }
}
