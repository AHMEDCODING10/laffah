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

// ============================================================
// MOTORCYCLE-SPECIFIC DOMAIN DATA (EXCLUSIVELY MOTORCYCLES)
// ============================================================

// (Motorcycle brands and engine sizes removed for simplification)

// ============================================================
// PAGE CLASS
// ============================================================

class RegisterCaptainPage extends StatefulWidget {
  const RegisterCaptainPage({super.key});

  @override
  State<RegisterCaptainPage> createState() => _RegisterCaptainPageState();
}

class _RegisterCaptainPageState extends State<RegisterCaptainPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ──────────────────────────────────────────
  // FORM KEY
  // ──────────────────────────────────────────
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ──────────────────────────────────────────
  // TEXT CONTROLLERS
  // ──────────────────────────────────────────
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _plateController = TextEditingController();

  // ──────────────────────────────────────────
  // VISIBILITY & AGREEMENT TOGGLES
  // ──────────────────────────────────────────
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  // ──────────────────────────────────────────
  // FOCUS NODES
  // ──────────────────────────────────────────
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _plateFocusNode = FocusNode();

  bool _isNameFocused = false;
  bool _isPhoneFocused = false;
  bool _isPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;
  bool _isPlateFocused = false;
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
    _plateFocusNode.addListener(
        () => setState(() => _isPlateFocused = _plateFocusNode.hasFocus));

    _nameController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
    _plateController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nameController.text.trim().isNotEmpty &&
          _phoneController.text.trim().length == 9 &&
          _passwordController.text.length >= 6 &&
          _passwordController.text == _confirmPasswordController.text &&
          _plateController.text.trim().isNotEmpty &&
          _agreeToTerms;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _plateController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _plateFocusNode.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────
  // FORM SUBMISSION
  // ──────────────────────────────────────────
  void _handleRegister() {
    if (_formKey.currentState == null) return;
    final bool isFormValid = _formKey.currentState!.validate();
    if (!isFormValid) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.auth_val_terms,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              const RoundedRectangleBorder(borderRadius: AppSpacing.radiusMD),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final String fullPhone = '+967${_phoneController.text.trim()}';

    context.read<AuthBloc>().add(
          RegisterCaptainRequested(
            name: _nameController.text.trim(),
            phone: fullPhone,
            password: _passwordController.text,
            vehicleType: AppLocalizations.of(context)!
                .auth_motorcycle, //  نوع ثابت ومباشر بدون تعقيد
            vehicleModel: AppLocalizations.of(context)!.auth_unspecified,
            vehicleYear: 2024,
            vehiclePlate: _plateController.text.trim(),
          ),
        );
  }

  // ──────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FA),
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (BuildContext context, AuthState state) {
              if (state is AuthSuccess) {
                // تسجيل الكابتن نجح - توجيه مباشر لشاشة الكابتن
                context.go(LaffahRoutes.captainHome);
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppSpacing.radiusMD),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            builder: (BuildContext context, AuthState state) {
              final bool isLoading = state is AuthLoading;

              return FadeTransition(
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ——— Header ———————————————
                        const LaffahLogo(
                            height: 80, width: 80, showSubtitle: false),
                        AppSpacing.h8,
                        Text(
                          AppLocalizations.of(context)!.auth_join_as_captain,
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: isDark ? AppColors.white : AppColors.gray900,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.auth_join_captain_desc,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 11.5,
                            color:
                                isDark ? AppColors.gray500 : AppColors.gray600,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ——— Registration Form ———
                        GlassBox(
                          borderRadius: AppSpacing.radiusXL,
                          padding: const EdgeInsets.all(AppSpacing.s24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // SECTION 1: بيانات شخصية
                                _buildSectionHeader(
                                    AppLocalizations.of(context)!
                                        .auth_capt_personal_data),
                                const SizedBox(height: 12),

                                _buildLabel(AppLocalizations.of(context)!
                                    .auth_full_name_4),
                                _buildNameField(isDark),
                                const SizedBox(height: 16),

                                _buildLabel(AppLocalizations.of(context)!.capt_mobile_number),
                                _buildPhoneField(isDark),
                                const SizedBox(height: 16),

                                _buildLabel(AppLocalizations.of(context)!
                                    .auth_new_password),
                                _buildPasswordField(isDark),
                                const SizedBox(height: 16),

                                _buildLabel(AppLocalizations.of(context)!
                                    .auth_confirm_password),
                                _buildConfirmPasswordField(isDark),

                                const SizedBox(height: 28),

                                // SECTION 2: بيانات الدراجة النارية
                                _buildSectionHeader(
                                    AppLocalizations.of(context)!
                                        .auth_bike_data),
                                const SizedBox(height: 12),

                                _buildLabel(AppLocalizations.of(context)!
                                    .auth_plate_number),
                                _buildPlateField(isDark),

                                const SizedBox(height: 24),

                                // SECTION 3: الموافقة على الشروط
                                _buildTermsCheckbox(isDark),

                                const SizedBox(height: 28),

                                // SUBMIT BUTTON
                                PrimaryGradientButton(
                                  text: AppLocalizations.of(context)!
                                      .auth_submit_request,
                                  isLoading: isLoading,
                                  onPressed:
                                      _isFormValid ? _handleRegister : null,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Back to login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.auth_already_capt,
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
                              child: Text(
                                AppLocalizations.of(context)!.auth_login_now,
                                style: const TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary500,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
    );
  }

  // ============================================================
  // HELPERS & INPUT FIELDS
  // ============================================================
  Widget _buildSectionHeader(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
      decoration: BoxDecoration(
        color: AppColors.primary500.withValues(alpha: 0.08),
        borderRadius: AppSpacing.radiusSM,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 13.5,
          fontWeight: FontWeight.w900,
          color: AppColors.primary500,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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

  InputDecoration _buildInputDecoration({
    required bool isDark,
    required bool isFocused,
    required String hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    double hintFontSize = 12,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        fontSize: hintFontSize,
        color: isDark ? AppColors.gray600 : AppColors.gray400,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 14),
      filled: true,
      fillColor:
          isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.radiusSM,
        borderSide: BorderSide(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.05)
              : AppColors.gray300,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppSpacing.radiusSM,
        borderSide: BorderSide(color: AppColors.primary500, width: 1.8),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: AppSpacing.radiusSM,
        borderSide: BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: AppSpacing.radiusSM,
        borderSide: BorderSide(color: AppColors.danger, width: 1.8),
      ),
    );
  }

  Widget _buildNameField(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: AppSpacing.radiusSM,
        boxShadow: [
          if (_isNameFocused)
            BoxShadow(
              color: AppColors.primary500.withValues(alpha: 0.12),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: TextFormField(
        controller: _nameController,
        focusNode: _nameFocusNode,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
        decoration: _buildInputDecoration(
          isDark: isDark,
          isFocused: _isNameFocused,
          hintText: AppLocalizations.of(context)!.auth_ex_name_4,
          suffixIcon: Icon(
            Icons.person_rounded,
            color: _isNameFocused ? AppColors.primary500 : AppColors.gray600,
            size: 20,
          ),
        ),
        validator: (String? value) {
          if (value == null || value.trim().isEmpty) {
            return AppLocalizations.of(context)!.auth_val_capt_name_req;
          }
          if (value.trim().split(' ').length < 3) {
            return AppLocalizations.of(context)!.auth_val_name_3_4;
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
        borderRadius: AppSpacing.radiusSM,
        boxShadow: [
          if (_isPhoneFocused)
            BoxShadow(
              color: AppColors.primary500.withValues(alpha: 0.12),
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
        decoration: _buildInputDecoration(
          isDark: isDark,
          isFocused: _isPhoneFocused,
          hintText: '7XXXXXXXX',
          hintFontSize: 14,
          suffixIcon: Icon(
            Icons.phone_iphone_rounded,
            color:
                _isPhoneFocused ? AppColors.primary500 : AppColors.gray600,
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
                  color: AppColors.primary500,
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
        ),
        validator: (String? value) {
          if (value == null || value.trim().isEmpty) {
            return AppLocalizations.of(context)!.auth_val_phone_req_2;
          }
          if (value.trim().length != 9) {
            return AppLocalizations.of(context)!.auth_val_phone_9_digits_2;
          }
          if (!value.trim().startsWith('7')) {
            return AppLocalizations.of(context)!.auth_val_phone_yemen_start;
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
        borderRadius: AppSpacing.radiusSM,
        boxShadow: [
          if (_isPasswordFocused)
            BoxShadow(
              color: AppColors.primary500.withValues(alpha: 0.12),
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
        decoration: _buildInputDecoration(
          isDark: isDark,
          isFocused: _isPasswordFocused,
          hintText: AppLocalizations.of(context)!.auth_val_min_6,
          suffixIcon: Icon(
            Icons.lock_open_rounded,
            color: _isPasswordFocused
                ? AppColors.primary500
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
        ),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.auth_val_set_pass;
          }
          if (value.length < 6) {
            return AppLocalizations.of(context)!.auth_val_enter_6;
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
        borderRadius: AppSpacing.radiusSM,
        boxShadow: [
          if (_isConfirmPasswordFocused)
            BoxShadow(
              color: AppColors.primary500.withValues(alpha: 0.12),
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
          FocusScope.of(context).requestFocus(_plateFocusNode);
        },
        style: TextStyle(
          fontFamily:
              _obscureConfirmPassword ? 'monospace' : 'IBM Plex Sans Arabic',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
        decoration: _buildInputDecoration(
          isDark: isDark,
          isFocused: _isConfirmPasswordFocused,
          hintText: AppLocalizations.of(context)!.auth_val_confirm_pass_prev,
          suffixIcon: Icon(
            Icons.lock_rounded,
            color: _isConfirmPasswordFocused
                ? AppColors.primary500
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
        ),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.auth_val_confirm_pass_req;
          }
          if (value != _passwordController.text) {
            return AppLocalizations.of(context)!.auth_val_pass_mismatch;
          }
          return null;
        },
      ),
    );
  }

  // (Motorcycle UI helpers removed)

  Widget _buildPlateField(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: AppSpacing.radiusSM,
        boxShadow: [
          if (_isPlateFocused)
            BoxShadow(
              color: AppColors.primary500.withValues(alpha: 0.12),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: TextFormField(
        controller: _plateController,
        focusNode: _plateFocusNode,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) {
          if (_isFormValid) {
            _handleRegister();
          } else {
            FocusScope.of(context).unfocus();
          }
        },
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 13.5,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
        decoration: _buildInputDecoration(
          isDark: isDark,
          isFocused: _isPlateFocused,
          hintText: AppLocalizations.of(context)!.auth_ex_plate,
        ),
        validator: (String? value) {
          if (value == null || value.trim().isEmpty) {
            return AppLocalizations.of(context)!.auth_required;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTermsCheckbox(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: _agreeToTerms,
          activeColor: AppColors.primary500,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.radiusXS,
          ),
          onChanged: (bool? val) {
            setState(() {
              _agreeToTerms = val ?? false;
              _validateForm();
            });
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _agreeToTerms = !_agreeToTerms;
                _validateForm();
              });
            },
            child: Text.rich(
              TextSpan(
                text: AppLocalizations.of(context)!.auth_agree_to,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11.5,
                  color: isDark ? AppColors.gray400 : AppColors.gray700,
                ),
                children: [
                  TextSpan(
                    text: AppLocalizations.of(context)!.auth_terms_policy,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                      text:
                          AppLocalizations.of(context)!.auth_capt_terms_suffix),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
