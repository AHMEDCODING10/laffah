import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../widgets/laffah_main_shell_scaffold.dart';

// Auth module
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/auth_landing_page.dart';
import '../../features/auth/presentation/pages/phone_number_input_page.dart';
import '../../features/auth/presentation/pages/register_passenger_page.dart';
import '../../features/auth/presentation/pages/register_captain_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';

import '../pages/coming_soon_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';

// Passenger home
import '../../features/home/presentation/pages/home_dashboard_page.dart';

// Passenger ride & history
import '../../features/ride/presentation/pages/trip_history_page.dart';
import '../../features/ride/presentation/pages/passenger_schedule_ride_page.dart';
import '../../features/ride/presentation/pages/passenger_ride_tracking_page.dart';
import '../../features/ride/presentation/pages/passenger_ride_invoice_page.dart';

// Captain core features
import '../../features/captain/presentation/pages/captain_trip_history_page.dart';
import '../../features/captain/presentation/pages/captain_performance_page.dart';
import '../../features/captain/presentation/pages/captain_settings_page.dart';
import '../../features/captain/presentation/pages/captain_ride_invoice_page.dart';
import '../../features/captain/presentation/pages/captain_parcel_details_page.dart';
import '../../features/captain/presentation/pages/captain_bonus_page.dart';
import '../../features/captain/presentation/pages/captain_support_page.dart';

// Passenger core features
import '../../features/passenger/presentation/pages/wallet_page.dart';
import '../../features/passenger/presentation/pages/notifications_page.dart';
import '../../features/passenger/presentation/pages/promo_code_page.dart';


// Parcel Delivery features
import '../../features/parcel/presentation/pages/parcel_send_page.dart';
import '../../features/parcel/presentation/pages/parcel_tracking_page.dart';
import '../../features/parcel/presentation/pages/parcel_confirmation_page.dart';
import '../../features/parcel/presentation/pages/parcel_history_page.dart';
import '../../features/parcel/presentation/pages/parcel_delivery_proof_page.dart';

// Captain module
import '../../features/captain/presentation/pages/captain_home_page.dart';
import '../../features/captain/presentation/pages/captain_navigation_page.dart';
import '../../features/captain/presentation/pages/captain_payout_request_page.dart';
import '../../features/captain/presentation/pages/captain_document_upload_page.dart';

// Profile module
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/captain/presentation/bloc/core/captain_bloc.dart';
import '../di/injection_container.dart' as di;
import '../../features/profile/presentation/pages/user_profile_page.dart';
import '../../features/profile/presentation/pages/saved_places_page.dart';
import '../../features/profile/presentation/pages/passenger_profile_edit_page.dart';
import '../../features/profile/presentation/pages/legal/privacy_policy_page.dart';
import '../../features/profile/presentation/pages/legal/terms_of_service_page.dart';
import '../../features/profile/domain/entities/profile_entity.dart';

// ============================================================
// ROUTE PATH CONSTANTS
// ============================================================

/// Centralized route path constants for the Laffah application.
abstract class LaffahRoutes {
  // ──────────────────────────────────────────
  // SPLASH & ONBOARDING
  // ──────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // ──────────────────────────────────────────
  // AUTH FLOW
  // ──────────────────────────────────────────
  static const String authLanding             = '/auth';
  static const String authPhone               = '/auth/phone';
  static const String authRegisterPassenger   = '/auth/register/passenger';
  static const String authRegisterCaptain     = '/auth/register/captain';

  static const String forgotPassword          = '/auth/forgot-password';

  // ──────────────────────────────────────────
  // PASSENGER — CORE
  // ──────────────────────────────────────────
  static const String passengerHome = '/passenger/home';
  static const String passengerHistory = '/passenger/history';
  static const String passengerNotifications = '/passenger/notifications';
  static const String passengerWallet = '/passenger/wallet';
  static const String passengerPromoCode = '/passenger/promo';

  // ──────────────────────────────────────────
  // PASSENGER — RIDE LIFECYCLE
  // ──────────────────────────────────────────
  static const String passengerRideRequest = '/passenger/ride/request';
  static const String passengerRideTracking = '/passenger/ride/tracking';
  static const String passengerRideInvoice = '/passenger/ride/invoice';
  static const String passengerScheduleRide = '/passenger/ride/schedule';

  // ──────────────────────────────────────────
  // PASSENGER — PARCEL DELIVERY
  // ──────────────────────────────────────────
  static const String passengerParcelSend     = '/passenger/parcel/send';
  static const String passengerParcelTracking = '/passenger/parcel/tracking';
  static const String passengerParcelConfirm  = '/passenger/parcel/confirm';
  static const String passengerParcelHistory  = '/passenger/parcel/history';
  static const String parcelDeliveryProof     = '/parcel/proof';

  // ──────────────────────────────────────────
  // PASSENGER — PROFILE & SUPPORT
  // ──────────────────────────────────────────
  static const String passengerProfile = '/passenger/profile';
  static const String passengerProfileEdit = '/passenger/profile/edit';
  static const String passengerSavedPlaces = '/passenger/profile/saved-places';
  static const String passengerSupportTickets = '/passenger/support-tickets';
  static const String roleSelection = '/auth/role';

  // ──────────────────────────────────────────
  // PASSENGER — SUPPORT
  // ──────────────────────────────────────────


  // ──────────────────────────────────────────
  // CAPTAIN — CORE
  // ──────────────────────────────────────────
  static const String captainHome = '/captain/home';
  static const String captainNavigation = '/captain/navigation';
  static const String captainHistory = '/captain/history';
  static const String captainPerformance = '/captain/performance';
  static const String captainBonus = '/captain/bonus';
  static const String captainSettings = '/captain/settings';
  static const String captainRideInvoice = '/captain/ride/invoice';
  static const String captainParcelDetails = '/captain/parcel/details';

  // ──────────────────────────────────────────
  // CAPTAIN — FINANCE & ACCOUNT
  // ──────────────────────────────────────────
  static const String captainPayout = '/captain/payout';
  static const String captainDocuments = '/captain/documents';
  static const String captainSupport = '/captain/support';

  // ──────────────────────────────────────────
  // PASSENGER — SUPPORT & LEGAL
  // ──────────────────────────────────────────
  static const String helpCenter = '/passenger/support/help';
  static const String faq = '/passenger/support/faq';
  static const String contactUs = '/passenger/support/contact';
  static const String changePassword = '/passenger/profile/change-password';

  // ──────────────────────────────────────────
  // LEGAL
  // ──────────────────────────────────────────
  static const String privacyPolicy = '/legal/privacy';
  static const String termsOfService = '/legal/terms';
}

// ============================================================
// APP ROUTER
// ============================================================

/// AppRouter — Comprehensive GoRouter configuration for لَفَّة (Laffah).
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'LaffahRootNavigator');

  static final GlobalKey<NavigatorState> _shellNavigatorKeyHome =
      GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final GlobalKey<NavigatorState> _shellNavigatorKeyHistory =
      GlobalKey<NavigatorState>(debugLabel: 'shellHistory');
  static final GlobalKey<NavigatorState> _shellNavigatorKeyWallet =
      GlobalKey<NavigatorState>(debugLabel: 'shellWallet');
  static final GlobalKey<NavigatorState> _shellNavigatorKeyProfile =
      GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: LaffahRoutes.authLanding,
    debugLogDiagnostics: false,

    // ─────────────────────────────────────────────────────────────
    // ROUTE DEFINITIONS
    // ─────────────────────────────────────────────────────────────
    routes: <RouteBase>[
      // ══════════════════════════════════════════
      // SPLASH
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.splash,
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) =>
            const SplashPage(),
      ),

      // ══════════════════════════════════════════
      // ONBOARDING
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.onboarding,
        name: 'onboarding',
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingPage(),
      ),

      // ══════════════════════════════════════════
      // AUTH FLOW
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.authLanding,
        name: 'auth-landing',
        builder: (BuildContext context, GoRouterState state) =>
            const AuthLandingPage(),
      ),

      GoRoute(
        path: LaffahRoutes.authPhone,
        name: 'auth-phone',
        builder: (BuildContext context, GoRouterState state) =>
            const PhoneNumberInputPage(),
      ),


      GoRoute(
        path: LaffahRoutes.authRegisterPassenger,
        name: 'auth-register-passenger',
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterPassengerPage(),
      ),

      GoRoute(
        path: LaffahRoutes.authRegisterCaptain,
        name: 'auth-register-captain',
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterCaptainPage(),
      ),

      GoRoute(
        path: LaffahRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordPage(),
      ),

      // ══════════════════════════════════════════
      // PASSENGER — MAIN SHELL ROUTE (4 ROOT TABS)
      // ══════════════════════════════════════════
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return LaffahMainShellScaffold(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          // Branch 0: الرئيسية (Home)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyHome,
            routes: <RouteBase>[
              GoRoute(
                path: LaffahRoutes.passengerHome,
                name: 'passenger-home',
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeDashboardPage(),
              ),
            ],
          ),

          // Branch 1: رحلاتي (History & Active Orders)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyHistory,
            routes: <RouteBase>[
              GoRoute(
                path: LaffahRoutes.passengerHistory,
                name: 'passenger-history',
                builder: (BuildContext context, GoRouterState state) =>
                    const TripHistoryPage(),
              ),
            ],
          ),

          // Branch 2: المحفظة (Wallet)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyWallet,
            routes: <RouteBase>[
              GoRoute(
                path: LaffahRoutes.passengerWallet,
                name: 'passenger-wallet',
                builder: (BuildContext context, GoRouterState state) =>
                    const WalletPage(),
              ),
            ],
          ),

          // Branch 3: الحساب (Profile)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyProfile,
            routes: <RouteBase>[
              GoRoute(
                path: LaffahRoutes.passengerProfile,
                name: 'passenger-profile',
                builder: (BuildContext context, GoRouterState state) =>
                    const UserProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // ══════════════════════════════════════════
      // PASSENGER — RIDE & PARCEL FLOWS (PUSHED OVER SHELL)
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.passengerRideRequest,
        name: 'passenger-ride-request',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeDashboardPage(),
      ),

      GoRoute(
        path: LaffahRoutes.passengerParcelSend,
        name: 'passenger-parcel-send',
        builder: (BuildContext context, GoRouterState state) =>
            const ParcelSendPage(),
      ),

      // ══════════════════════════════════════════
      // PASSENGER — CORE FEATURES
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.passengerNotifications,
        name: 'passenger-notifications',
        builder: (BuildContext context, GoRouterState state) =>
            const NotificationsPage(),
      ),
      GoRoute(
        path: LaffahRoutes.passengerPromoCode,
        name: 'passenger-promo',
        builder: (BuildContext context, GoRouterState state) =>
            const PromoCodePage(),
      ),

      GoRoute(
        path: LaffahRoutes.passengerRideTracking,
        name: 'passenger-ride-tracking',
        builder: (BuildContext context, GoRouterState state) =>
        const PassengerRideTrackingPage(),
      ),

      GoRoute(
        path: LaffahRoutes.passengerRideInvoice,
        name: 'passenger-ride-invoice',
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PassengerRideInvoicePage(
            fare: (extra['fare'] as num?)?.toDouble() ?? 1200.0,
            tripId: extra['tripId'] as String? ?? 'LF-83210',
            captainName: extra['captainName'] as String? ?? 'محمد علي',
            discount: (extra['discount'] as num?)?.toDouble() ?? 0.0,
          );
        },
      ),

      GoRoute(
        path: LaffahRoutes.passengerScheduleRide,
        name: 'passenger-schedule-ride',
        builder: (BuildContext context, GoRouterState state) =>
        const PassengerScheduleRidePage(),
      ),

      // ══════════════════════════════════════════
      // PASSENGER — PARCEL DELIVERY
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.passengerParcelTracking,
        name: 'passenger-parcel-tracking',
        builder: (BuildContext context, GoRouterState state) =>
            const ParcelTrackingPage(),
      ),

      GoRoute(
        path: LaffahRoutes.passengerParcelConfirm,
        name: 'passenger-parcel-confirm',
        builder: (BuildContext context, GoRouterState state) =>
            const ParcelConfirmationPage(),
      ),

      GoRoute(
        path: LaffahRoutes.passengerParcelHistory,
        name: 'passenger-parcel-history',
        builder: (BuildContext context, GoRouterState state) =>
            const ParcelHistoryPage(),
      ),

      GoRoute(
        path: LaffahRoutes.parcelDeliveryProof,
        name: 'parcel-delivery-proof',
        builder: (BuildContext context, GoRouterState state) =>
            const ParcelDeliveryProofPage(),
      ),

      GoRoute(
        path: LaffahRoutes.passengerProfileEdit,
        name: 'passenger-profile-edit',
        builder: (BuildContext context, GoRouterState state) {
          final profile = state.extra as ProfileEntity?;
          return PassengerProfileEditPage(profile: profile);
        },
      ),

      GoRoute(
        path: LaffahRoutes.passengerSavedPlaces,
        name: 'passenger-saved-places',
        builder: (BuildContext context, GoRouterState state) =>
            const SavedPlacesPage(),
      ),

      // ══════════════════════════════════════════
      // PASSENGER — SUPPORT & INCIDENTS
      // ══════════════════════════════════════════




      // ══════════════════════════════════════════
      // CAPTAIN — HOME DASHBOARD
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.captainHome,
        name: 'captain-home',
        builder: (BuildContext context, GoRouterState state) =>
            BlocProvider<CaptainBloc>(
          create: (_) => di.sl<CaptainBloc>(),
          child: const CaptainHomePage(),
        ),
      ),

      // ══════════════════════════════════════════
      // CAPTAIN — ACTIVE TRIP NAVIGATION
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.captainNavigation,
        name: 'captain-navigation',
        builder: (BuildContext context, GoRouterState state) {
          final Map<String, dynamic> extra =
              (state.extra as Map<String, dynamic>?) ?? <String, dynamic>{};
          return CaptainNavigationPage(
            tripId: extra['tripId'] as String? ?? 'LF-00000',
            passengerName: extra['passengerName'] as String? ?? 'الراكب',
            passengerPhone:
                extra['passengerPhone'] as String? ?? '+967 777 000 000',
            passengerRating:
                (extra['passengerRating'] as num?)?.toDouble() ?? 5.0,
            pickup: extra['pickup'] as String? ?? 'موقع الانطلاق',
            dropoff: extra['dropoff'] as String? ?? 'وجهة الوصول',
            fare: (extra['fare'] as num?)?.toDouble() ?? 0.0,
            distance: extra['distance'] as String? ?? '—',
            duration: extra['duration'] as String? ?? '—',
          );
        },
      ),

      // ══════════════════════════════════════════
      // CAPTAIN — HISTORY & PERFORMANCE
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.captainHistory,
        name: 'captain-history',
        builder: (BuildContext context, GoRouterState state) =>
            const CaptainTripHistoryPage(),
      ),

      GoRoute(
        path: LaffahRoutes.captainPerformance,
        name: 'captain-performance',
        builder: (BuildContext context, GoRouterState state) =>
            const CaptainPerformancePage(),
      ),

      GoRoute(
        path: LaffahRoutes.captainSettings,
        name: 'captain-settings',
        builder: (BuildContext context, GoRouterState state) =>
            const CaptainSettingsPage(),
      ),

      GoRoute(
        path: LaffahRoutes.captainRideInvoice,
        name: 'captain-ride-invoice',
        builder: (BuildContext context, GoRouterState state) =>
            const CaptainRideInvoicePage(),
      ),

      GoRoute(
        path: LaffahRoutes.captainParcelDetails,
        name: 'captain-parcel-details',
        builder: (BuildContext context, GoRouterState state) =>
            const CaptainParcelDetailsPage(),
      ),

      GoRoute(
        path: LaffahRoutes.captainBonus,
        name: 'captain-bonus',
        builder: (BuildContext context, GoRouterState state) =>
        const CaptainBonusPage(),
      ),

      // ══════════════════════════════════════════
      // CAPTAIN — FINANCE
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.captainPayout,
        name: 'captain-payout',
        builder: (BuildContext context, GoRouterState state) =>
            const CaptainPayoutRequestPage(),
      ),

      // ══════════════════════════════════════════
      // CAPTAIN — ACCOUNT MANAGEMENT
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.captainDocuments,
        name: 'captain-documents',
        builder: (BuildContext context, GoRouterState state) =>
            const CaptainDocumentUploadPage(),
      ),

      GoRoute(
        path: LaffahRoutes.captainSupport,
        name: 'captain-support',
        builder: (BuildContext context, GoRouterState state) =>
        const CaptainSupportPage(),
      ),

      // ══════════════════════════════════════════
      // PROFILE — HELP, FAQ, CONTACT, CHANGE PASSWORD
      // (Static placeholder pages — replace with real content later)
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.helpCenter,
        name: 'help-center',
        builder: (BuildContext context, GoRouterState state) =>
            const LaffahComingSoonPage(
          featureNameAr: 'مركز المساعدة',
          featureNameEn: 'Help Center',
          iconData: Icons.help_outline_rounded,
        ),
      ),

      GoRoute(
        path: LaffahRoutes.faq,
        name: 'faq',
        builder: (BuildContext context, GoRouterState state) =>
            const LaffahComingSoonPage(
          featureNameAr: 'الأسئلة الشائعة',
          featureNameEn: 'FAQ',
          iconData: Icons.quiz_outlined,
        ),
      ),

      GoRoute(
        path: LaffahRoutes.contactUs,
        name: 'contact-us',
        builder: (BuildContext context, GoRouterState state) =>
            const LaffahComingSoonPage(
          featureNameAr: 'تواصل معنا',
          featureNameEn: 'Contact Us',
          iconData: Icons.mail_outline_rounded,
        ),
      ),

      GoRoute(
        path: LaffahRoutes.changePassword,
        name: 'change-password',
        builder: (BuildContext context, GoRouterState state) =>
            const LaffahComingSoonPage(
          featureNameAr: 'تغيير كلمة المرور',
          featureNameEn: 'Change Password',
          iconData: Icons.lock_outline_rounded,
        ),
      ),

      // ══════════════════════════════════════════
      // LEGAL & SHARED INFORMATIONAL PAGES
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.privacyPolicy,
        name: 'privacy-policy',
        builder: (BuildContext context, GoRouterState state) =>
        const PrivacyPolicyPage(),
      ),

      GoRoute(
        path: LaffahRoutes.termsOfService,
        name: 'terms-of-service',
        builder: (BuildContext context, GoRouterState state) =>
        const TermsOfServicePage(),
      ),
    ],

    // ─────────────────────────────────────────────────────────────
    // ERROR HANDLER — unknown routes
    // ─────────────────────────────────────────────────────────────
    errorBuilder: (BuildContext context, GoRouterState state) {
      return _LaffahRouteErrorPage(
        errorMessage: state.error?.message ?? 'المسار المطلوب غير موجود',
      );
    },
  );
}

// ============================================================
// INTERNAL: Branded route error page
// ============================================================

class _LaffahRouteErrorPage extends StatelessWidget {
  final String errorMessage;

  const _LaffahRouteErrorPage({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s24),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.danger,
                      size: 52,
                    ),
                  ),
                  AppSpacing.h24,
                  const Text(
                    'الصفحة غير موجودة',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                  AppSpacing.h12,
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.gray500,
                    ),
                  ),
                  AppSpacing.h40,
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(LaffahRoutes.splash);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppSpacing.radiusMD,
                        ),
                      ),
                      icon: const Icon(Icons.home_rounded, size: 20),
                      label: const Text(
                        'العودة للرئيسية',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
