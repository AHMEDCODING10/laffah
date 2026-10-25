import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotService extends ChangeNotifier {
  final SharedPreferences prefs;

  static const String _chatbotEnabledKey = 'is_chatbot_enabled';

  bool _isEnabled = true;
  bool _isHidden = false; // Temporary hide

  ChatbotService({required this.prefs}) {
    _isEnabled = prefs.getBool(_chatbotEnabledKey) ?? true;
  }

  bool get isEnabled => _isEnabled;
  bool get isHidden => _isHidden;
  bool get shouldShowFloatingIcon => _isEnabled && !_isHidden;

  void toggleChatbot(bool value) {
    _isEnabled = value;
    _isHidden = false; // Reset hidden state when toggling
    prefs.setBool(_chatbotEnabledKey, value);
    notifyListeners();
  }

  void hideFloatingIconTemporarily() {
    _isHidden = true;
    notifyListeners();
  }

  void unhideFloatingIcon() {
    if (_isHidden) {
      _isHidden = false;
      notifyListeners();
    }
  }
}
