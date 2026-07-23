class ApiEndpoints {
  // Laravel Local Development Environment (Sanctum/API)
  // For physical devices connecting to local machine use local network IP (e.g., 192.168.1.X)
  // For Android Emulator use 10.0.2.2
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Auth Endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String logout = '/auth/logout';
  
  // Example Endpoints
  static const String userProfile = '/user/profile';
}
