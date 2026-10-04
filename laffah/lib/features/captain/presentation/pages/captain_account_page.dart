import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/router/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import 'widgets/captain_account_dialogs.dart';
import '../../../../core/bloc/locale/locale_bloc.dart';
import '../../../../core/bloc/locale/locale_event.dart';
import '../../../../core/widgets/laffah_glass_snackbar.dart';
import '../../../profile/presentation/pages/legal/terms_of_service_page.dart';
import '../../../profile/presentation/pages/legal/privacy_policy_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/core/captain_bloc.dart';
import '../bloc/core/captain_event.dart';
import '../../../ride/presentation/bloc/ride_bloc.dart';

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
  dynamic _cachedProfile;
  bool _isProfileUpdating = false;

  @override
  void initState() {
    super.initState();
    // Use the global ProfileBloc instance and fetch profile on load
    _profileBloc = context.read<ProfileBloc>()..add(GetProfileEvent());
  }

  @override
  void dispose() {
    // Do NOT close _profileBloc because it's a global LazySingleton!
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
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        bloc: _profileBloc,
        listener: (context, state) {
          if (_isProfileUpdating && state is ProfileLoaded) {
            _isProfileUpdating = false;
            LaffahSnackBar.success(
              context,
              AppLocalizations.of(context)!.capt_acc_profile_updated,
            );
          } else if (_isProfileUpdating && state is ProfileError) {
            _isProfileUpdating = false;
            LaffahSnackBar.error(context, state.message);
          }
        },
        child: Directionality(
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
                    if (state is ProfileLoaded) {
                      _cachedProfile = state.profile;
                    }

                    final dynamic profile = _cachedProfile ??
                        (state is ProfileLoaded ? state.profile : null);

                    String name = profile?.name ?? '';
                    if (name.isEmpty) {
                      name = state is ProfileLoading
                          ? AppLocalizations.of(context)!.capt_acc_loading
                          : 'الكابتن';
                    }

                    String rating =
                        profile?.rating?.toStringAsFixed(1) ?? '5.0';
                    String vehicleType = profile?.vehicleType ??
                        AppLocalizations.of(context)!.capt_acc_vehicle;
                    String vehiclePlate = profile?.plateNumber ??
                        AppLocalizations.of(context)!.capt_acc_unspecified;
                    bool isVerified = profile?.isVerified ?? false;

                    // Fast, lightweight, local offline avatar - no external web network requests
                    final avatarChild = _buildFallbackAvatar(name);

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
                            backgroundColor: AppColors.primary500,
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
                                        ).then((_) {
                                          if (mounted) {
                                            _profileBloc.add(GetProfileEvent());
                                          }
                                        });
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
                  final dynamic profile = _cachedProfile ??
                      (_profileBloc.state is ProfileLoaded
                          ? (_profileBloc.state as ProfileLoaded).profile
                          : null);
                  String currentName = profile?.name ?? '';
                  String currentPhone = profile?.phone ?? '';
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => EditProfileSheet(
                      currentName: currentName,
                      currentPhone: currentPhone,
                      onSave: (newName, newPhone) {
                        setState(() {
                          _isProfileUpdating = true;
                        });
                        _profileBloc.add(UpdateProfileEvent(
                          name: newName,
                          phone: newPhone,
                        ));
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
                  final dynamic profile = _cachedProfile ??
                      (_profileBloc.state is ProfileLoaded
                          ? (_profileBloc.state as ProfileLoaded).profile
                          : null);
                  final Map<String, String> currentVehicleInfo = {
                    'type': profile?.vehicleType ?? 'غير محدد',
                    'model': profile?.vehicleModel ?? 'غير محدد',
                    'plate': profile?.plateNumber ?? 'غير محدد',
                    'color': profile?.vehicleColor ?? 'غير محدد',
                  };
                  final bool isVerified = profile?.isVerified ?? false;

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => VehicleDetailsSheet(
                      vehicleInfo: currentVehicleInfo,
                      isVerified: isVerified,
                      onSave: (type, model, plate, color) {
                        _profileBloc.add(UpdateProfileEvent(
                          name: profile?.name ?? 'الكابتن',
                          phone: profile?.phone,
                          email: profile?.email,
                          vehicleType: type,
                          vehicleModel: model,
                          plateNumber: plate,
                          vehicleColor: color,
                        ));
                      },
                    ),
                  ).then((_) {
                    if (mounted) {
                      _profileBloc.add(GetProfileEvent());
                    }
                  });
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
                  ).then((_) {
                    if (mounted) {
                      _profileBloc.add(GetProfileEvent());
                    }
                  });
                },
              ),
              _buildSettingItem(
                icon: Icons.lock_outline_rounded,
                title: AppLocalizations.of(context)!.capt_acc_change_pass,
                subtitle: AppLocalizations.of(context)!.capt_acc_change_pass_desc,
                onTap: () {
                  final phone = _cachedProfile?.phone ?? '';
                  context.push(LaffahRoutes.forgotPassword, extra: {
                    'phone': phone,
                    'isChangingPassword': true,
                  });
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
                          backgroundColor: AppColors.primary500,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsOfServicePage(),
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.security_rounded,
                title: AppLocalizations.of(context)!.capt_acc_privacy,
                subtitle: AppLocalizations.of(context)!.capt_acc_privacy_desc,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyPage(),
                    ),
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

              AppSpacing.h12,

              // 7. DELETE ACCOUNT BUTTON
              TextButton.icon(
                onPressed: () => _showDeleteAccountDialog(context, isDark),
                icon: const Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.error,
                  size: 18,
                ),
                label: const Text(
                  'حذف حساب الكابتن نهائياً',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12.5,
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
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
                        color: AppColors.primary500.withValues(alpha: 0.08),
                        shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.capt_acc_laffah,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary500,
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
                  color: AppColors.primary500.withValues(alpha: 0.08),
                  shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary500, size: 20),
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
          activeTrackColor: AppColors.primary500,
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
                color: AppColors.primary500.withValues(alpha: 0.08),
                shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary500, size: 20),
          ),
        ),
        ),
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B26) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.gray200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Title
                  Text(
                    AppLocalizations.of(context)!.capt_logout,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 18,
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    AppLocalizations.of(context)!.capt_logout_confirm_msg,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 13,
                      height: 1.6,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1. Confirm Logout Button (Primary, Red, Full Width)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.read<AuthBloc>().add(const LogoutRequested());
                        try {
                          context.read<CaptainBloc>().add(const ResetCaptainState(keepOnline: false));
                        } catch (_) {}
                        try {
                          context.read<RideBloc>().add(const ResetRideState());
                        } catch (_) {}
                        context.go(LaffahRoutes.authLanding);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.capt_confirm_logout,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Cancel Button (UNDER Confirm Logout, as requested)
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.capt_cancel,
                        style: TextStyle(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, bool isDark) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B26) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.gray200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: AppColors.error,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'حذف حساب الكابتن نهائياً',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'هل أنت متأكد من رغبتك في حذف حساب الكابتن نهائياً؟ ستفقد جميع سجلات الرحلات، تقييماتك، ورصيد محفظتك ولا يمكن التراجع عن هذا الإجراء.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 13,
                      height: 1.6,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 1. Delete Button (Red, Full Width)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.read<AuthBloc>().add(const DeleteAccountRequested());
                        try {
                          context.read<CaptainBloc>().add(const ResetCaptainState(keepOnline: false));
                        } catch (_) {}
                        try {
                          context.read<RideBloc>().add(const ResetRideState());
                        } catch (_) {}
                        context.go(LaffahRoutes.authLanding);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'نعم، احذف الحساب نهائياً',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 2. Cancel Button (Underneath)
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'إلغاء والتراجع',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
