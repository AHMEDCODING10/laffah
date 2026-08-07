import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:go_router/go_router.dart';
=======
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart';
>>>>>>> origin/admin-ahmed
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/laffah_app_bar.dart';
<<<<<<< HEAD
import '../../data/datasources/fake_profile_repository.dart';
=======
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
>>>>>>> origin/admin-ahmed
import '../widgets/logout_confirmation_dialog.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/profile_user_header.dart';

<<<<<<< HEAD
/// UserProfilePage — Refactored Profile Page for Laffah Passengers.
/// Clean Architecture & Modular Widget Composition.
class UserProfilePage extends StatefulWidget {
=======
/// UserProfilePage — Passenger Profile Page connected to real backend via ProfileBloc
class UserProfilePage extends StatelessWidget {
>>>>>>> origin/admin-ahmed
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(GetProfileEvent()),
      child: const _ProfileView(),
    );
  }
}

<<<<<<< HEAD
class _UserProfilePageState extends State<UserProfilePage> {
  late final Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    _userData = FakeProfileRepository.getUserProfile();
  }

  void _showLogoutDialog(bool isDark) {
=======
class _ProfileView extends StatelessWidget {
  const _ProfileView();

  void _showLogoutDialog(BuildContext context, bool isDark) {
>>>>>>> origin/admin-ahmed
    LogoutConfirmationDialog.show(context, isDark, () {
      context.go(LaffahRoutes.authLanding);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
<<<<<<< HEAD
        appBar: const LaffahAppBar(title: 'الملف الشخصي', showMenuButton: false),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s16,
            AppSpacing.s20,
            100,
          ),
          children: [
            // User Header Card
            ProfileUserHeader(
              isDark: isDark,
              userName: _userData['name'],
              userPhone: _userData['phone'],
              rating: _userData['rating'],
              membershipTier: _userData['membershipTier'],
              onEditPressed: () =>
                  context.push(LaffahRoutes.passengerProfileEdit),
            ),

            AppSpacing.h24,

            // Section 1: Personal Info
            ProfileSectionCard(
              isDark: isDark,
              sectionTitle: 'المعلومات الشخصية',
              tiles: [
                ProfileListTile(
                  icon: Icons.person_outline_rounded,
                  label: 'الملف الشخصي',
                  isDark: isDark,
                  onTap: () => context.push(LaffahRoutes.passengerProfile),
                ),
                ProfileListTile(
                  icon: Icons.edit_outlined,
                  label: 'تعديل البيانات',
                  isDark: isDark,
                  onTap: () => context.push(LaffahRoutes.passengerProfileEdit),
                ),
                ProfileListTile(
                  icon: Icons.place_outlined,
                  label: 'الأماكن المحفوظة',
                  isDark: isDark,
                  onTap: () => context.push(LaffahRoutes.passengerSavedPlaces),
                ),
              ],
            ),

            AppSpacing.h20,

            // Section 2: Security & Preferences
            ProfileSectionCard(
              isDark: isDark,
              sectionTitle: 'الأمان والتفضيلات',
              tiles: [
                ProfileListTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'تغيير كلمة المرور',
                  isDark: isDark,
                  onTap: () => context.push(LaffahRoutes.changePassword),
                ),
                ProfileListTile(
                  icon: Icons.language_rounded,
                  label: 'اللغة',
                  isDark: isDark,
                  trailing: Text(
                    'العربية',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      color: isDark ? AppColors.gray400 : AppColors.gray500,
                    ),
                  ),
                  onTap: () {},
                ),
                ProfileListTile(
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  label: 'الوضع الليلي',
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
              sectionTitle: 'الدعم والقانون',
              tiles: [
                ProfileListTile(
                  icon: Icons.headset_mic_outlined,
                  label: 'الدعم الفني والخدمات',
                  isDark: isDark,
                  onTap: () => context.push(LaffahRoutes.passengerSupportTickets),
                ),
                ProfileListTile(
                  icon: Icons.help_outline_rounded,
                  label: 'الأسئلة الشائعة',
                  isDark: isDark,
                  onTap: () => context.push(LaffahRoutes.faq),
                ),
                ProfileListTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'سياسة الخصوصية',
                  isDark: isDark,
                  onTap: () => context.push(LaffahRoutes.privacyPolicy),
=======
        extendBody: true,
        appBar: const LaffahAppBar(title: 'الملف الشخصي', showMenuButton: false),
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
                      label: const Text('إعادة المحاولة',
                          style:
                              TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500),
                    ),
                  ],
>>>>>>> origin/admin-ahmed
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
                // User Header Card
                ProfileUserHeader(
                  isDark: isDark,
                  userName: profile?.name ?? 'المستخدم',
                  userPhone: profile?.phone ?? '',
                  rating: 5.0, // Backend might not have this yet
                  membershipTier: 'عضو لَفَّة',
                  onEditPressed: () =>
                      context.push(LaffahRoutes.passengerProfileEdit, extra: profile),
                ),

                AppSpacing.h24,

                // Section 1: Personal Info
                ProfileSectionCard(
                  isDark: isDark,
                  sectionTitle: 'المعلومات الشخصية',
                  tiles: [
                    ProfileListTile(
                      icon: Icons.edit_outlined,
                      label: 'تعديل البيانات',
                      isDark: isDark,
                      onTap: () =>
                          context.push(LaffahRoutes.passengerProfileEdit, extra: profile),
                    ),
                    ProfileListTile(
                      icon: Icons.place_outlined,
                      label: 'الأماكن المحفوظة',
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
                  sectionTitle: 'الأمان والتفضيلات',
                  tiles: [
                    ProfileListTile(
                      icon: Icons.lock_outline_rounded,
                      label: 'تغيير كلمة المرور',
                      isDark: isDark,
                      onTap: () => context.push(LaffahRoutes.forgotPassword),
                    ),
                    ProfileListTile(
                      icon: Icons.language_rounded,
                      label: 'اللغة',
                      isDark: isDark,
                      trailing: Text(
                        'العربية',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                          color: isDark ? AppColors.gray400 : AppColors.gray500,
                        ),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('اللغة العربية هي اللغة المدعومة حالياً', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                            backgroundColor: AppColors.primary500,
                          ),
                        );
                      },
                    ),
                    ProfileListTile(
                      icon: isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      label: 'الوضع الليلي',
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
                  sectionTitle: 'الدعم والقانون',
                  tiles: [
                    ProfileListTile(
                      icon: Icons.headset_mic_outlined,
                      label: 'الدعم الفني والخدمات',
                      isDark: isDark,
                      onTap: () async {
                        final Uri url = Uri.parse(
                            'whatsapp://send?phone=+967770291452');
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
                      label: 'الأسئلة الشائعة',
                      isDark: isDark,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('الأسئلة الشائعة قريباً!', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                            backgroundColor: AppColors.primary500,
                          ),
                        );
                      },
                    ),
                    ProfileListTile(
                      icon: Icons.privacy_tip_outlined,
                      label: 'سياسة الخصوصية',
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
                    label: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(
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
              ],
<<<<<<< HEAD
            ),

            AppSpacing.h24,

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(isDark),
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.danger,
                  size: 20,
                ),
                label: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
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
          ],
=======
            );
          },
>>>>>>> origin/admin-ahmed
        ),
      ),
    );
  }
}
