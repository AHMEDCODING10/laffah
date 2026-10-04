import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  // Laravel Local Development Environment (Sanctum/API)
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];

    // 1. Web Platform (Chrome / Edge / Firefox)
    if (kIsWeb) {
      if (envUrl != null && envUrl.startsWith('https://')) {
        return envUrl.replaceAll('/api/v1', '/api');
      }
      return 'http://127.0.0.1:8000/api';
    }

    // 2. Mobile / Desktop Platforms
    if (envUrl != null && envUrl.isNotEmpty) {
      String cleaned = envUrl.replaceAll('/api/v1', '/api');
      // If pointing to localhost/127.0.0.1 and running on Android Emulator, route to host machine alias
      if (defaultTargetPlatform == TargetPlatform.android &&
          (cleaned.contains('localhost') || cleaned.contains('127.0.0.1'))) {
        return cleaned
            .replaceAll('localhost', '10.0.2.2')
            .replaceAll('127.0.0.1', '10.0.2.2');
      }
      return cleaned;
    }

    // Default Fallbacks
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String logout = '/auth/logout';
  static const String registerPassenger = '/auth/register-passenger';
  static const String registerCaptain = '/auth/register-captain';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetCode = '/auth/verify-reset-code';
  static const String resetPassword = '/auth/reset-password';

  // Profile / User Endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String savedPlaces = '/user/saved-places';

  // Captain Endpoints
  static const String toggleOnlineStatus =
      '/captain/toggle-online'; // Aligned with backend
  static const String updateCaptainLocation =
      '/captain/update-location'; // Aligned with backend
  static String respondToTrip(String tripId) =>
      '/trips/$tripId/accept'; // Aligned with backend
  static const String requestPayout =
      '/wallet/payout-request'; // Aligned with backend
  static const String captainBonus = '/captain/bonus';
  static const String captainNotifications = '/captain/notifications';
  static const String captainNearbyRequests = '/captain/requests/nearby';
  static const String captainDocuments = '/captain/documents';


  // Shared Endpoints
  static const String tripHistory =
      '/trips/history'; // Works for both captain and passenger

  // Ride Endpoints
  static const String requestRide = '/trips/create'; // Aligned with backend
  static String trackRide(String tripId) =>
      '/trips/$tripId'; // Aligned with backend
  static String cancelRide(String tripId) =>
      '/trips/$tripId/cancel'; // Aligned with backend
  static String retryRide(String tripId) =>
      '/trips/$tripId/retry'; // Aligned with backend
  static String rateTrip(String tripId) =>
      '/trips/$tripId/rate'; // Aligned with backend
  static const String estimateRide =
      '/trips/estimate'; // Aligned with backend (was /trip/estimate)

  // Parcel Endpoints
  static const String submitParcel = '/parcel/request';
  static String trackParcel(String identifier) => '/parcel/$identifier/track';

  // Wallet Endpoints
  static const String walletBalance = '/wallet/balance';
  static const String walletRecharge = '/wallet/recharge';
  static const String walletCompanyAccounts = '/wallet/company-accounts';


  // Geocoding Endpoints
  static const String geocodeSearch = '/geocode/search';
  static const String geocodeReverse = '/geocode/reverse';

  // Notifications Endpoints
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String notificationsClearAll = '/notifications/clear-all';
  static String notificationMarkRead(String id) => '/notifications/$id/read';
  static String notificationDelete(String id) => '/notifications/$id';
}
