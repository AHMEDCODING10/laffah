import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_app_bar.dart';
import '../../data/models/promo_voucher_model.dart';
import '../widgets/promo_card.dart';

/// PromoCodePage — Passenger Promo Codes & Discounts Screen.
/// Refactored to Clean Architecture composition.
class PromoCodePage extends StatefulWidget {
  const PromoCodePage({super.key});

  @override
  State<PromoCodePage> createState() => _PromoCodePageState();
}

class _PromoCodePageState extends State<PromoCodePage> {
  final TextEditingController _codeController = TextEditingController();
  late final List<PromoVoucherModel> _promos;

  @override
  void initState() {
    super.initState();
    // Promos will be loaded from the real backend API
    _promos = [];
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _applyPromoCode(String code) {
    if (code.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال رمز الخصم أولاً',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تفعيل كود الخصم ($code) بنجاح!',
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
        ),
        backgroundColor: AppColors.success,
      ),
    );
    _codeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: const LaffahAppBar(title: 'أكواد الخصم والعروض'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s20,
            AppSpacing.s20,
            100,
          ),
          children: [
            // Promo Code Entry Card
            GlassBox(
              borderRadius: AppSpacing.radiusLG,
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'هل لديك كود خصم خاص؟',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                  AppSpacing.h12,
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? AppColors.white : AppColors.gray900,
                          ),
                          decoration: InputDecoration(
                            hintText: 'أدخل رمز الخصم (مثال: LAFFAH20)',
                            hintStyle: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 12,
                              color: isDark ? AppColors.gray500 : AppColors.gray400,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.white.withValues(alpha: 0.03)
                                : AppColors.gray100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s14,
                              vertical: AppSpacing.s12,
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: AppSpacing.radiusSM,
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.w10,
                      ElevatedButton(
                        onPressed: () => _applyPromoCode(_codeController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s20,
                            vertical: AppSpacing.s14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderSM,
                          ),
                        ),
                        child: const Text(
                          'تطبيق',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            AppSpacing.h24,

            // Active Promos Title
            Text(
              'العروض والقسائم المتاحة لك',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),

            AppSpacing.h12,

            // Active Promos List
            for (final promo in _promos)
              PromoCard(
                isDark: isDark,
                promo: promo,
                onApply: () => _applyPromoCode(promo.code),
              ),
          ],
        ),
      ),
    );
  }
}
