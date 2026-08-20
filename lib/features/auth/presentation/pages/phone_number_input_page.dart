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
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/widgets/primary_gradient_button.dart';
import 'forgot_password_page.dart';

/// PhoneNumberInputPage - Dedicated, high-contrast login screen for Laffah (راكب / كابتن)
/// Features Yemen +967 formatting, focus glow borders, and registration role selection.
class PhoneNumberInputPage extends StatefulWidget {
  const PhoneNumberInputPage({super.key});

  @override
  State<PhoneNumberInputPage> createState() => _PhoneNumberInputPageState();
}

class _PhoneNumberInputPageState extends State<PhoneNumberInputPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _entranceController.dispose();
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

    return Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FA),
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                final isCapt = state.role == 'captain';

                if (_isCaptain && !isCapt) {
                  context.read<AuthBloc>().add(const LogoutRequested());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.danger,
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        AppLocalizations.of(context)!.auth_err_acc_is_passenger,
                        style: const TextStyle(
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
                    SnackBar(
                      backgroundColor: AppColors.danger,
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        AppLocalizations.of(context)!.auth_err_acc_is_captain,
                        style: const TextStyle(
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
                  context.go(isCapt
                      ? LaffahRoutes.captainHome
                      : LaffahRoutes.passengerHome);
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
                            AppLocalizations.of(context)!.auth_welcome_back,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color:
                                  isDark ? AppColors.white : AppColors.gray900,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.auth_login_desc,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.gray500
                                  : AppColors.gray600,
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
                                  Text(
                                    AppLocalizations.of(context)!
                                        .auth_phone_label,
                                    style: const TextStyle(
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
                                  Text(
                                    AppLocalizations.of(context)!
                                        .auth_password_label,
                                    style: const TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gray600,
                                    ),
                                  ),
                                  AppSpacing.h8,

                                  // Password TextFormField
                                  _buildPasswordTextField(isDark),

                                  const SizedBox(height: 12),

                                  // Forgot Password (Moved to bottom of password field)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgotPasswordPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .auth_forgot_password,
                                        style: const TextStyle(
                                          fontFamily: 'IBM Plex Sans Arabic',
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary500,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  // Submit/Login Button
                                  PrimaryGradientButton(
                                    text: AppLocalizations.of(context)!
                                        .auth_enter,
                                    isLoading: isLoading,
                                    onPressed: _handleLogin,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Redirect to landing to register/create new account
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .auth_dont_have_account,
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
                                  context.push(LaffahRoutes.authLanding);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .auth_register_new_account,
                                  style: const TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
    );
  }

  Widget _buildRoleSegmentedToggle(bool isDark) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.white.withValues(alpha: 0.03)
            : AppColors.white.withValues(alpha: 0.4),
        borderRadius: AppSpacing.borderMD,
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.05)
              : AppColors.white.withValues(alpha: 0.6),
        ),
      ),
      child: Stack(
        children: [
          // 1. Sliding Pill (Active Indicator)
          AnimatedAlign(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            alignment:
                !_isCaptain ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: AppSpacing.borderSM,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8E3C), AppColors.primary500],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary500.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Clickable Areas & Content
          Row(
            children: [
              // Passenger Option
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isCaptain = false),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: !_isCaptain
                            ? AppColors.white
                            : (isDark ? AppColors.gray400 : AppColors.gray600),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSize(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutBack,
                            child: !_isCaptain
                                ? const Icon(Icons.person_rounded,
                                    size: 18, color: AppColors.white)
                                : const SizedBox.shrink(),
                          ),
                          if (!_isCaptain) const SizedBox(width: 6),
                          Text(AppLocalizations.of(context)!
                              .auth_register_passenger),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Captain Option
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isCaptain = true),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: _isCaptain
                            ? AppColors.white
                            : (isDark ? AppColors.gray400 : AppColors.gray600),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSize(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutBack,
                            child: _isCaptain
                                ? const Icon(Icons.two_wheeler_rounded,
                                    size: 18, color: AppColors.white)
                                : const SizedBox.shrink(),
                          ),
                          if (_isCaptain) const SizedBox(width: 6),
                          Text(AppLocalizations.of(context)!
                              .auth_register_captain),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16, vertical: 14),
          filled: true,
          fillColor: isDark
              ? AppColors.white.withValues(alpha: 0.02)
              : AppColors.gray50,
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
              color: AppColors.primary500,
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
            return AppLocalizations.of(context)!.auth_val_phone_req;
          }
          if (value.trim().length != 9) {
            return AppLocalizations.of(context)!.auth_val_phone_yemen;
          }
          if (!value.trim().startsWith('7')) {
            return AppLocalizations.of(context)!.auth_val_phone_start;
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
        style: TextStyle(
          fontFamily: _obscurePassword ? 'monospace' : 'IBM Plex Sans Arabic',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.auth_enter_password,
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
            Icons.lock_rounded,
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
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
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
              color: AppColors.primary500,
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
            return AppLocalizations.of(context)!.auth_val_pass_req;
          }
          if (value.length < 6) {
            return AppLocalizations.of(context)!.auth_val_pass_length;
          }
          return null;
        },
      ),
    );
  }
}
