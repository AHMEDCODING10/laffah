import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../ride/presentation/bloc/ride_bloc.dart';

/// PromoCodePage — Page to apply promo codes for discounts on motorcycle rides.
/// Uses clear error handling and visually appealing success states.
class PromoCodePage extends StatefulWidget {
  const PromoCodePage({super.key});

  @override
  State<PromoCodePage> createState() => _PromoCodePageState();
}

class _PromoCodePageState extends State<PromoCodePage> {
  final TextEditingController _promoController = TextEditingController();
  bool _isLoading = false;

  void _handleApplyPromo() {
    if (_promoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال كود الخصم أولاً',
            style: TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    
    context.read<RideBloc>().add(ApplyPromoCode(_promoController.text.trim()));
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<RideBloc, RideState>(
        listener: (context, state) {
          if (state is PromoCodeApplied) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم تفعيل كود الخصم بنجاح! خصم ${(state.discountPercentage * 100).toInt()}% على رحلتك',
                  style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
                ),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state is PromoCodeInvalid) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
                ),
                backgroundColor: AppColors.danger,
              ),
            );
          } else if (state is RideLoading) {
            setState(() => _isLoading = true);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.white : AppColors.gray900, size: 20),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'كود الخصم',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.h32,
                    
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.discount_rounded,
                          color: Color(0xFF3B82F6),
                          size: 50,
                        ),
                      ),
                    ),
                
                AppSpacing.h32,
                
                Text(
                  'إضافة كود خصم',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h8,
                Text(
                  'أدخل الرمز الترويجي للحصول على خصومات حصرية لرحلاتك.',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 14,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                    height: 1.5,
                  ),
                ),
                
                AppSpacing.h32,
                
                // Input Field
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.white.withValues(alpha: 0.03) : AppColors.gray50,
                    borderRadius: AppSpacing.radiusMD,
                    border: Border.all(
                      color: isDark ? AppColors.white.withValues(alpha: 0.1) : AppColors.gray300,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.local_offer_outlined, color: AppColors.gray400, size: 20),
                      AppSpacing.w12,
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          textCapitalization: TextCapitalization.characters,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.white : AppColors.gray900,
                            letterSpacing: 2,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'أدخل الكود هنا',
                            hintStyle: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              color: isDark ? AppColors.gray600 : AppColors.gray400,
                              letterSpacing: 0,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleApplyPromo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: AppColors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppSpacing.radiusMD,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'تفعيل الكود',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
                AppSpacing.h32,
              ],
            ),
          ),
        ),
      );
        },
      ),
    );
  }
}
