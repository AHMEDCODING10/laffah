import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../home/presentation/pages/location_search_page.dart';
import '../../../ride/presentation/bloc/ride_bloc.dart';

import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';

/// ParcelSendPage — Full Screen Parcel Sending Page for Laffah Passenger.
/// Built strictly per 9 design and validation requirements.
class ParcelSendPage extends StatefulWidget {
  const ParcelSendPage({super.key});

  @override
  State<ParcelSendPage> createState() => _ParcelSendPageState();
}

class _ParcelSendPageState extends State<ParcelSendPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _senderPhoneController = TextEditingController();
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverPhoneController = TextEditingController();
  final TextEditingController _estimatedValueController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _pickupLocationName = '';
  String _dropoffLocationName = '';

  final List<String> _parcelTypes = const [
    'إلكترونيات',
    'مستندات وأوراق',
    'ملابس وهدايا',
    'أطعمة ومأكولات',
    'أخرى',
  ];
  late String _selectedParcelType;

  bool _isInsuranceEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedParcelType = _parcelTypes.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfileData();
    });
  }

  void _fetchProfileData() {
    try {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        if (_senderNameController.text.isEmpty) {
          _senderNameController.text = profileState.profile.name;
        }
        if (_senderPhoneController.text.isEmpty) {
          String rawPhone = profileState.profile.phone;
          if (rawPhone.startsWith('+967')) {
            rawPhone = rawPhone.replaceFirst('+967', '');
          } else if (rawPhone.startsWith('967')) {
            rawPhone = rawPhone.replaceFirst('967', '');
          }
          _senderPhoneController.text = rawPhone.trim();
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _estimatedValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectPickupLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LocationSearchPage(locationType: 'pickup'),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _pickupLocationName = result['name'] as String;
      });
    }
  }

  Future<void> _selectDropoffLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LocationSearchPage(locationType: 'dropoff'),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _dropoffLocationName = result['name'] as String;
      });
    }
  }

  void _submitParcelForm() {
    FocusScope.of(context).unfocus();

    if (_senderNameController.text.trim().isEmpty) {
      _showErrorSnackBar('يرجى أدخال اسم المرسل الكامل');
      return;
    }
    if (_senderPhoneController.text.trim().isEmpty) {
      _showErrorSnackBar('يرجى أدخال رقم هاتف المرسل');
      return;
    }
    if (_receiverNameController.text.trim().isEmpty) {
      _showErrorSnackBar('يرجى أدخال اسم الشخص المستلم');
      return;
    }
    if (_receiverPhoneController.text.trim().isEmpty) {
      _showErrorSnackBar('يرجى أدخال رقم هاتف المستلم');
      return;
    }
    if (_pickupLocationName.trim().isEmpty) {
      _showErrorSnackBar('يرجى تحديد موقع استلام الطرد');
      return;
    }
    if (_dropoffLocationName.trim().isEmpty) {
      _showErrorSnackBar('يرجى تحديد موقع تسليم الطرد');
      return;
    }

    final parcelData = ParcelData(
      senderName: _senderNameController.text.trim(),
      senderPhone: '+967${_senderPhoneController.text.trim()}',
      receiverName: _receiverNameController.text.trim(),
      receiverPhone: '+967${_receiverPhoneController.text.trim()}',
      parcelType: _selectedParcelType,
      size: 'متوسط',
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : 'شحنة طرد عادية',
    );

    try {
      context.read<RideBloc>().add(SubmitParcelOrder(parcelData));
    } catch (_) {}

    context.pushReplacement(LaffahRoutes.passengerParcelTracking);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusMD,
        ),
      ),
    );
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s20,
              vertical: AppSpacing.s16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── 1) قسم تفاصيل المرسل ───
                _buildSectionHeader(
                  title: 'تفاصيل المرسل',
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                ),
                AppSpacing.h12,
                _buildCardContainer(
                  isDark: isDark,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _senderNameController,
                        labelText: 'اسم المرسل',
                        hintText: 'أدخل اسمك الكامل',
                        icon: Icons.person_outline_rounded,
                        isDark: isDark,
                      ),
                      AppSpacing.h12,
                      _buildTextField(
                        controller: _senderPhoneController,
                        labelText: 'رقم الهاتف',
                        hintText: '7xxxxxxxx',
                        icon: Icons.phone_iphone_rounded,
                        prefixText: '+967 ',
                        keyboardType: TextInputType.phone,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                AppSpacing.h24,

                // ─── 2) قسم تفاصيل المستلم ───
                _buildSectionHeader(
                  title: 'تفاصيل المستلم',
                  icon: Icons.people_outline_rounded,
                  isDark: isDark,
                ),
                AppSpacing.h12,
                _buildCardContainer(
                  isDark: isDark,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _receiverNameController,
                        labelText: 'اسم المستلم',
                        hintText: 'اسم الشخص المستلم',
                        icon: Icons.person_add_alt_1_rounded,
                        isDark: isDark,
                      ),
                      AppSpacing.h12,
                      _buildTextField(
                        controller: _receiverPhoneController,
                        labelText: 'رقم المستلم',
                        hintText: '7xxxxxxxx',
                        icon: Icons.phone_android_rounded,
                        prefixText: '+967 ',
                        keyboardType: TextInputType.phone,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                AppSpacing.h24,

                // ─── 3) قسم المواقع ───
                _buildSectionHeader(
                  title: 'المواقع',
                  icon: Icons.map_outlined,
                  isDark: isDark,
                ),
                AppSpacing.h12,
                _buildCardContainer(
                  isDark: isDark,
                  child: Column(
                    children: [
                      // موقع الاستلام
                      InkWell(
                        onTap: _selectPickupLocation,
                        borderRadius: AppSpacing.radiusMD,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary500
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.primary500,
                                  size: 20,
                                ),
                              ),
                              AppSpacing.w12,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'موقع الاستلام',
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.white
                                            : AppColors.gray900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _pickupLocationName.isNotEmpty
                                          ? _pickupLocationName
                                          : 'حدد موقع استلام الطرد من الـ...',
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 11.5,
                                        color: _pickupLocationName.isNotEmpty
                                            ? (isDark
                                                ? AppColors.white
                                                : AppColors.gray900)
                                            : (isDark
                                                ? AppColors.gray400
                                                : AppColors.gray600),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.gray500,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        color: isDark
                            ? AppColors.white.withValues(alpha: 0.08)
                            : AppColors.gray200,
                      ),
                      // موقع التسليم
                      InkWell(
                        onTap: _selectDropoffLocation,
                        borderRadius: AppSpacing.radiusMD,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary500
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.navigation_rounded,
                                  color: AppColors.primary500,
                                  size: 20,
                                ),
                              ),
                              AppSpacing.w12,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'موقع التسليم',
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.white
                                            : AppColors.gray900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _dropoffLocationName.isNotEmpty
                                          ? _dropoffLocationName
                                          : 'إلى أين تريد إرسال الطرد؟',
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 11.5,
                                        color: _dropoffLocationName.isNotEmpty
                                            ? (isDark
                                                ? AppColors.white
                                                : AppColors.gray900)
                                            : (isDark
                                                ? AppColors.gray400
                                                : AppColors.gray600),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.gray500,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.h24,

                // ─── 4) قسم معلومات الطرد ───
                _buildSectionHeader(
                  title: 'معلومات الطرد',
                  icon: Icons.inventory_2_outlined,
                  isDark: isDark,
                ),
                AppSpacing.h12,
                _buildCardContainer(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // نوع الطرد (Dropdown)
                      Text(
                        'نوع الطرد',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                      AppSpacing.h6,
                      DropdownButtonFormField<String>(
                        initialValue: _selectedParcelType,
                        items: _parcelTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                              type,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.gray900,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedParcelType = val);
                          }
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.primary500,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0x08FFFFFF)
                              : AppColors.gray50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
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
                        ),
                        dropdownColor: isDark
                            ? AppColors.surfaceDark
                            : AppColors.white,
                      ),

                      AppSpacing.h16,

                      // قيمة الطرد التقديرية
                      _buildTextField(
                        controller: _estimatedValueController,
                        labelText: 'قيمة الطرد التقديرية',
                        hintText: '0.00',
                        icon: Icons.monetization_on_outlined,
                        suffixText: 'ريال',
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        isDark: isDark,
                      ),

                      AppSpacing.h12,

                      // تأمين الطرد (Switch)
                      SwitchListTile(
                        value: _isInsuranceEnabled,
                        onChanged: (val) =>
                            setState(() => _isInsuranceEnabled = val),
                        activeTrackColor: AppColors.primary500,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'تأمين الطرد',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? AppColors.white : AppColors.gray900,
                          ),
                        ),
                        subtitle: Text(
                          'تأمين إضافي للمواد الثمينة ضد الفقدان أو التلف',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 11,
                            color: isDark
                                ? AppColors.gray400
                                : AppColors.gray600,
                          ),
                        ),
                      ),

                      AppSpacing.h8,

                      // ملاحظات إضافية (اختياري)
                      _buildTextField(
                        controller: _notesController,
                        labelText: 'ملاحظات إضافية (اختياري)',
                        hintText: 'أضف أي تفاصيل إضافية هنا...',
                        icon: Icons.note_alt_outlined,
                        maxLines: 3,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                AppSpacing.h24,

                // ─── 5) زر رئيسي: تأكيد وإرسال ───
                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primary500,
                    borderRadius: AppSpacing.radiusMD,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary500.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _submitParcelForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: AppColors.white,
                      elevation: 0,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.near_me_rounded,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildCardContainer({
    required Widget child,
    required bool isDark,
  }) {
    return GlassBox(
      borderRadius: AppSpacing.radiusMD,
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    required bool isDark,
    String? prefixText,
    String? suffixText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 13,
        fontFamily: 'IBM Plex Sans Arabic',
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.white : AppColors.gray900,
      ),
      decoration: InputDecoration(
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
        suffixText: suffixText,
        suffixStyle: const TextStyle(
          fontSize: 12,
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.bold,
          color: AppColors.primary500,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.primary500,
          size: 20,
        ),
        filled: true,
        fillColor: isDark ? const Color(0x08FFFFFF) : AppColors.gray50,
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
      ),
    );
  }
}
