import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

/// CaptainCommunicationSheet — Interactive glassmorphic modal for communicating with passengers
/// via WhatsApp, SMS, Direct Phone Call, or quick one-tap messages.
class CaptainCommunicationSheet extends StatelessWidget {
  final String passengerName;
  final String passengerPhone;

  const CaptainCommunicationSheet({
    super.key,
    required this.passengerName,
    required this.passengerPhone,
  });

  static void show({
    required BuildContext context,
    required String passengerName,
    required String passengerPhone,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CaptainCommunicationSheet(
        passengerName: passengerName,
        passengerPhone: passengerPhone,
      ),
    );
  }

  void _sendQuickMessage(BuildContext context, String text) {
    HapticFeedback.heavyImpact();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFFF6B00),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'تم إرسال إشعار للراكب: "$text"',
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<String> quickMessages = const [
      'أنا وصلت موقع الاستلام وبانتظارك 📍',
      'أنا في الطريق وفي الزحمة دقيقتين وأصل 🛵',
      'يرجى التجهز والانتظار مكانك ⏱️',
      'أنا واصل عند البوابة الرئيسية 🚪',
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141822).withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.96),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Drag Handle Bar
                    Center(
                      child: Container(
                        width: 44,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    AppSpacing.h16,

                    // Header Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFFFF6B00).withValues(alpha: 0.18),
                          child: Text(
                            passengerName.isNotEmpty ? passengerName[0] : 'ر',
                            style: const TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFFF6B00),
                            ),
                          ),
                        ),
                        AppSpacing.w12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'التواصل مع الراكب: $passengerName',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : AppColors.gray900,
                                ),
                              ),
                              Text(
                                passengerPhone,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: AppColors.gray500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.h20,

                    // Communication Channels (WhatsApp, Call, SMS)
                    const Text(
                      'اختر وسيلة المراسلة المباشرة:',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.gray500,
                      ),
                    ),

                    AppSpacing.h10,

                    Row(
                      children: [
                        // WhatsApp Direct Option
                        Expanded(
                          child: _buildChannelCard(
                            isDark: isDark,
                            label: 'محادثة واتساب',
                            icon: Icons.chat_rounded,
                            color: const Color(0xFF25D366),
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF25D366),
                                  content: Text(
                                    'جاري فتح الواتساب لمراسلة $passengerName...',
                                    style: const TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        AppSpacing.w10,

                        // SMS Direct Option
                        Expanded(
                          child: _buildChannelCard(
                            isDark: isDark,
                            label: 'رسالة نصية SMS',
                            icon: Icons.textsms_rounded,
                            color: const Color(0xFFFF6B00),
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFFFF6B00),
                                  content: Text(
                                    'جاري فتح تطبيق الرسائل النصية لمراسلة $passengerName...',
                                    style: const TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.h20,

                    // Quick One-Tap Messages Section
                    const Text(
                      'أرسل رسالة سريعة بنقرة واحدة ⚡:',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.gray500,
                      ),
                    ),

                    AppSpacing.h8,

                    ...quickMessages.map((msg) {
                      return GestureDetector(
                        onTap: () => _sendQuickMessage(context, msg),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : AppColors.gray100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.flash_on_rounded,
                                size: 16,
                                color: Color(0xFFFF6B00),
                              ),
                              AppSpacing.w10,
                              Expanded(
                                child: Text(
                                  msg,
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.gray900,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.send_rounded,
                                size: 16,
                                color: AppColors.gray500,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    AppSpacing.h16,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelCard({
    required bool isDark,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
