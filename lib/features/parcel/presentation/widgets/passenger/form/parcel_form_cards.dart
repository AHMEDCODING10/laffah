import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/widgets/glass_box.dart';

/// Helper for uniform input text style
TextStyle _inputTextStyle(bool isDark) {
  return TextStyle(
    fontSize: 13,
    fontFamily: 'IBM Plex Sans Arabic',
    fontWeight: FontWeight.bold,
    color: isDark ? AppColors.white : AppColors.gray900,
  );
}

/// Helper for uniform input field decoration
InputDecoration _inputDecoration({
  required String hintText,
  required String labelText,
  required IconData icon,
  required bool isDark,
  Color? iconColor,
  String? prefixText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: TextStyle(
      fontSize: 12,
      fontFamily: 'IBM Plex Sans Arabic',
      fontWeight: FontWeight.bold,
      color: isDark ? AppColors.gray400 : AppColors.gray600,
    ),
    hintText: hintText,
    hintStyle: TextStyle(
      fontSize: 12,
      fontFamily: 'IBM Plex Sans Arabic',
      color: isDark ? AppColors.gray500 : AppColors.gray400,
    ),
    prefixText: prefixText,
    prefixStyle: TextStyle(
      fontSize: 13,
      fontFamily: 'IBM Plex Sans Arabic',
      fontWeight: FontWeight.bold,
      color: isDark ? AppColors.white : AppColors.gray900,
    ),
    prefixIcon: Icon(
      icon,
      color: iconColor ?? AppColors.primary500,
      size: 20,
    ),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: isDark ? const Color(0x08FFFFFF) : AppColors.gray50,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.s14,
      vertical: AppSpacing.s12,
    ),
    border: OutlineInputBorder(
      borderRadius: AppSpacing.radiusSM,
      borderSide: BorderSide(
        color: isDark
            ? AppColors.white.withValues(alpha: 0.08)
            : AppColors.gray300,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppSpacing.radiusSM,
      borderSide: BorderSide(
        color: isDark
            ? AppColors.white.withValues(alpha: 0.08)
            : AppColors.gray200,
      ),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: AppSpacing.radiusSM,
      borderSide: BorderSide(
        color: AppColors.primary500,
        width: 1.5,
      ),
    ),
  );
}

/// Helper container for form cards
Widget _buildFormCard({
  required bool isDark,
  required List<Widget> children,
}) {
  return GlassBox(
    borderRadius: AppSpacing.radiusMD,
    padding: const EdgeInsets.all(AppSpacing.s16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

/// ParcelSenderCard — Sender Name & Phone inputs
class ParcelSenderCard extends StatelessWidget {
  final bool isDark;
  final TextEditingController nameController;
  final TextEditingController phoneController;

  const ParcelSenderCard({
    super.key,
    required this.isDark,
    required this.nameController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return _buildFormCard(
      isDark: isDark,
      children: [
        TextFormField(
          controller: nameController,
          style: _inputTextStyle(isDark),
          decoration: _inputDecoration(
            hintText: 'أدخل اسمك الكامل',
            labelText: 'اسم المرسل',
            icon: Icons.person_rounded,
            isDark: isDark,
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'يرجى إدخال اسم المرسل';
            }
            return null;
          },
        ),
        AppSpacing.h16,
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: _inputTextStyle(isDark),
          decoration: _inputDecoration(
            hintText: '7xxxxxxxx',
            labelText: 'رقم الهاتف',
            prefixText: '+967 ',
            icon: Icons.phone_android_rounded,
            isDark: isDark,
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'يرجى إدخال رقم الهاتف';
            }
            if (val.trim().length < 8) {
              return 'رقم الهاتف غير مكتمل';
            }
            return null;
          },
        ),
      ],
    );
  }
}

/// ParcelRecipientCard — Recipient Name & Phone inputs
class ParcelRecipientCard extends StatelessWidget {
  final bool isDark;
  final TextEditingController nameController;
  final TextEditingController phoneController;

  const ParcelRecipientCard({
    super.key,
    required this.isDark,
    required this.nameController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return _buildFormCard(
      isDark: isDark,
      children: [
        TextFormField(
          controller: nameController,
          style: _inputTextStyle(isDark),
          decoration: _inputDecoration(
            hintText: 'اسم الشخص المستلم',
            labelText: 'اسم المستلم',
            icon: Icons.people_outline_rounded,
            isDark: isDark,
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'يرجى إدخال اسم المستلم';
            }
            return null;
          },
        ),
        AppSpacing.h16,
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: _inputTextStyle(isDark),
          decoration: _inputDecoration(
            hintText: '7xxxxxxxx',
            labelText: 'رقم المستلم',
            prefixText: '+967 ',
            icon: Icons.phone_android_rounded,
            isDark: isDark,
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'يرجى إدخال رقم المستلم';
            }
            if (val.trim().length < 8) {
              return 'رقم الجوال غير مكتمل';
            }
            return null;
          },
        ),
      ],
    );
  }
}

/// ParcelLocationsCard — Pickup & Dropoff Location inputs
class ParcelLocationsCard extends StatelessWidget {
  final bool isDark;
  final TextEditingController pickupController;
  final TextEditingController dropoffController;

  const ParcelLocationsCard({
    super.key,
    required this.isDark,
    required this.pickupController,
    required this.dropoffController,
  });

  @override
  Widget build(BuildContext context) {
    return _buildFormCard(
      isDark: isDark,
      children: [
        TextFormField(
          controller: pickupController,
          style: _inputTextStyle(isDark),
          decoration: _inputDecoration(
            hintText: 'حدد موقع استلام الطرد من الـ...',
            labelText: 'موقع الاستلام',
            icon: Icons.location_on_rounded,
            iconColor: AppColors.primary500,
            suffixIcon: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.gray400,
            ),
            isDark: isDark,
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'يرجى تحديد موقع الاستلام';
            }
            return null;
          },
        ),
        AppSpacing.h16,
        TextFormField(
          controller: dropoffController,
          style: _inputTextStyle(isDark),
          decoration: _inputDecoration(
            hintText: 'إلى أين تريد إرسال الطرد؟',
            labelText: 'موقع التسليم',
            icon: Icons.near_me_rounded,
            iconColor: AppColors.primary500,
            suffixIcon: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.gray400,
            ),
            isDark: isDark,
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'يرجى تحديد موقع التسليم';
            }
            return null;
          },
        ),
      ],
    );
  }
}

/// ParcelInfoCard — Parcel Type Dropdown, Estimated Value, and Notes
class ParcelInfoCard extends StatelessWidget {
  final bool isDark;
  final List<String> parcelTypes;
  final String selectedParcelType;
  final ValueChanged<String?> onChangedType;
  final TextEditingController estimatedValueController;
  final TextEditingController notesController;

  const ParcelInfoCard({
    super.key,
    required this.isDark,
    required this.parcelTypes,
    required this.selectedParcelType,
    required this.onChangedType,
    required this.estimatedValueController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return _buildFormCard(
      isDark: isDark,
      children: [
        DropdownButtonFormField<String>(
          initialValue: selectedParcelType,
          style: _inputTextStyle(isDark),
          dropdownColor:
              isDark ? AppColors.surfaceElevatedDark : AppColors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary500,
            size: 24,
          ),
          decoration: _inputDecoration(
            hintText: 'اختر نوع المحتوى',
            labelText: 'نوع الطرد',
            icon: Icons.inventory_2_outlined,
            isDark: isDark,
          ),
          items: parcelTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(
                type,
                style: _inputTextStyle(isDark),
              ),
            );
          }).toList(),
          onChanged: onChangedType,
        ),
        AppSpacing.h16,
        TextFormField(
          controller: estimatedValueController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: _inputTextStyle(isDark),
          decoration: _inputDecoration(
            hintText: '0.00',
            labelText: 'قيمة الطرد التقديرية (ريال)',
            icon: Icons.payments_outlined,
            isDark: isDark,
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'يرجى إدخال القيمة التقديرية';
            }
            return null;
          },
        ),
        AppSpacing.h16,
        TextFormField(
          controller: notesController,
          maxLines: 3,
          style: _inputTextStyle(isDark),
          decoration: _inputDecoration(
            hintText: 'أضف أي تفاصيل إضافية هنا...',
            labelText: 'ملاحظات إضافية (اختياري)',
            icon: Icons.notes_rounded,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

/// ParcelInsuranceCard — Optional Insurance Toggle
class ParcelInsuranceCard extends StatelessWidget {
  final bool isDark;
  final bool isInsuranceEnabled;
  final ValueChanged<bool> onChanged;

  const ParcelInsuranceCard({
    super.key,
    required this.isDark,
    required this.isInsuranceEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      borderRadius: AppSpacing.radiusMD,
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s8),
            decoration: BoxDecoration(
              color: isInsuranceEnabled
                  ? AppColors.primary500.withValues(alpha: 0.15)
                  : (isDark
                      ? AppColors.white.withValues(alpha: 0.05)
                      : AppColors.gray200),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user_outlined,
              color: isInsuranceEnabled
                  ? AppColors.primary500
                  : (isDark ? AppColors.gray400 : AppColors.gray600),
              size: 22,
            ),
          ),
          AppSpacing.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تأمين الطرد',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'تأمين إضافي للمواد الثمينة ضد الفقدان أو التلف',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isInsuranceEnabled,
            activeThumbColor: AppColors.primary500,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// ParcelPriceSummaryCard — Price calculation box & Submit button
class ParcelPriceSummaryCard extends StatelessWidget {
  final bool isDark;
  final double baseFee;
  final bool isInsuranceEnabled;
  final double insuranceFee;
  final double totalPrice;
  final VoidCallback onSubmit;

  const ParcelPriceSummaryCard({
    super.key,
    required this.isDark,
    required this.baseFee,
    required this.isInsuranceEnabled,
    required this.insuranceFee,
    required this.totalPrice,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      borderRadius: AppSpacing.radiusMD,
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'رسوم الشحن الأساسية:',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12.5,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
              Text(
                '${baseFee.toStringAsFixed(0)} ريال',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ],
          ),
          if (isInsuranceEnabled) ...[
            AppSpacing.h8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'رسوم التأمين الشامل:',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12.5,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
                Text(
                  '${insuranceFee.toStringAsFixed(0)} ريال',
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primary500,
                  ),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي التكلفة المتوقعة:',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              Text(
                '${totalPrice.toStringAsFixed(0)} ريال يمني',
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
          AppSpacing.h20,
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: AppColors.white,
                elevation: 4,
                shadowColor: AppColors.primary500.withValues(alpha: 0.4),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppSpacing.radiusMD,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'تأكيد وإرسال',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                  AppSpacing.w10,
                  Icon(
                    Icons.send_rounded,
                    size: 18,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
