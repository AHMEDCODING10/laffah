import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../ride/presentation/bloc/ride_bloc.dart';
import '../widgets/passenger/form/parcel_form_cards.dart';

/// ParcelSendPage — Refactored Passenger Parcel Send Screen for Laffah.
/// Clean Architecture & Modular Form Card Composition.
class ParcelSendPage extends StatefulWidget {
  const ParcelSendPage({super.key});

  @override
  State<ParcelSendPage> createState() => _ParcelSendPageState();
}

class _ParcelSendPageState extends State<ParcelSendPage> {
  final _formKey = GlobalKey<FormState>();

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

  final List<String> _parcelTypes = [
    'إلكترونيات',
    'مستندات وأوراق',
    'ملابس وهدايا',
    'أطعمة ومأكولات',
    'أخرى',
  ];
  late String _selectedParcelType;

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

      try {
        context.read<RideBloc>().add(SubmitParcelOrder(parcelData));
      } catch (_) {}

      context.pushReplacement(LaffahRoutes.passengerParcelTracking);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
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
              // Section 1: Sender Details
              _buildSectionHeader(
                title: 'تفاصيل المرسل',
                icon: Icons.person_outline_rounded,
                isDark: isDark,
              ),
              AppSpacing.h12,
              ParcelSenderCard(
                isDark: isDark,
                nameController: _senderNameController,
                phoneController: _senderPhoneController,
              ),

              AppSpacing.h24,

              // Section 2: Recipient Details
              _buildSectionHeader(
                title: 'تفاصيل المستلم',
                icon: Icons.people_outline_rounded,
                isDark: isDark,
              ),
              AppSpacing.h12,
              ParcelRecipientCard(
                isDark: isDark,
                nameController: _receiverNameController,
                phoneController: _receiverPhoneController,
              ),

              AppSpacing.h24,

              // Section 3: Locations
              _buildSectionHeader(
                title: 'المواقع',
                icon: Icons.map_outlined,
                isDark: isDark,
              ),
              AppSpacing.h12,
              ParcelLocationsCard(
                isDark: isDark,
                pickupController: _pickupLocationController,
                dropoffController: _dropoffLocationController,
              ),

              AppSpacing.h24,

              // Section 4: Parcel Info
              _buildSectionHeader(
                title: 'معلومات الطرد',
                icon: Icons.inventory_2_outlined,
                isDark: isDark,
              ),
              AppSpacing.h12,
              ParcelInfoCard(
                isDark: isDark,
                parcelTypes: _parcelTypes,
                selectedParcelType: _selectedParcelType,
                onChangedType: (val) {
                  if (val != null) {
                    setState(() => _selectedParcelType = val);
                  }
                },
                estimatedValueController: _estimatedValueController,
                notesController: _notesController,
              ),

              AppSpacing.h24,

              // Section 5: Insurance
              ParcelInsuranceCard(
                isDark: isDark,
                isInsuranceEnabled: _isInsuranceEnabled,
                onChanged: (val) {
                  setState(() => _isInsuranceEnabled = val);
                },
              ),

              AppSpacing.h24,

              // Price Summary Card & Submit Button
              ParcelPriceSummaryCard(
                isDark: isDark,
                baseFee: _baseShippingFee,
                isInsuranceEnabled: _isInsuranceEnabled,
                insuranceFee: _insuranceFee,
                totalPrice: _totalPrice,
                onSubmit: _submitParcelForm,
              ),

              AppSpacing.h32,
            ],
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
}
