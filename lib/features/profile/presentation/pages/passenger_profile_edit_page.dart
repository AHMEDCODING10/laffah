import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class PassengerProfileEditPage extends StatefulWidget {
  const PassengerProfileEditPage({super.key});

  @override
  State<PassengerProfileEditPage> createState() => _PassengerProfileEditPageState();
}

class _PassengerProfileEditPageState extends State<PassengerProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'أحمد اليمني');
  final _emailController = TextEditingController(text: 'ahmed@example.com');
  final _phoneController = TextEditingController(text: '777123456');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(UpdateUserProfile(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حفظ التعديلات بنجاح', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          }
        },
        builder: (context, state) {
          return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
            onPressed: () => context.pop(),
          ),
          centerTitle: true,
          title: Text(
            'تعديل الملف الشخصي',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary500.withValues(alpha: 0.1),
                      backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary500,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.camera_alt_rounded, color: AppColors.white, size: 20),
                    ),
                  ],
                ),
                AppSpacing.h32,
                _buildTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                  validator: (value) => value!.isEmpty ? 'يرجى إدخال الاسم' : null,
                ),
                AppSpacing.h16,
                _buildTextField(
                  controller: _phoneController,
                  label: 'رقم الهاتف',
                  icon: Icons.phone_android_rounded,
                  isDark: isDark,
                  keyboardType: TextInputType.phone,
                  enabled: false, // Usually phone is verified and locked
                ),
                AppSpacing.h16,
                _buildTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني (اختياري)',
                  icon: Icons.email_outlined,
                  isDark: isDark,
                  keyboardType: TextInputType.emailAddress,
                ),
                AppSpacing.h40,
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppSpacing.radiusMD,
                      ),
                    ),
                    child: state is AuthLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'حفظ التعديلات',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.white : AppColors.gray900,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          color: isDark ? AppColors.gray400 : AppColors.gray600,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary500),
        filled: true,
        fillColor: enabled
            ? (isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50)
            : (isDark ? AppColors.white.withValues(alpha: 0.01) : AppColors.gray200),
        border: const OutlineInputBorder(
          borderRadius: AppSpacing.radiusSM,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.radiusSM,
          borderSide: BorderSide(color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.radiusSM,
          borderSide: BorderSide(color: AppColors.primary500, width: 1.5),
        ),
      ),
    );
  }
}
