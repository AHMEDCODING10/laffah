import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../ride/presentation/bloc/ride_bloc.dart';
import '../../../ride/presentation/bloc/ride_event.dart';

/// ParcelSendPage — Premium Parcel Send Screen for Laffah matching Stitch design specs.
/// Includes Sender/Recipient details, pickup & dropoff location selection, parcel type dropdown,
/// estimated value, optional insurance toggle, dynamic price calculation, form validation,
/// and primary orange action button navigation to live tracking.
class ParcelSendPage extends StatefulWidget {
  const ParcelSendPage({super.key});

  @override
  State<ParcelSendPage> createState() => _ParcelSendPageState();
}

class _ParcelSendPageState extends State<ParcelSendPage> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _senderNameController =
      TextEditingController(text: 'سارة العامري');
  final TextEditingController _senderPhoneController =
      TextEditingController(text: '777123456');
  final TextEditingController _receiverNameController =
      TextEditingController();
  final TextEditingController _receiverPhoneController =
      TextEditingController();
  final TextEditingController _pickupLocationController =
      TextEditingController(text: 'شارع حدة، أمام مركز الكميم');
  final TextEditingController _dropoffLocationController =
      TextEditingController();
  final TextEditingController _estimatedValueController =
      TextEditingController(text: '5000');
  final TextEditingController _notesController = TextEditingController();

  // Parcel Type Options
  final List<String> _parcelTypes = [
    'مستندات وأوراق',
    'إلكترونيات وأجهزة',
    'ملابس وهدايا',
    'أطعمة ومأكولات',
    'أخرى',
  ];
  late String _selectedParcelType;

  // Insurance State
  bool _isInsuranceEnabled = false;
  final double _baseShippingFee = 1500.0;
  final double _insuranceFee = 500.0;

  double get _totalPrice =>
      _baseShippingFee + (_isInsuranceEnabled ? _insuranceFee : 0.0);

  @override
  void initState() {
    super.initState();
    _selectedParcelType = _parcelTypes.first;
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _pickupLocationController.dispose();
    _dropoffLocationController.dispose();
    _estimatedValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitParcelForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create ParcelData DTO
      final parcelData = ParcelData(
        senderName: _senderNameController.text.trim(),
        senderPhone: _senderPhoneController.text.trim(),
        receiverName: _receiverNameController.text.trim(),
        receiverPhone: _receiverPhoneController.text.trim(),
        parcelType: _selectedParcelType,
        size: 'متوسط',
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : 'شحنة طرد عادية',
      );

      // Dispatch to RideBloc if present
      try {
        context.read<RideBloc>().add(SubmitParcelOrder(parcelData));
      } catch (_) {
        // Fallback if Bloc context is external
      }

      // Navigate to Parcel Tracking screen via pushReplacement
      context.pushReplacement(LaffahRoutes.passengerParcelTracking);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'يرجى التأكد من تعبئة جميع الحقول المطلوبة بشكل صحيح',
            style: TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.radiusMD,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: isDark
              ? AppColors.backgroundDark.withValues(alpha: 0.95)
              : AppColors.backgroundLight.withValues(alpha: 0.95),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.white : AppColors.gray900,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'إرسال طرد',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s20,
              vertical: AppSpacing.s16,
            ),
            children: [
              // ══════════════════════════════════════════
              // TOP PARCEL ILLUSTRATION HEADER
              // ══════════════════════════════════════════
              _buildHeaderIllustration(isDark),

              AppSpacing.h24,

              // ══════════════════════════════════════════
              // SECTION 1: SENDER DETAILS
              // ══════════════════════════════════════════
              _buildSectionHeader(
                title: 'تفاصيل المرسل',
                icon: Icons.person_outline_rounded,
                isDark: isDark,
              ),
              AppSpacing.h12,
              _buildSenderDetailsCard(isDark),

              AppSpacing.h24,

              // ══════════════════════════════════════════
              // SECTION 2: RECIPIENT DETAILS
              // ══════════════════════════════════════════
              _buildSectionHeader(
                title: 'تفاصيل المستلم',
                icon: Icons.people_outline_rounded,
                isDark: isDark,
              ),
              AppSpacing.h12,
              _buildRecipientDetailsCard(isDark),

              AppSpacing.h24,

              // ══════════════════════════════════════════
              // SECTION 3: LOCATIONS (PICKUP & DROPOFF)
              // ══════════════════════════════════════════
              _buildSectionHeader(
                title: 'المواقع',
                icon: Icons.map_outlined,
                isDark: isDark,
              ),
              AppSpacing.h12,
              _buildLocationsCard(isDark),

              AppSpacing.h24,

              // ══════════════════════════════════════════
              // SECTION 4: PARCEL INFORMATION
              // ══════════════════════════════════════════
              _buildSectionHeader(
                title: 'معلومات الطرد',
                icon: Icons.inventory_2_outlined,
                isDark: isDark,
              ),
              AppSpacing.h12,
              _buildParcelInfoCard(isDark),

              AppSpacing.h24,

              // ══════════════════════════════════════════
              // SECTION 5: PARCEL INSURANCE (OPTIONAL)
              // ══════════════════════════════════════════
              _buildInsuranceCard(isDark),

              AppSpacing.h24,

              // ══════════════════════════════════════════
              // PRICE SUMMARY CARD & CONFIRM BUTTON
              // ══════════════════════════════════════════
              _buildPriceSummaryAndSubmit(isDark),

              AppSpacing.h32,
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TOP ILLUSTRATION HEADER
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeaderIllustration(bool isDark) {
    return GlassBox(
      borderRadius: AppSpacing.radiusXL,
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppSpacing.radiusMD,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary500.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: AppColors.white,
              size: 40,
            ),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خدمة توصيل الطرود السريعة',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h4,
                Text(
                  'إرسال واستلام المستندات والطرود بسهولة وأمان في جميع أنحاء المدينة.',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION HEADER HELPER
  // ─────────────────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.s6),
          decoration: BoxDecoration(
            color: AppColors.primary500.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary500,
            size: 18,
          ),
        ),
        AppSpacing.w10,
        Text(
          title,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SENDER DETAILS CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildSenderDetailsCard(bool isDark) {
    return _buildFormCard(
      isDark: isDark,
      children: [
        // Sender Name
        TextFormField(
          controller: _senderNameController,
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
        // Sender Phone
        TextFormField(
          controller: _senderPhoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: _inputTextStyle(isDark),
          decoration: _inputDecoration(
            hintText: '77X XXX XXX',
            labelText: 'رقم الجوال',
            prefixText: '+967 ',
            icon: Icons.phone_android_rounded,
            isDark: isDark,
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'يرجى إدخال رقم جوال المرسل';
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

  // ─────────────────────────────────────────────────────────────
  // RECIPIENT DETAILS CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildRecipientDetailsCard(bool isDark) {
    return _buildFormCard(
      isDark: isDark,
      children: [
        // Recipient Name
        TextFormField(
          controller: _receiverNameController,
          style: _inputTextStyle(isDark),
          decoration: _inputDecoration(
            hintText: 'اسم الشخص المستلم',
            labelText: 'اسم المستلم',
            icon: Icons.person_add_alt_1_rounded,
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
        // Recipient Phone
        TextFormField(
          controller: _receiverPhoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: _inputTextStyle(isDark),
          decoration: _inputDecoration(
            hintText: '77X XXX XXX',
            labelText: 'رقم المستلم',
            prefixText: '+967 ',
            icon: Icons.phone_android_rounded,
            isDark: isDark,
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'يرجى إدخال رقم جوال المستلم';
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

  // ─────────────────────────────────────────────────────────────
  // LOCATIONS CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildLocationsCard(bool isDark) {
    return _buildFormCard(
      isDark: isDark,
      children: [
        // Pickup Location
        TextFormField(
          controller: _pickupLocationController,
          style: _inputTextStyle(isDark),
          decoration: _inputDecoration(
            hintText: 'حدد موقع استلام الطرد من...',
            labelText: 'موقع الاستلام',
            icon: Icons.location_on_rounded,
            iconColor: AppColors.success,
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
        // Dropoff Location
        TextFormField(
          controller: _dropoffLocationController,
          style: _inputTextStyle(isDark),
          decoration: _inputDecoration(
            hintText: 'اختر موقع تسليم الطرد...',
            labelText: 'إلى أين تريد إرسال الطرد؟',
            icon: Icons.location_on_rounded,
            iconColor: AppColors.danger,
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

  // ─────────────────────────────────────────────────────────────
  // PARCEL INFO CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildParcelInfoCard(bool isDark) {
    return _buildFormCard(
      isDark: isDark,
      children: [
        // Dropdown: Parcel Type
        DropdownButtonFormField<String>(
          value: _selectedParcelType,
          style: _inputTextStyle(isDark),
          dropdownColor: isDark ? AppColors.surfaceDark : AppColors.white,
          decoration: _inputDecoration(
            hintText: 'اختر نوع المحتوى',
            labelText: 'نوع الطرد',
            icon: Icons.category_rounded,
            isDark: isDark,
          ),
          items: _parcelTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(
                type,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedParcelType = val;
              });
            }
          },
        ),
        AppSpacing.h16,
        // Estimated Value
        TextFormField(
          controller: _estimatedValueController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: _inputTextStyle(isDark),
          decoration: _inputDecoration(
            hintText: 'مثال: 5000',
            labelText: 'قيمة الطرد التقديرية',
            suffixText: 'ر.ي',
            icon: Icons.payments_rounded,
            isDark: isDark,
          ),
        ),
        AppSpacing.h16,
        // Optional Notes
        TextFormField(
          controller: _notesController,
          maxLines: 2,
          style: _inputTextStyle(isDark),
          decoration: _inputDecoration(
            hintText: 'ملاحظات إضافية للكابتن (اختياري)',
            labelText: 'ملاحظات الشحنة',
            icon: Icons.note_alt_rounded,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // INSURANCE CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildInsuranceCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.6)
            : AppColors.white.withValues(alpha: 0.9),
        borderRadius: AppSpacing.radiusLG,
        border: Border.all(
          color: _isInsuranceEnabled
              ? AppColors.primary500.withValues(alpha: 0.4)
              : (isDark
                  ? AppColors.white.withValues(alpha: 0.05)
                  : AppColors.gray200),
          width: _isInsuranceEnabled ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s10),
            decoration: BoxDecoration(
              color: AppColors.primary500.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.primary500,
              size: 22,
            ),
          ),
          AppSpacing.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تأمين إرسال الطرد',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h2,
                Text(
                  'حماية شحنتك ضد الفقد أو التلف (+500 ر.ي)',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isInsuranceEnabled,
            activeThumbColor: AppColors.primary500,
            onChanged: (val) {
              setState(() {
                _isInsuranceEnabled = val;
              });
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PRICE SUMMARY CARD & SUBMIT BUTTON
  // ─────────────────────────────────────────────────────────────
  Widget _buildPriceSummaryAndSubmit(bool isDark) {
    return Column(
      children: [
        // Summary Breakdown
        Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.white,
            borderRadius: AppSpacing.radiusLG,
            border: Border.all(
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.05)
                  : AppColors.gray200,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'أجرة التوصيل التقديرية',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 13,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                  Text(
                    '${_baseShippingFee.toInt()} ر.ي',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                ],
              ),
              if (_isInsuranceEnabled) ...[
                AppSpacing.h8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'رسوم تأمين الطرد',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 13,
                        color: AppColors.primary500,
                      ),
                    ),
                    Text(
                      '+ 500 ر.ي',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.primary500,
                      ),
                    ),
                  ],
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s10),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إجمالي المبلغ',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                  Text(
                    '${_totalPrice.toInt()} ر.ي',
                    style: const TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppColors.primary500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        AppSpacing.h20,

        // Primary Confirm Button (Orange Filled)
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _submitParcelForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: AppColors.white,
              elevation: 4,
              shadowColor: AppColors.primary500.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
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
                  Icons.arrow_forward_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // FORM CARD CONTAINER HELPER
  // ─────────────────────────────────────────────────────────────
  Widget _buildFormCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.6)
            : AppColors.white.withValues(alpha: 0.9),
        borderRadius: AppSpacing.radiusLG,
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.05)
              : AppColors.gray200,
        ),
      ),
      child: Column(children: children),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TEXT INPUT STYLES & DECORATION HELPERS
  // ─────────────────────────────────────────────────────────────
  TextStyle _inputTextStyle(bool isDark) {
    return TextStyle(
      fontFamily: 'IBM Plex Sans Arabic',
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.white : AppColors.gray900,
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required String labelText,
    required IconData icon,
    required bool isDark,
    Color? iconColor,
    String? prefixText,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixText: prefixText,
      suffixText: suffixText,
      labelStyle: TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.primary500,
      ),
      hintStyle: TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        fontSize: 13,
        color: isDark ? AppColors.gray500 : AppColors.gray400,
      ),
      prefixIcon: Icon(
        icon,
        color: iconColor ?? AppColors.primary500,
        size: 20,
      ),
      filled: true,
      fillColor: isDark
          ? AppColors.backgroundDark.withValues(alpha: 0.5)
          : AppColors.gray50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s14,
        vertical: AppSpacing.s12,
      ),
      border: OutlineInputBorder(
        borderRadius: AppSpacing.radiusMD,
        borderSide: BorderSide(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.1)
              : AppColors.gray300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.radiusMD,
        borderSide: BorderSide(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.1)
              : AppColors.gray300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.radiusMD,
        borderSide: const BorderSide(
          color: AppColors.primary500,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.radiusMD,
        borderSide: const BorderSide(
          color: AppColors.danger,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.radiusMD,
        borderSide: const BorderSide(
          color: AppColors.danger,
          width: 1.5,
        ),
      ),
      errorStyle: const TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.danger,
      ),
    );
  }
}
