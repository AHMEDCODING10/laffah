import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  /// Stream to listen for real-time connection status
  Stream<bool> get isConnectedStream;

  /// Check one-off current connection status
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Stream<bool> get isConnectedStream {
    return connectivity.onConnectivityChanged
        .map((List<ConnectivityResult> results) {
      if (results.isEmpty) return false;
      // If it contains none, then there is no connection
      if (results.contains(ConnectivityResult.none) && results.length == 1) {
        return false;
      }
      return true;
    });
  }

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();
    if (results.isEmpty ||
        (results.contains(ConnectivityResult.none) && results.length == 1)) {
      return false;
    }
    return true;
  }
}
