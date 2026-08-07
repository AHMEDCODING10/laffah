import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/ride_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class PassengerScheduleRidePage extends StatefulWidget {
  const PassengerScheduleRidePage({super.key});

  @override
  State<PassengerScheduleRidePage> createState() => _PassengerScheduleRidePageState();
}

class _PassengerScheduleRidePageState extends State<PassengerScheduleRidePage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary500,
              onPrimary: Colors.white,
              onSurface: AppColors.gray900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary500,
              onPrimary: Colors.white,
              onSurface: AppColors.gray900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<RideBloc, RideState>(
        listener: (context, state) {
          if (state is RideScheduledSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم جدولة الرحلة بنجاح!', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
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
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.white : AppColors.gray900),
                onPressed: () => context.pop(),
              ),
              centerTitle: true,
              title: Text(
                'جدولة رحلة مسبقة',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'اختر موعد الرحلة',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                  AppSpacing.h8,
                  Text(
                    'يمكنك جدولة رحلة مسبقة ليقوم الكابتن بالتوجه إليك في الموعد المحدد تماماً.',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 13,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                  AppSpacing.h32,
                  _buildPickerCard(
                    title: 'تاريخ الرحلة',
                    value: _selectedDate != null
                        ? '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}'
                        : 'اختر التاريخ',
                    icon: Icons.calendar_today_rounded,
                    isDark: isDark,
                    onTap: _pickDate,
                  ),
                  AppSpacing.h16,
                  _buildPickerCard(
                    title: 'وقت الرحلة',
                    value: _selectedTime != null ? _selectedTime!.format(context) : 'اختر الوقت',
                    icon: Icons.access_time_rounded,
                    isDark: isDark,
                    onTap: _pickTime,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: (_selectedDate != null && _selectedTime != null && state is! RideLoading)
                        ? () {
                            context.read<RideBloc>().add(
                              ScheduleRide(
                                date: _selectedDate!,
                                time: _selectedTime!.format(context),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      disabledBackgroundColor: AppColors.gray300,
                      minimumSize: const Size(double.infinity, 52),
                      shape: const RoundedRectangleBorder(borderRadius: AppSpacing.radiusMD),
                    ),
                    child: state is RideLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'تأكيد الجدولة',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                  AppSpacing.h20,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPickerCard({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.white.withValues(alpha: 0.04) : AppColors.white,
          borderRadius: AppSpacing.radiusMD,
          border: Border.all(color: isDark ? AppColors.white.withValues(alpha: 0.1) : AppColors.gray200),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: AppColors.gray200.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary500, size: 20),
            ),
            AppSpacing.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? AppColors.gray600 : AppColors.gray400),
          ],
        ),
      ),
    );
  }
}
