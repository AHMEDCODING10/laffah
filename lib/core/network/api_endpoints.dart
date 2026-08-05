import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  // Laravel Local Development Environment (Sanctum/API)
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      String cleaned = envUrl.replaceAll('/api/v1', '/api');
      if (kIsWeb && (cleaned.contains('10.0.2.2') || cleaned.contains('172.20.10.13'))) {
        return 'http://localhost:8000/api';
      }
      return cleaned;
    }
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    return 'http://10.0.2.2:8000/api';
  }
  
  // Auth Endpoints
  static const String login            = '/auth/login';
  static const String sendOtp          = '/auth/send-otp';
  static const String verifyOtp        = '/auth/verify-otp';
  static const String logout           = '/auth/logout';
  static const String registerPassenger = '/auth/register-passenger';
  static const String registerCaptain   = '/auth/register-captain';

  // Profile / User Endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String savedPlaces = '/user/saved-places';

  // Captain Endpoints
  static const String toggleOnlineStatus = '/captain/toggle-online'; // Aligned with backend
  static String respondToTrip(String tripId) => '/trips/$tripId/accept'; // Aligned with backend
  static const String requestPayout = '/wallet/payout-request'; // Aligned with backend
  static const String captainBonus = '/captain/bonus';
  static const String captainNotifications = '/captain/notifications';
  static const String captainNearbyRequests = '/captain/requests/nearby';
  static const String captainDocuments = '/captain/documents';

  // Shared Endpoints
  static const String tripHistory = '/trips/history'; // Works for both captain and passenger

  // Ride Endpoints
  static const String requestRide = '/trips/create'; // Aligned with backend
  static String cancelRide(String tripId) => '/trips/$tripId/cancel'; // Aligned with backend
  static const String estimateRide = '/trips/estimate'; // Aligned with backend (was /trip/estimate)

  // Parcel Endpoints
  static const String submitParcel = '/parcel/request';

  // Wallet Endpoints
  static const String walletBalance = '/wallet/balance';
  static const String walletRecharge = '/wallet/recharge';
}
