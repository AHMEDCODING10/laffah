import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_logo.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// RegisterPassengerPage - Premium account registration for Passengers (عملاء).
/// Adheres to strict 8-point spacing, glassmorphic inputs, RTL, and terms consent checks.
class RegisterPassengerPage extends StatefulWidget {
  const RegisterPassengerPage({super.key});

  @override
  State<RegisterPassengerPage> createState() => _RegisterPassengerPageState();
}

class _RegisterPassengerPageState extends State<RegisterPassengerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isNameFocused = false;
  bool _isPhoneFocused = false;
  bool _isPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() => setState(() => _isNameFocused = _nameFocusNode.hasFocus));
    _phoneFocusNode.addListener(() => setState(() => _isPhoneFocused = _phoneFocusNode.hasFocus));
    _passwordFocusNode.addListener(() => setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus));
    _confirmPasswordFocusNode.addListener(() => setState(() => _isConfirmPasswordFocused = _confirmPasswordFocusNode.hasFocus));
    
    _nameController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nameController.text.trim().isNotEmpty &&
          _phoneController.text.trim().length == 9 &&
          _passwordController.text.length >= 6 &&
          _passwordController.text == _confirmPasswordController.text &&
          _agreeToTerms;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'يرجى الموافقة على شروط الاستخدام وسياسة خصوصية لَفَّة للمتابعة',
              style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 13),
            ),
          ),
        );
        return;
      }

      final String phoneDigits = _phoneController.text.trim();
      final String fullPhone = '+967$phoneDigits';

      // Submit Registration request
      context.read<AuthBloc>().add(RegisterPassengerRequested(
        name: _nameController.text.trim(),
        phone: fullPhone,
        password: _passwordController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl, // RTL layout
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: SafeArea(
            child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                // تسجيل الراكب نجح - توجيه مباشر لشاشة الراكب الرئيسية
                context.go(LaffahRoutes.passengerHome);
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderMD,
                    ),
                    content: Text(
                      state.message,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              final bool isLoading = state is AuthLoading;

              return Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s24,
                    vertical: AppSpacing.s16,
                  ),
                  child: Column(
                    children: [
                      const LaffahLogo(
                        height: 90,
                        width: 90,
                        showSubtitle: false,
                      ),
                      AppSpacing.h8,
                      Text(
                        'انضم إلى ركاب لَفَّة',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                      Text(
                        'املأ بياناتك للبدء في طلب مشاوير آمنة وسهلة واقتصادية',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                          color: isDark ? AppColors.gray500 : AppColors.gray600,
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Glassmorphic Form Card
                      GlassBox(
                        borderRadius: AppSpacing.radiusXL,
                        padding: const EdgeInsets.all(AppSpacing.s24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Full Name Field
                              _buildLabel('الاسم الكامل والأخير:'),
                              _buildNameField(isDark),

                              const SizedBox(height: 16),

                              // Phone Number Field
                              _buildLabel('رقم الهاتف الجوال:'),
                              _buildPhoneField(isDark),

                              const SizedBox(height: 16),

                              // Password Field
                              _buildLabel('كلمة المرور الجديدة:'),
                              _buildPasswordField(isDark),

                              const SizedBox(height: 16),

                              // Confirm Password Field
                              _buildLabel('تأكيد كلمة المرور:'),
                              _buildConfirmPasswordField(isDark),

                              const SizedBox(height: 16),

                              // Referral Code Field (Optional)
                              _buildLabel('رمز الإحالة / الدعوة (اختياري):'),
                              _buildReferralField(isDark),

                              const SizedBox(height: 20),

                              // Terms & Conditions Checkbox
                              _buildTermsCheckbox(isDark),

                              const SizedBox(height: 24),

                              // Register Button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: (isLoading || !_isFormValid) ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isFormValid ? const Color(0xFFFF6B00) : AppColors.gray300,
                                    foregroundColor: AppColors.white,
                                    elevation: _isFormValid ? 2 : 0,
                                    shadowColor: const Color(0xFFFF6B00).withValues(alpha: 0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppSpacing.borderMD,
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: AppColors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'إنشاء الحساب وتأكيد رقمي',
                                          style: TextStyle(
                                            fontFamily: 'IBM Plex Sans Arabic',
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Direct back to login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'لديك حساب بالفعل في لَفَّة؟',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 13.5,
                              color: isDark ? AppColors.gray400 : AppColors.gray600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          GestureDetector(
                            onTap: () {
                              context.pushReplacement('/auth/phone');
                            },
                            child: const Text(
                              'تسجيل الدخول مباشر',
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFF6B00),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s6),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.gray600,
        ),
      ),
    );
  }

  Widget _buildNameField(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: AppSpacing.borderSM,
        boxShadow: [
          if (_isNameFocused)
            BoxShadow(
              color: const Color(0xFFFF6B00).withValues(alpha: 0.12),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: TextFormField(
        controller: _nameController,
        focusNode: _nameFocusNode,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_phoneFocusNode);
        },
        keyboardType: TextInputType.name,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
        decoration: InputDecoration(
          hintText: 'مثال: جلال أحمد الوادعي',
          hintStyle: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: isDark ? AppColors.gray600 : AppColors.gray400,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 14),
          filled: true,
          fillColor: isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50,
          suffixIcon: Icon(
            Icons.person_rounded,
            color: _isNameFocused ? const Color(0xFFFF6B00) : AppColors.gray600,
            size: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: BorderSide(
              color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: const BorderSide(
              color: Color(0xFFFF6B00),
              width: 1.8,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: const BorderSide(color: AppColors.danger, width: 1.8),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'يرجى إدخال اسمك الثنائي أو الثلاثي بالكامل';
          }
          if (value.trim().split(' ').length < 2) {
            return 'يرجى كتابة الاسم واللقب على الأقل لتسهيل التعرف عليك';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPhoneField(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: AppSpacing.borderSM,
        boxShadow: [
          if (_isPhoneFocused)
            BoxShadow(
              color: const Color(0xFFFF6B00).withValues(alpha: 0.12),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: TextFormField(
        controller: _phoneController,
        focusNode: _phoneFocusNode,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        },
        textDirection: TextDirection.ltr,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 1.5,
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(9),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          hintText: '7XXXXXXXX',
          hintStyle: TextStyle(
            fontFamily: 'monospace',
            letterSpacing: 1.0,
            fontSize: 15,
            color: isDark ? AppColors.gray600 : AppColors.gray400,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 14),
          filled: true,
          fillColor: isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50,
          suffixIcon: Icon(
            Icons.phone_iphone_rounded,
            color: _isPhoneFocused ? const Color(0xFFFF6B00) : AppColors.gray600,
            size: 20,
          ),
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: AppSpacing.s16),
              const Text(
                '+967',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: Color(0xFFFF6B00),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Container(
                height: 22,
                width: 1,
                color: isDark ? AppColors.white.withValues(alpha: 0.1) : AppColors.gray300,
              ),
              const SizedBox(width: AppSpacing.s12),
            ],
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: BorderSide(
              color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: const BorderSide(
              color: Color(0xFFFF6B00),
              width: 1.8,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: const BorderSide(color: AppColors.danger, width: 1.8),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'يرجى إدخال رقم الهاتف الجوال';
          }
          if (value.trim().length != 9) {
            return 'الرقم اليمني الصحيح يجب أن يتكون من 9 خانات';
          }
          if (!value.trim().startsWith('7')) {
            return 'يجب أن يبدأ رقم الهاتف بـ 7';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: AppSpacing.borderSM,
        boxShadow: [
          if (_isPasswordFocused)
            BoxShadow(
              color: const Color(0xFFFF6B00).withValues(alpha: 0.12),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
        },
        style: TextStyle(
          fontFamily: _obscurePassword ? 'monospace' : 'IBM Plex Sans Arabic',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
        decoration: InputDecoration(
          hintText: 'يجب ألا تقل عن 6 خانات',
          hintStyle: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            color: isDark ? AppColors.gray600 : AppColors.gray400,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 14),
          filled: true,
          fillColor: isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50,
          suffixIcon: Icon(
            Icons.lock_open_rounded,
            color: _isPasswordFocused ? const Color(0xFFFF6B00) : AppColors.gray600,
            size: 20,
          ),
          prefixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppColors.gray600,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: BorderSide(
              color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: const BorderSide(
              color: Color(0xFFFF6B00),
              width: 1.8,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: const BorderSide(color: AppColors.danger, width: 1.8),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى تحديد كلمة مرور آمنة لحسابك';
          }
          if (value.length < 6) {
            return 'يجب أن تحتوي كلمة المرور على 6 أحرف أو أرقام على الأقل';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildConfirmPasswordField(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: AppSpacing.borderSM,
        boxShadow: [
          if (_isConfirmPasswordFocused)
            BoxShadow(
              color: const Color(0xFFFF6B00).withValues(alpha: 0.12),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: TextFormField(
        controller: _confirmPasswordController,
        focusNode: _confirmPasswordFocusNode,
        obscureText: _obscureConfirmPassword,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(FocusNode()); // Move to next logically or hide
        },
        style: TextStyle(
          fontFamily: _obscureConfirmPassword ? 'monospace' : 'IBM Plex Sans Arabic',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
        decoration: InputDecoration(
          hintText: 'أعد كتابة كلمة المرور السابقة',
          hintStyle: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            color: isDark ? AppColors.gray600 : AppColors.gray400,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 14),
          filled: true,
          fillColor: isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50,
          suffixIcon: Icon(
            Icons.lock_rounded,
            color: _isConfirmPasswordFocused ? const Color(0xFFFF6B00) : AppColors.gray600,
            size: 20,
          ),
          prefixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppColors.gray600,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: BorderSide(
              color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: const BorderSide(
              color: Color(0xFFFF6B00),
              width: 1.8,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: const BorderSide(color: AppColors.danger, width: 1.8),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى تأكيد كلمة المرور';
          }
          if (value != _passwordController.text) {
            return 'كلمة المرور غير متطابقة مع كلمة السر المدخلة';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildReferralField(bool isDark) {
    return TextFormField(
      controller: _referralController,
      style: TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.white : AppColors.gray900,
      ),
      decoration: InputDecoration(
        hintText: 'رمز الإحالة (دعوة صديق)',
        hintStyle: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 12,
          color: isDark ? AppColors.gray600 : AppColors.gray400,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 14),
        filled: true,
        fillColor: isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50,
        suffixIcon: const Icon(
          Icons.card_giftcard_rounded,
          color: AppColors.gray600,
          size: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderSM,
          borderSide: BorderSide(
            color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderSM,
          borderSide: const BorderSide(
            color: Color(0xFFFF6B00),
            width: 1.8,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreeToTerms,
            activeColor: const Color(0xFFFF6B00),
            checkColor: AppColors.white,
            side: BorderSide(
              color: isDark ? AppColors.white.withValues(alpha: 0.3) : AppColors.gray400,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (val) {
              setState(() {
                _agreeToTerms = val ?? false;
                _validateForm();
              });
            },
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _agreeToTerms = !_agreeToTerms;
                _validateForm();
              });
            },
            child: Text(
              'أوافق على شروط الاستخدام وقوانين منصة لَفَّة (لفّة) لخدمات سيارات الأجرة وتوصيل الطرود وسياسة الخصوصية وحقوق المستخدم في الجمهورية اليمنية.',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 11,
                height: 1.4,
                color: isDark ? AppColors.gray400 : AppColors.gray700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
