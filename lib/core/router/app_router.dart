import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/pages/coming_soon_page.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

// Auth module
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/auth_landing_page.dart';
import '../../features/auth/presentation/pages/phone_number_input_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/register_passenger_page.dart';
import '../../features/auth/presentation/pages/register_captain_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';

// Passenger home
import '../../features/home/presentation/pages/home_dashboard_page.dart';

// Passenger ride & history
import '../../features/ride/presentation/pages/trip_history_page.dart';

// Captain core features
import '../../features/captain/presentation/pages/captain_trip_history_page.dart';
import '../../features/captain/presentation/pages/captain_performance_page.dart';
import '../../features/captain/presentation/pages/captain_settings_page.dart';
import '../../features/captain/presentation/pages/captain_ride_invoice_page.dart';
import '../../features/captain/presentation/pages/captain_parcel_details_page.dart';

// Passenger core features
import '../../features/passenger/presentation/pages/wallet_page.dart';
import '../../features/passenger/presentation/pages/notifications_page.dart';
import '../../features/passenger/presentation/pages/promo_code_page.dart';
import '../../features/ride/presentation/pages/report_incident_page.dart';
import '../../features/ride/presentation/pages/support_tickets_page.dart';

// Parcel Delivery features
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
import '../../features/profile/presentation/pages/user_profile_page.dart';
import '../../features/profile/presentation/pages/saved_places_page.dart';

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
  static const String authLanding = '/auth';
  static const String authPhone = '/auth/phone';
  static const String authOtp = '/auth/otp';
  static const String authRegisterPassenger = '/auth/register/passenger';
  static const String authRegisterCaptain = '/auth/register/captain';
  static const String roleSelection = '/auth/role';
  static const String forgotPassword = '/auth/forgot-password';

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
  static const String passengerRideTracking = '/passenger/ride/tracking';
  static const String passengerRideInvoice = '/passenger/ride/invoice';
  static const String passengerScheduleRide = '/passenger/ride/schedule';

  // ──────────────────────────────────────────
  // PASSENGER — PARCEL DELIVERY
  // ──────────────────────────────────────────
  static const String passengerParcelTracking = '/passenger/parcel/tracking';
  static const String passengerParcelConfirm = '/passenger/parcel/confirm';
  static const String passengerParcelHistory = '/passenger/parcel/history';
  static const String parcelDeliveryProof = '/parcel/proof';

  // ──────────────────────────────────────────
  // PASSENGER — PROFILE
  // ──────────────────────────────────────────
  static const String passengerProfile = '/passenger/profile';
  static const String passengerProfileEdit = '/passenger/profile/edit';
  static const String passengerSavedPlaces = '/passenger/profile/saved-places';

  // ──────────────────────────────────────────
  // PASSENGER — SUPPORT
  // ──────────────────────────────────────────
  static const String passengerReportIncident = '/passenger/support/report';
  static const String passengerSupportTickets = '/passenger/support/tickets';

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
        path: LaffahRoutes.authOtp,
        name: 'auth-otp',
        builder: (BuildContext context, GoRouterState state) {
          final String phone = state.uri.queryParameters['phone'] ?? '';
          return OTPVerificationPage(phoneNumber: phone);
        },
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
        path: LaffahRoutes.roleSelection,
        name: 'role-selection',
        builder: (BuildContext context, GoRouterState state) =>
            const RoleSelectionPage(),
      ),

      GoRoute(
        path: LaffahRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordPage(),
      ),

      // ══════════════════════════════════════════
      // PASSENGER — HOME DASHBOARD
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.passengerHome,
        name: 'passenger-home',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeDashboardPage(),
      ),

      // ══════════════════════════════════════════
      // PASSENGER — RIDE HISTORY & ORDERS
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.passengerHistory,
        name: 'passenger-history',
        builder: (BuildContext context, GoRouterState state) =>
            const TripHistoryPage(),
      ),

      // ══════════════════════════════════════════
      // PASSENGER — CORE FEATURES
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.passengerWallet,
        name: 'passenger-wallet',
        builder: (BuildContext context, GoRouterState state) =>
            const WalletPage(),
      ),
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
            const LaffahComingSoonPage(
          featureNameAr: 'تتبع الرحلة المباشر',
          featureNameEn: 'Active Ride Tracking',
          iconData: Icons.gps_fixed_rounded,
        ),
      ),

      GoRoute(
        path: LaffahRoutes.passengerRideInvoice,
        name: 'passenger-ride-invoice',
        builder: (BuildContext context, GoRouterState state) =>
            const LaffahComingSoonPage(
          featureNameAr: 'فاتورة الرحلة',
          featureNameEn: 'Ride Invoice',
          iconData: Icons.receipt_long_rounded,
        ),
      ),

      GoRoute(
        path: LaffahRoutes.passengerScheduleRide,
        name: 'passenger-schedule-ride',
        builder: (BuildContext context, GoRouterState state) =>
            const LaffahComingSoonPage(
          featureNameAr: 'جدولة رحلة مسبقة',
          featureNameEn: 'Schedule a Ride',
          iconData: Icons.schedule_rounded,
        ),
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

      // ══════════════════════════════════════════
      // PASSENGER — PROFILE
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.passengerProfile,
        name: 'passenger-profile',
        builder: (BuildContext context, GoRouterState state) =>
            const UserProfilePage(),
      ),

      GoRoute(
        path: LaffahRoutes.passengerProfileEdit,
        name: 'passenger-profile-edit',
        builder: (BuildContext context, GoRouterState state) =>
            const LaffahComingSoonPage(
          featureNameAr: 'تعديل الملف الشخصي',
          featureNameEn: 'Edit Profile',
          iconData: Icons.edit_outlined,
        ),
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
      GoRoute(
        path: LaffahRoutes.passengerReportIncident,
        name: 'passenger-report-incident',
        builder: (BuildContext context, GoRouterState state) {
          final Map<String, dynamic>? extra =
              state.extra as Map<String, dynamic>?;
          return ReportIncidentPage(
            preFilledRideId: extra?['rideId'] as String?,
            preFilledCaptainName: extra?['captainName'] as String?,
          );
        },
      ),

      GoRoute(
        path: LaffahRoutes.passengerSupportTickets,
        name: 'passenger-support-tickets',
        builder: (BuildContext context, GoRouterState state) =>
            const SupportTicketsPage(),
      ),

      // ══════════════════════════════════════════
      // CAPTAIN — HOME DASHBOARD
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.captainHome,
        name: 'captain-home',
        builder: (BuildContext context, GoRouterState state) =>
            const CaptainHomePage(),
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
            const LaffahComingSoonPage(
          featureNameAr: 'مكافآت وبونص الكباتن',
          featureNameEn: 'Captain Bonuses & Rewards',
          iconData: Icons.emoji_events_outlined,
        ),
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
            const LaffahComingSoonPage(
          featureNameAr: 'دعم ومساعدة الكباتن',
          featureNameEn: 'Captain Support',
          iconData: Icons.headset_mic_outlined,
        ),
      ),

      // ══════════════════════════════════════════
      // LEGAL & SHARED INFORMATIONAL PAGES
      // ══════════════════════════════════════════
      GoRoute(
        path: LaffahRoutes.privacyPolicy,
        name: 'privacy-policy',
        builder: (BuildContext context, GoRouterState state) =>
            const LaffahComingSoonPage(
          featureNameAr: 'سياسة الخصوصية',
          featureNameEn: 'Privacy Policy',
          iconData: Icons.privacy_tip_outlined,
        ),
      ),

      GoRoute(
        path: LaffahRoutes.termsOfService,
        name: 'terms-of-service',
        builder: (BuildContext context, GoRouterState state) =>
            const LaffahComingSoonPage(
          featureNameAr: 'الشروط والأحكام',
          featureNameEn: 'Terms of Service',
          iconData: Icons.description_outlined,
        ),
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
                        shape: RoundedRectangleBorder(
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
