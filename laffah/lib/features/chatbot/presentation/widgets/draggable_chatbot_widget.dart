import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laffah/core/services/chatbot_service.dart';
import 'package:laffah/core/di/injection_container.dart' as di;
import '../../../../core/router/app_router.dart';

class DraggableChatbotWidget extends StatefulWidget {
  final Widget child;

  const DraggableChatbotWidget({super.key, required this.child});

  @override
  State<DraggableChatbotWidget> createState() => DraggableChatbotWidgetState();
}

class DraggableChatbotWidgetState extends State<DraggableChatbotWidget> {
  Offset position = const Offset(20, 100);
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    final chatbotService = di.sl<ChatbotService>();
    chatbotService.addListener(_onServiceUpdate);
    AppRouter.router.routerDelegate.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    di.sl<ChatbotService>().removeListener(_onServiceUpdate);
    AppRouter.router.routerDelegate.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatbotService = di.sl<ChatbotService>();

    String currentPath = '';
    bool isAuthRoute = false;
    try {
      final config = AppRouter.router.routerDelegate.currentConfiguration;
      currentPath = config.uri.path;
      if (currentPath.isEmpty ||
          currentPath == '/' ||
          currentPath == LaffahRoutes.splash ||
          currentPath == LaffahRoutes.onboarding ||
          currentPath.startsWith('/auth')) {
        isAuthRoute = true;
      } else if (config.isNotEmpty) {
        for (final match in config.matches) {
          final loc = match.matchedLocation;
          if (loc == '/' ||
              loc == LaffahRoutes.splash ||
              loc == LaffahRoutes.onboarding ||
              loc.startsWith('/auth')) {
            isAuthRoute = true;
            break;
          }
        }
      }
    } catch (_) {}

    final bool isHiddenScreen = !AppRouter.isAppInitialized ||
        isAuthRoute ||
        currentPath == LaffahRoutes.chatbot;

    final bool shouldShow = chatbotService.shouldShowFloatingIcon && !isHiddenScreen;

    return Stack(
      children: [
        widget.child,
        if (shouldShow)
          AnimatedPositioned(
            duration: _isDragging ? Duration.zero : const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            left: position.dx,
            top: position.dy,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() => _isDragging = true);
              },
              onPanUpdate: (details) {
                final screenSize = MediaQuery.of(context).size;
                const iconSize = 62.0;
                setState(() {
                  final newX = (position.dx + details.delta.dx)
                      .clamp(0.0, screenSize.width - iconSize);
                  final newY = (position.dy + details.delta.dy)
                      .clamp(40.0, screenSize.height - iconSize - 20.0);
                  position = Offset(newX, newY);
                });
              },
              onPanEnd: (details) {
                final screenSize = MediaQuery.of(context).size;
                final padding = MediaQuery.of(context).padding;
                const iconSize = 62.0;

                // المغناطيس الذكي: الانجذاب التلقائي لأقرب حافة (يمين أو يسار)
                final targetX = position.dx + iconSize / 2 < screenSize.width / 2
                    ? 16.0
                    : screenSize.width - iconSize - 16.0;

                // الحفاظ على الأيقونة ضمن النطاق الآمن الرأسي
                final minY = padding.top + 40.0;
                final maxY = screenSize.height - padding.bottom - 110.0;
                final targetY = position.dy.clamp(minY, maxY);

                setState(() {
                  _isDragging = false;
                  position = Offset(targetX, targetY);
                });
              },
              onLongPress: () {
                final navCtx = AppRouter.rootNavigatorKey.currentContext ?? context;
                final isDark = Theme.of(navCtx).brightness == Brightness.dark;
                showDialog(
                  context: navCtx,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: isDark ? const Color(0xFF161B26) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        Image.asset(
                          'assets/images/chatbot_avatar.png',
                          width: 32,
                          height: 32,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'المساعد الذكي لَفَّة',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'يمكنك إيقاف ظهور المساعد الذكي مؤقتاً، أو تعطيله نهائياً في أي وقت من خلال الإعدادات.',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 13,
                        color: isDark ? Colors.grey.shade300 : Colors.black87,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          di.sl<ChatbotService>().toggleChatbot(false);
                          ScaffoldMessenger.of(navCtx).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تم إيقاف المساعد الذكي. يمكنك إعادة تفعيله من الإعدادات في أي وقت.',
                                style: TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        },
                        child: const Text(
                          'إيقاف الآن',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onTap: () {
                HapticFeedback.lightImpact();
                AppRouter.router.push(LaffahRoutes.chatbot);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: _isDragging ? 68 : 62,
                height: _isDragging ? 68 : 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withValues(alpha: _isDragging ? 0.65 : 0.40),
                      blurRadius: _isDragging ? 22 : 14,
                      spreadRadius: _isDragging ? 4 : 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/chatbot_avatar.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
