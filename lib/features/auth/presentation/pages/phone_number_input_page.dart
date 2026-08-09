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
import 'auth_landing_page.dart';

/// PhoneNumberInputPage - Dedicated, high-contrast login screen for Laffah (راكب / كابتن)
/// Features Yemen +967 formatting, focus glow borders, and registration role selection.
class PhoneNumberInputPage extends StatefulWidget {
  const PhoneNumberInputPage({super.key});

  @override
  State<PhoneNumberInputPage> createState() => _PhoneNumberInputPageState();
}

class _PhoneNumberInputPageState extends State<PhoneNumberInputPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isCaptain = false; // Toggle login role context

  // Focus nodes to manage glow border states
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isPhoneFocused = false;
  bool _isPasswordFocused = false;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() {
        _isPhoneFocused = _phoneFocusNode.hasFocus;
      });
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final String phoneDigits = _phoneController.text.trim();
      final String fullPhoneNumber = '+967$phoneDigits';

      // Fire Login Code event to BLoC
      context.read<AuthBloc>().add(LoginRequested(
        phone: fullPhoneNumber,
        password: _passwordController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl, // RTL layout
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.white : AppColors.gray900,
              size: 20,
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          centerTitle: true,
          title: Text(
            'تسجيل الدخول',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                final isCapt = state.role == 'captain';
                
                if (_isCaptain && !isCapt) {
                  context.read<AuthBloc>().add(const LogoutRequested());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.danger,
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'هذا الحساب مسجل كراكب. يرجى اختيار تسجيل دخول راكب بدلاً من كابتن.',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  );
                  return;
                } else if (!_isCaptain && isCapt) {
                  context.read<AuthBloc>().add(const LogoutRequested());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.danger,
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'هذا الحساب مسجل ككابتن. يرجى اختيار تسجيل دخول كابتن بدلاً من راكب.',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  );
                  return;
                }

                // Navigate to home based on verified role
                if (mounted) {
                  context.go(isCapt ? LaffahRoutes.captainHome : LaffahRoutes.passengerHome);
                }
              } else if (state is AuthFailure) {
                // Show high-fidelity snackbar
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
                        fontSize: 12.5,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Brand Identity
                      const LaffahLogo(
                        height: 100,
                        width: 100,
                        showSubtitle: false,
                      ),
                      AppSpacing.h8,
                      Text(
                        'مرحباً بك مجدداً في لَفَّة',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                      Text(
                        'سجّل دخولك لمتابعة مشاويرك وإدارة حسابك',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                          color: isDark ? AppColors.gray500 : AppColors.gray600,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Glassmorphic Login Container
                      GlassBox(
                        borderRadius: AppSpacing.radiusXL,
                        padding: const EdgeInsets.all(AppSpacing.s24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Role Selection Toggle (عميل vs كابتن)
                              Center(
                                child: _buildRoleSegmentedToggle(isDark),
                              ),

                              const SizedBox(height: 24),

                              // Phone Label
                              const Text(
                                'رقم الهاتف المحمول:',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gray600,
                                ),
                              ),
                              AppSpacing.h8,

                              // Phone TextFormField with Yemen code prefix
                              _buildPhoneTextField(isDark),

                              const SizedBox(height: 20),

                              // Password Label
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'كلمة المرور:',
                                    style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gray600,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // Handle forgot password flow
                                    },
                                    child: const Text(
                                      'نسيت كلمة المرور؟',
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFF6B00),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.h8,

                              // Password TextFormField
                              _buildPasswordTextField(isDark),

                              const SizedBox(height: 28),

                              // Submit/Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6B00),
                                    foregroundColor: AppColors.white,
                                    elevation: 2,
                                    shadowColor: const Color(0xFFFF6B00).withValues(alpha:0.3),
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
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'دخول',
                                              style: TextStyle(
                                                fontFamily: 'IBM Plex Sans Arabic',
                                                fontWeight: FontWeight.w900,
                                                fontSize: 13.5,
                                              ),
                                            ),
                                            AppSpacing.w8,
                                            Icon(Icons.arrow_back_rounded, size: 16), // Flipped for RTL
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Redirect to landing to register/create new account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ليس لديك حساب في لَفَّة بعد؟',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 13.5,
                              color: isDark ? AppColors.gray400 : AppColors.gray600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AuthLandingPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'سجّل حساب جديد',
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
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSegmentedToggle(bool isDark) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.white.withValues(alpha:0.02) : AppColors.gray100,
        borderRadius: AppSpacing.borderMD,
        border: Border.all(
          color: isDark ? AppColors.white.withValues(alpha:0.04) : AppColors.gray200,
        ),
      ),
      child: Row(
        children: [
          // Passenger Button
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCaptain = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: AppSpacing.borderSM,
                  color: !_isCaptain
                      ? const Color(0xFFFF6B00)
                      : Colors.transparent,
                ),
                child: Text(
                  'تسجيل دخول راكب',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: !_isCaptain ? AppColors.white : AppColors.gray500,
                  ),
                ),
              ),
            ),
          ),
          // Captain Button
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCaptain = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: AppSpacing.borderSM,
                  color: _isCaptain
                      ? const Color(0xFFFF6B00)
                      : Colors.transparent,
                ),
                child: Text(
                  'تسجيل دخول كابتن',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: _isCaptain ? AppColors.white : AppColors.gray500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneTextField(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: AppSpacing.borderSM,
        boxShadow: [
          if (_isPhoneFocused)
            BoxShadow(
              color: const Color(0xFFFF6B00).withValues(alpha:0.12),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: TextFormField(
        controller: _phoneController,
        focusNode: _phoneFocusNode,
        keyboardType: TextInputType.phone,
        textDirection: TextDirection.ltr, // Numeric digits left-to-right
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
          fillColor: isDark ? AppColors.white.withValues(alpha:0.02) : AppColors.gray50,
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
                color: isDark ? AppColors.white.withValues(alpha:0.1) : AppColors.gray300,
              ),
              const SizedBox(width: AppSpacing.s12),
            ],
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: BorderSide(
              color: isDark ? AppColors.white.withValues(alpha:0.05) : AppColors.gray300,
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
            borderSide: const BorderSide(
              color: AppColors.danger,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: const BorderSide(
              color: AppColors.danger,
              width: 1.8,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'يرجى إدخال رقم الهاتف الجوال لتسجيل الدخول';
          }
          if (value.trim().length != 9) {
            return 'الرقم اليمني الصحيح يجب أن يتكون من 9 خانات';
          }
          if (!value.trim().startsWith('7')) {
            return 'يجب أن يبدأ رقم الهاتف بـ 7 (77 أو 73 أو 71 أو 70)';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordTextField(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: AppSpacing.borderSM,
        boxShadow: [
          if (_isPasswordFocused)
            BoxShadow(
              color: const Color(0xFFFF6B00).withValues(alpha:0.12),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        obscureText: _obscurePassword,
        style: TextStyle(
          fontFamily: _obscurePassword ? 'monospace' : 'IBM Plex Sans Arabic',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
        decoration: InputDecoration(
          hintText: 'أدخل كلمة المرور الخاصة بحسابك',
          hintStyle: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: isDark ? AppColors.gray600 : AppColors.gray400,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 14),
          filled: true,
          fillColor: isDark ? AppColors.white.withValues(alpha:0.02) : AppColors.gray50,
          suffixIcon: Icon(
            Icons.lock_rounded,
            color: _isPasswordFocused ? const Color(0xFFFF6B00) : AppColors.gray600,
            size: 20,
          ),
          prefixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppColors.gray600,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: BorderSide(
              color: isDark ? AppColors.white.withValues(alpha:0.05) : AppColors.gray300,
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
            borderSide: const BorderSide(
              color: AppColors.danger,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderSM,
            borderSide: const BorderSide(
              color: AppColors.danger,
              width: 1.8,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى كتابة كلمة المرور المعتمدة';
          }
          if (value.length < 6) {
            return 'يجب ألا تقل كلمة المرور عن 6 أحرف';
          }
          return null;
        },
      ),
    );
  }
}
