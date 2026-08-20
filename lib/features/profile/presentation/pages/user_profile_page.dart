import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/laffah_app_bar.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/logout_confirmation_dialog.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/profile_user_header.dart';
import '../../../../core/bloc/locale/locale_bloc.dart';
import '../../../../core/bloc/locale/locale_event.dart';
import '../../../../core/bloc/locale/locale_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

/// UserProfilePage — Passenger Profile Page connected to real backend via ProfileBloc
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(GetProfileEvent()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  void _showLogoutDialog(BuildContext context, bool isDark) {
    LogoutConfirmationDialog.show(context, isDark, () {
      context.go(LaffahRoutes.authLanding);
    });
  }

  void _showDeleteAccountDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF141822) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderMD),
          title: Text(
            'حذف الحساب نهائياً',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف الحساب نهائياً؟ ستفقد جميع بياناتك ورصيدك ولا يمكن التراجع عن هذا الإجراء.',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء',
                  style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: AppColors.primary500,
                      fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(const DeleteAccountRequested());
                context.go(LaffahRoutes.authLanding);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSM),
              ),
              child: const Text('نعم، احذف الحساب',
                  style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic', color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        extendBody: true,
        appBar: LaffahAppBar(
          title: AppLocalizations.of(context)!.pass_profile_title,
          showMenuButton: false,
          showBackButton: false,
        ),
        bottomNavigationBar: HomeBottomNavBar(isDark: isDark, currentIndex: 3),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // Show skeleton/loading while fetching
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary500),
              );
            }

            // Show error with retry
            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_off_rounded,
                        size: 48, color: AppColors.gray400),
                    AppSpacing.h12,
                    Text(
                      state.message,
                      style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: AppColors.gray600),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.h16,
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<ProfileBloc>().add(GetProfileEvent()),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(AppLocalizations.of(context)!.pass_retry,
                          style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500),
                    ),
                  ],
                ),
              );
            }

            // Extract profile from state
            ProfileEntity? profile;
            if (state is ProfileLoaded) profile = state.profile;

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s16,
                AppSpacing.s20,
                100,
              ),
              children: [
                ProfileUserHeader(
                  isDark: isDark,
                  userName: profile?.name ?? AppLocalizations.of(context)!.pass_profile_user,
                  userPhone: profile?.phone ?? '',
                  avatarUrl: profile?.avatarUrl,
                  rating: profile?.rating ?? 5.0,
                  membershipTier: AppLocalizations.of(context)!.pass_profile_member,
                  isVerified: profile?.isVerified ?? true,
                  onEditPressed: () => context
                      .push(LaffahRoutes.passengerProfileEdit, extra: profile),
                ),

                AppSpacing.h24,

                // Section 1: Personal Info
                ProfileSectionCard(
                  isDark: isDark,
                  sectionTitle: AppLocalizations.of(context)!.pass_profile_personal_info,
                  tiles: [
                    ProfileListTile(
                      icon: Icons.edit_outlined,
                      label: AppLocalizations.of(context)!.pass_profile_edit_data,
                      isDark: isDark,
                      onTap: () => context.push(
                          LaffahRoutes.passengerProfileEdit,
                          extra: profile),
                    ),
                    ProfileListTile(
                      icon: Icons.place_outlined,
                      label: AppLocalizations.of(context)!.pass_profile_saved_places,
                      isDark: isDark,
                      onTap: () =>
                          context.push(LaffahRoutes.passengerSavedPlaces),
                    ),
                  ],
                ),

                AppSpacing.h20,

                // Section 2: Security & Preferences
                ProfileSectionCard(
                  isDark: isDark,
                  sectionTitle: AppLocalizations.of(context)!.pass_profile_security_prefs,
                  tiles: [
                    ProfileListTile(
                      icon: Icons.lock_outline_rounded,
                      label: AppLocalizations.of(context)!.pass_profile_change_pass,
                      isDark: isDark,
                      onTap: () => context.push(LaffahRoutes.forgotPassword),
                    ),
                    ProfileListTile(
                      icon: Icons.language_rounded,
                      label: AppLocalizations.of(context)!.pass_profile_language,
                      isDark: isDark,
                      trailing: BlocBuilder<LocaleBloc, LocaleState>(
                        builder: (context, localeState) {
                          return Text(
                            localeState.locale.languageCode == 'ar'
                                ? AppLocalizations.of(context)!.pass_profile_arabic
                                : AppLocalizations.of(context)!.pass_profile_english,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.gray400
                                  : AppColors.gray500,
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        final localeState = context.read<LocaleBloc>().state;
                        showModalBottomSheet(
                          context: context,
                          backgroundColor:
                              isDark ? const Color(0xFF141822) : Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (BuildContext bottomSheetContext) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      AppLocalizations.of(context)!.pass_profile_choose_lang,
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(AppLocalizations.of(context)!.pass_profile_arabic,
                                        style: TextStyle(
                                            fontFamily: 'IBM Plex Sans Arabic',
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black)),
                                    trailing:
                                        localeState.locale.languageCode == 'ar'
                                            ? const Icon(Icons.check,
                                                color: AppColors.primary500)
                                            : null,
                                    onTap: () {
                                      context.read<LocaleBloc>().add(
                                          const ChangeLocale(Locale('ar')));
                                      Navigator.pop(bottomSheetContext);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: AppColors.primary500,
                                          content: Text(
                                            AppLocalizations.of(context)!.pass_profile_lang_ar_success,
                                            style: const TextStyle(
                                                fontFamily: 'IBM Plex Sans Arabic',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    title: Text(AppLocalizations.of(context)!.pass_profile_english,
                                        style: TextStyle(
                                            fontFamily: 'IBM Plex Sans Arabic',
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black)),
                                    trailing:
                                        localeState.locale.languageCode == 'en'
                                            ? const Icon(Icons.check,
                                                color: AppColors.primary500)
                                            : null,
                                    onTap: () {
                                      context.read<LocaleBloc>().add(
                                          const ChangeLocale(Locale('en')));
                                      Navigator.pop(bottomSheetContext);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: AppColors.primary500,
                                          content: Text(
                                            AppLocalizations.of(context)!.pass_profile_lang_en_success,
                                            style: const TextStyle(
                                                fontFamily: 'IBM Plex Sans Arabic',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    ProfileListTile(
                      icon: isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      label: AppLocalizations.of(context)!.pass_profile_dark_mode,
                      isDark: isDark,
                      trailing: Switch(
                        value: isDark,
                        activeThumbColor: AppColors.primary500,
                        onChanged: (val) {
                          ThemeController.instance.toggleTheme(val);
                        },
                      ),
                      onTap: () {
                        ThemeController.instance.toggleTheme(!isDark);
                      },
                    ),
                  ],
                ),

                AppSpacing.h20,

                // Section 3: Support & Legal
                ProfileSectionCard(
                  isDark: isDark,
                  sectionTitle: AppLocalizations.of(context)!.pass_profile_support_legal,
                  tiles: [
                    ProfileListTile(
                      icon: Icons.headset_mic_outlined,
                      label: AppLocalizations.of(context)!.pass_profile_tech_support,
                      isDark: isDark,
                      onTap: () async {
                        final Uri url =
                            Uri.parse('whatsapp://send?phone=+967770291452');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          final Uri phoneUrl = Uri.parse('tel:+967770291452');
                          if (await canLaunchUrl(phoneUrl)) {
                            await launchUrl(phoneUrl);
                          }
                        }
                      },
                    ),
                    ProfileListTile(
                      icon: Icons.help_outline_rounded,
                      label: AppLocalizations.of(context)!.pass_profile_faq,
                      isDark: isDark,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.pass_profile_faq_soon,
                                style: const TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic')),
                            backgroundColor: AppColors.primary500,
                          ),
                        );
                      },
                    ),
                    ProfileListTile(
                      icon: Icons.privacy_tip_outlined,
                      label: AppLocalizations.of(context)!.pass_profile_privacy_policy,
                      isDark: isDark,
                      onTap: () => context.push(LaffahRoutes.privacyPolicy),
                    ),
                  ],
                ),

                AppSpacing.h24,

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context, isDark),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.danger,
                      size: 20,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.pass_profile_logout,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.danger,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger.withValues(alpha: 0.12),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.borderMD,
                      ),
                    ),
                  ),
                ),

                AppSpacing.h16,

                // Delete Account Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteAccountDialog(context, isDark),
                    icon: const Icon(
                      Icons.person_remove_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      'حذف الحساب',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.borderMD,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
    );
  }
}
