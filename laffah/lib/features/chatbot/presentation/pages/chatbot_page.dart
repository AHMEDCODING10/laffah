import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';

/// Representation of a single chat message
class ChatMessage {
  final String text;
  final bool isUser;
  final String timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<String> _quickSuggestions = [
    'كم سعر المشوار؟ 🏍️',
    'كيف أشحن المحفظة؟ 💳',
    'شروط نقل الطرود 📦',
    'كيف أطلب دراجة نارية؟ 📍',
    'كيف أصبح كابتن في لَفَّة؟ 🛵',
  ];

  @override
  void initState() {
    super.initState();
    _resetToWelcome();
  }

  void _resetToWelcome() {
    _messages.clear();
    _messages.add(
      ChatMessage(
        text: 'مرحباً بك في لَفَّة 🤩\nأنا مساعدك الذكي، كيف يمكنني مساعدتك اليوم؟',
        isUser: false,
        timestamp: _getFormattedTime(),
      ),
    );
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _confirmClearChat(bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'مسح المحادثة',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.gray900,
          ),
        ),
        content: Text(
          'هل ترغب في بدء محادثة جديدة ومسح الرسائل السابقة؟',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            color: isDark ? AppColors.gray400 : AppColors.gray600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _resetToWelcome();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'مسح',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Built-in intelligent rule-based knowledge engine for Laffah services.
  /// Activates when Gemini API key is unavailable or during network failure.
  String _getLocalFallbackResponse(String query) {
    final clean = query.trim().toLowerCase();

    if (clean.contains('سعر') ||
        clean.contains('تسعير') ||
        clean.contains('تكلفة') ||
        clean.contains('كم') ||
        clean.contains('فلوس') ||
        clean.contains('حساب')) {
      return 'أهلاً بك يا غالي! 🏍️\nفي "لَفَّة"، يتم احتساب تكلفة المشوار بدقة وشفافية عبر خوارزمية ذكية تعتمد على المسافة والوقت الفعلي.\nيمكنك معرفة السعر الدقيق فوراً بمجرد تحديد نقطة الانطلاق والوجهة على الخريطة وقبل تأكيد الطلب!';
    }

    if (clean.contains('محفظ') ||
        clean.contains('شحن') ||
        clean.contains('رصيد') ||
        clean.contains('كريمي') ||
        clean.contains('ون كاش') ||
        clean.contains('دفع')) {
      return 'حياك الله! 💳\nيمكنك الدفع نقداً (كاش) للكابتن مباشرة، أو عبر محفظتك في التطبيق.\nلشحن المحفظة: توجه إلى صفحة "المحفظة" واختر وسيلة الدفع المناسبة (الكريمي، ون كاش، أو عبر الكابتن مباشرة).';
    }

    if (clean.contains('طرد') ||
        clean.contains('أمان') ||
        clean.contains('توصيل') ||
        clean.contains('شحنة') ||
        clean.contains('أغراض')) {
      return 'من عيوني! 📦✨\nخدمة توصيل الطرود في "لَفَّة" سريعة وآمنة عبر دراجاتنا النارية.\nكل ما عليك هو اختيار "توصيل طرد"، إدخال بيانات المستلم ورقم هاتفه، وسيقوم الكابتن باستلام الطرد وتسليمه فوراً مع إمكانية التتبع المباشر.';
    }

    if (clean.contains('طلب') ||
        clean.contains('مشوار') ||
        clean.contains('دراجة') ||
        clean.contains('موتور') ||
        clean.contains('كابتن')) {
      return 'أبشر يا طيب! 🛵\nلطلب مشوار سريع:\n1. افتح الشاشة الرئيسية وحدد وجهتك على الخريطة.\n2. اختر "طلب دراجة نارية".\n3. سيتم إرسال الطلب لأقرب كابتن إليك ليصلك خلال دقائق!';
    }

    if (clean.contains('كابتن') && (clean.contains('سجل') || clean.contains('أصبح') || clean.contains('انضم'))) {
      return 'مرحباً بك في عائلة كباتن لَفَّة! 🏍️💨\nللتسجيل ككابتن:\n1. من صفحة تسجيل الدخول، اختر "تسجيل ككابتن".\n2. املأ بياناتك ورقم هاتفك وصورة البطاقة ورخصة الدراجة.\n3. سيقوم فريق الإدارة بمراجعة طلبك وتفعيله في أقرب وقت لتبدأ بجني الأرباح!';
    }

    if (clean.contains('مرحبا') ||
        clean.contains('هلا') ||
        clean.contains('السلام') ||
        clean.contains('صباح') ||
        clean.contains('مساء') ||
        clean.contains('حيابك')) {
      return 'حياك الله يا غالي ونوّرت لَفَّة! 😊✨\nأنا هنا لمساعدتك في أي استفسار يخص المشاوير، توصيل الطرود، شحن المحفظة، أو التسجيل ككابتن. كيف أقدر أخدمك؟';
    }

    return 'حيّاك الله يا غالي! 😊\nأنا مساعد لَفَّة الذكي المخصص لخدمات الدراجات النارية ونقل الطرود بصنعاء.\nيمكنك سؤالي عن تكلفة المشوار، شحن المحفظة، توصيل الطرود، أو التواصل مع فريق الدعم الفني من خلال قائمة المساعدة.';
  }

  Future<void> _sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: trimmedText,
          isUser: true,
          timestamp: _getFormattedTime(),
        ),
      );
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    // If API key is not configured, reply instantly with the smart local assistant
    if (apiKey.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text: _getLocalFallbackResponse(trimmedText),
            isUser: false,
            timestamp: _getFormattedTime(),
          ),
        );
      });
      _scrollToBottom();
      return;
    }

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      // Build recent conversation turns for context
      final recentTurns = _messages.length > 6
          ? _messages.sublist(_messages.length - 6)
          : _messages;

      final contents = <Map<String, dynamic>>[];

      for (final msg in recentTurns) {
        contents.add({
          "role": msg.isUser ? "user" : "model",
          "parts": [
            {"text": msg.text}
          ],
        });
      }

      final response = await dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
        data: {
          "systemInstruction": {
            "parts": [
              {
                "text": "أنت 'مساعد لَفَّة الذكي'، موظف الدعم والخدمة الافتراضي لتطبيق 'لَفَّة' (Laffah) في اليمن.\n"
                    "- أسلوبك: محترف، ودود، يتحدث بلهجة يمنية بيضاء لطيفة وخفيفة (حيابك، أبشر، من عيوني، يا غالي).\n"
                    "- الخدمة الحالية: حصرياً للدراجات النارية (المواتير) لتوصيل الركاب والطرود الفورية بأمان وسرعة بصنعاء.\n"
                    "- التسعيرة: تُحسب برمجياً بناءً على المسافة الفعلية والوقت وتظهر للمستخدم قبل تأكيد الطلب.\n"
                    "- وسائل الدفع: نقداً (كاش) ومحفظة إلكترونية (كريمي، ون كاش).\n"
                    "- ردودك مركزة وموجزة مع استخدام إيموجيات لطيفة (🏍️، 📦، ✨، 😊)."
              }
            ]
          },
          "contents": contents,
        },
      );

      if (response.statusCode == 200 &&
          response.data['candidates'] != null &&
          (response.data['candidates'] as List).isNotEmpty) {
        final reply =
            response.data['candidates'][0]['content']['parts'][0]['text'];
        if (!mounted) return;
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: reply.toString().trim(),
              isUser: false,
              timestamp: _getFormattedTime(),
            ),
          );
        });
      } else {
        throw Exception('Invalid response');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text: _getLocalFallbackResponse(trimmedText),
            isUser: false,
            timestamp: _getFormattedTime(),
          ),
        );
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        ThemeController.instance.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            )
          : const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
            onPressed: () => context.pop(),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary500, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/chatbot_avatar.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مساعد لَفَّة الذكي',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: isDark ? Colors.white : AppColors.gray900,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'متصل الآن',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: isDark
                              ? AppColors.success.withValues(alpha: 0.85)
                              : AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
                size: 22,
              ),
              tooltip: 'مسح المحادثة',
              onPressed: () => _confirmClearChat(isDark),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Message list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator(isDark);
                    }
                    final msg = _messages[index];
                    return _buildMessageBubble(msg, isDark);
                  },
                ),
              ),

              // Quick suggested prompts
              if (_messages.length <= 2)
                _buildQuickSuggestions(isDark),

              // Input bar
              _buildMessageInput(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSuggestions(bool isDark) {
    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickSuggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final suggestion = _quickSuggestions[index];
          return ActionChip(
            label: Text(
              suggestion,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                color: isDark ? Colors.white : AppColors.gray800,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: isDark
                ? AppColors.surfaceElevatedDark
                : AppColors.primary50,
            side: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.primary200,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () => _sendMessage(suggestion),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isDark) {
    return Align(
      alignment: msg.isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.80,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: msg.isUser
              ? AppColors.primary500
              : (isDark ? AppColors.surfaceElevatedDark : Colors.white),
          gradient: msg.isUser ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(msg.isUser ? 4 : 18),
            bottomRight: Radius.circular(msg.isUser ? 18 : 4),
          ),
          border: !msg.isUser && isDark
              ? Border.all(color: Colors.white.withValues(alpha: 0.08))
              : null,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                color: msg.isUser
                    ? Colors.white
                    : (isDark ? Colors.white : AppColors.gray900),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              msg.timestamp,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                color: msg.isUser
                    ? Colors.white.withValues(alpha: 0.75)
                    : (isDark ? AppColors.gray400 : AppColors.gray500),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceElevatedDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
          border: isDark
              ? Border.all(color: Colors.white.withValues(alpha: 0.08))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'يكتب الآن...',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                color: isDark ? AppColors.gray300 : AppColors.gray600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : AppColors.gray200,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceElevatedDark
                    : AppColors.gray100,
                borderRadius: BorderRadius.circular(24),
                border: isDark
                    ? Border.all(color: Colors.white.withValues(alpha: 0.06))
                    : null,
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: isDark ? Colors.white : AppColors.gray900,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك هنا...',
                  hintStyle: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: isDark ? AppColors.gray500 : AppColors.gray400,
                    fontSize: 13.5,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _sendMessage(_messageController.text);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary500.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
