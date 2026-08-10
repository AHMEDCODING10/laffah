import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_logo.dart';
import '../../../../core/widgets/primary_gradient_button.dart';
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

class _RegisterPassengerPageState extends State<RegisterPassengerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
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
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _entranceController.forward();

    _nameFocusNode.addListener(
        () => setState(() => _isNameFocused = _nameFocusNode.hasFocus));
    _phoneFocusNode.addListener(
        () => setState(() => _isPhoneFocused = _phoneFocusNode.hasFocus));
    _passwordFocusNode.addListener(
        () => setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus));
    _confirmPasswordFocusNode.addListener(() => setState(
        () => _isConfirmPasswordFocused = _confirmPasswordFocusNode.hasFocus));

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
    _entranceController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            content: Text(
              AppLocalizations.of(context)!.auth_val_terms_req,
              style:
                  const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 13),
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
          backgroundColor:
              isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FA),
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
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
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
                              AppLocalizations.of(context)!.auth_join_passenger,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.gray900,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.auth_join_passenger_desc,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.gray500
                                    : AppColors.gray600,
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
                                    _buildLabel(AppLocalizations.of(context)!.auth_full_name_last),
                                    _buildNameField(isDark),

                                    const SizedBox(height: 16),

                                    // Phone Number Field
                                    _buildLabel('رقم الهاتف الجوال:'),
                                    _buildPhoneField(isDark),

                                    const SizedBox(height: 16),

                                    // Password Field
                                    _buildLabel(AppLocalizations.of(context)!.auth_new_password),
                                    _buildPasswordField(isDark),

                                    const SizedBox(height: 16),

                                    // Confirm Password Field
                                    _buildLabel(AppLocalizations.of(context)!.auth_confirm_password),
                                    _buildConfirmPasswordField(isDark),

                                    const SizedBox(height: 16),

                                    // Referral Code Field (Optional)
                                    _buildLabel(
                                        AppLocalizations.of(context)!.auth_ref_code),
                                    _buildReferralField(isDark),

                                    const SizedBox(height: 20),

                                    // Terms & Conditions Checkbox
                                    _buildTermsCheckbox(isDark),

                                    const SizedBox(height: 24),

                                    // Register Button
                                    PrimaryGradientButton(
                                      text: AppLocalizations.of(context)!.auth_create_acc_confirm,
                                      isLoading: isLoading,
                                      onPressed:
                                          _isFormValid ? _handleRegister : null,
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
                                  AppLocalizations.of(context)!.auth_already_have_laffah,
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 13.5,
                                    color: isDark
                                        ? AppColors.gray400
                                        : AppColors.gray600,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s8),
                                GestureDetector(
                                  onTap: () {
                                    context.pushReplacement('/auth/phone');
                                  },
                                  child: Text(AppLocalizations.of(context)!.auth_login_direct,
                                    style: const TextStyle(
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
          hintText: AppLocalizations.of(context)!.auth_ex_name_2,
          hintStyle: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: isDark ? AppColors.gray600 : AppColors.gray400,
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16, vertical: 14),
          filled: true,
          fillColor: isDark
              ? AppColors.white.withValues(alpha: 0.02)
              : AppColors.gray50,
          suffixIcon: Icon(
            Icons.person_rounded,
            color: _isNameFocused ? const Color(0xFFFF6B00) : AppColors.gray600,
            size: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: BorderSide(
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.05)
                  : AppColors.gray300,
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
            return AppLocalizations.of(context)!.auth_val_name_2_3;
          }
          if (value.trim().split(' ').length < 2) {
            return AppLocalizations.of(context)!.auth_val_name_surname;
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
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16, vertical: 14),
          filled: true,
          fillColor: isDark
              ? AppColors.white.withValues(alpha: 0.02)
              : AppColors.gray50,
          suffixIcon: Icon(
            Icons.phone_iphone_rounded,
            color:
                _isPhoneFocused ? const Color(0xFFFF6B00) : AppColors.gray600,
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
                color: isDark
                    ? AppColors.white.withValues(alpha: 0.1)
                    : AppColors.gray300,
              ),
              const SizedBox(width: AppSpacing.s12),
            ],
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: BorderSide(
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.05)
                  : AppColors.gray300,
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
            return AppLocalizations.of(context)!.auth_val_phone_yemen;
          }
          if (!value.trim().startsWith('7')) {
            return AppLocalizations.of(context)!.auth_val_phone_start_7;
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
          hintText: AppLocalizations.of(context)!.auth_val_min_6,
          hintStyle: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            color: isDark ? AppColors.gray600 : AppColors.gray400,
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16, vertical: 14),
          filled: true,
          fillColor: isDark
              ? AppColors.white.withValues(alpha: 0.02)
              : AppColors.gray50,
          suffixIcon: Icon(
            Icons.lock_open_rounded,
            color: _isPasswordFocused
                ? const Color(0xFFFF6B00)
                : AppColors.gray600,
            size: 20,
          ),
          prefixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.gray600,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: BorderSide(
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.05)
                  : AppColors.gray300,
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
            return AppLocalizations.of(context)!.auth_val_secure_pass;
          }
          if (value.length < 6) {
            return AppLocalizations.of(context)!.auth_val_pass_6_chars;
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
          FocusScope.of(context)
              .requestFocus(FocusNode()); // Move to next logically or hide
        },
        style: TextStyle(
          fontFamily:
              _obscureConfirmPassword ? 'monospace' : 'IBM Plex Sans Arabic',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.auth_retype_pass,
          hintStyle: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            color: isDark ? AppColors.gray600 : AppColors.gray400,
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16, vertical: 14),
          filled: true,
          fillColor: isDark
              ? AppColors.white.withValues(alpha: 0.02)
              : AppColors.gray50,
          suffixIcon: Icon(
            Icons.lock_rounded,
            color: _isConfirmPasswordFocused
                ? const Color(0xFFFF6B00)
                : AppColors.gray600,
            size: 20,
          ),
          prefixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.gray600,
              size: 20,
            ),
            onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: BorderSide(
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.05)
                  : AppColors.gray300,
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
            return AppLocalizations.of(context)!.auth_val_confirm_pass_req;
          }
          if (value != _passwordController.text) {
            return AppLocalizations.of(context)!.auth_val_pass_not_match;
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
        hintText: AppLocalizations.of(context)!.auth_ref_code_hint,
        hintStyle: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 12,
          color: isDark ? AppColors.gray600 : AppColors.gray400,
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16, vertical: 14),
        filled: true,
        fillColor:
            isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50,
        suffixIcon: const Icon(
          Icons.card_giftcard_rounded,
          color: AppColors.gray600,
          size: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderSM,
          borderSide: BorderSide(
            color: isDark
                ? AppColors.white.withValues(alpha: 0.05)
                : AppColors.gray300,
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
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.3)
                  : AppColors.gray400,
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
              AppLocalizations.of(context)!.auth_terms_long,
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
