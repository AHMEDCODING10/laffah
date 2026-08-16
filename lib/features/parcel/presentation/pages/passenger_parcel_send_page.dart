import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../home/presentation/pages/location_search_page.dart';
import '../bloc/parcel_bloc.dart';
import '../bloc/parcel_event.dart';
import '../bloc/parcel_state.dart';
import '../widgets/passenger/form/parcel_form_cards.dart';

class PassengerParcelSendPage extends StatefulWidget {
  const PassengerParcelSendPage({super.key});

  @override
  State<PassengerParcelSendPage> createState() =>
      _PassengerParcelSendPageState();
}

class _PassengerParcelSendPageState extends State<PassengerParcelSendPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _senderNameController =
      TextEditingController();
  final TextEditingController _senderPhoneController =
      TextEditingController();
  final TextEditingController _receiverNameController =
      TextEditingController();
  final TextEditingController _receiverPhoneController =
      TextEditingController();
  final TextEditingController _pickupLocationController =
      TextEditingController(text: 'موقعي الحالي (صنعاء)');
  final TextEditingController _dropoffLocationController =
      TextEditingController();
  final TextEditingController _estimatedValueController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  LatLng _pickupLatLng = const LatLng(15.3694, 44.1910);
  LatLng? _dropoffLatLng;


  final List<String> _parcelTypes = [
    'وثائق ومستندات',
    'طرد صغير / هدايا',
    'ملابس وأقمشة',
    'أجهزة وإلكترونيات',
    'أطعمة ومشروبات',
    'أدوية ومستلزمات طبية',
    'أخرى',
  ];
  String _selectedParcelType = 'طرد صغير / هدايا';
  String _selectedSize = 'صغير';
  bool _isInsuranceEnabled = false;

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

  double get _baseFee {
    if (_selectedSize == 'متوسط') return 1500.0;
    if (_selectedSize == 'كبير') return 2000.0;
    return 1200.0;
  }

  double get _insuranceFee => _isInsuranceEnabled ? 300.0 : 0.0;

  double get _totalPrice => _baseFee + _insuranceFee;

  Future<void> _pickLocation(bool isPickup) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationSearchPage(
          locationType: isPickup ? 'pickup' : 'dropoff',
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final name = result['name'] ?? '';
        final lat = result['lat'] as double?;
        final lon = result['lon'] as double?;
        if (isPickup) {
          _pickupLocationController.text = name;
          if (lat != null && lon != null) {
            _pickupLatLng = LatLng(lat, lon);
          }
        } else {
          _dropoffLocationController.text = name;
          if (lat != null && lon != null) {
            _dropoffLatLng = LatLng(lat, lon);
          }
        }
      });
    }
  }

  void _handleSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text(
            'يرجى التأكد من ملء جميع الحقول المطلوبة بشكل صحيح.',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
      return;
    }

    if (_dropoffLocationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text(
            'يرجى تحديد موقع تسليم الطرد.',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
      return;
    }

    final notes = [
      if (_notesController.text.trim().isNotEmpty)
        _notesController.text.trim(),
      if (_isInsuranceEnabled) 'شامل التأمين',
      'من: ${_pickupLocationController.text.trim()} (${_pickupLatLng.latitude.toStringAsFixed(4)}, ${_pickupLatLng.longitude.toStringAsFixed(4)})',
      if (_dropoffLatLng != null)
        'إلى: ${_dropoffLocationController.text.trim()} (${_dropoffLatLng!.latitude.toStringAsFixed(4)}, ${_dropoffLatLng!.longitude.toStringAsFixed(4)})'
      else
        'إلى: ${_dropoffLocationController.text.trim()}',
      if (_estimatedValueController.text.trim().isNotEmpty)
        'القيمة التقديرية: ${_estimatedValueController.text.trim()} ر.ي',
    ].join(' | ');


    context.read<ParcelBloc>().add(
          SubmitParcelEvent(
            senderName: _senderNameController.text.trim(),
            senderPhone: _senderPhoneController.text.trim(),
            receiverName: _receiverNameController.text.trim(),
            receiverPhone: _receiverPhoneController.text.trim(),
            pickupAddress: _pickupLocationController.text.trim(),
            pickupLatitude: _pickupLatLng.latitude,
            pickupLongitude: _pickupLatLng.longitude,
            dropoffAddress: _dropoffLocationController.text.trim(),
            dropoffLatitude: _dropoffLatLng?.latitude,
            dropoffLongitude: _dropoffLatLng?.longitude,
            parcelType: _selectedParcelType,
            size: _selectedSize,
            notes: notes,
            price: _totalPrice,
          ),
        );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider<ParcelBloc>(
      create: (_) => di.sl<ParcelBloc>(),
      child: BlocConsumer<ParcelBloc, ParcelState>(
        listener: (context, state) {
          if (state is ParcelSubmittedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: AppColors.success,
                content: Text(
                  'تم إرسال طلب الطرد بنجاح!',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                ),
              ),
            );
            context.go(LaffahRoutes.passengerParcelConfirm, extra: state.parcel);
          } else if (state is ParcelError) {

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.error,
                content: Text(
                  state.message,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            );
          }
        },

        builder: (context, state) {
          final isLoading = state is ParcelLoading;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              appBar: AppBar(
                title: const Text(
                  'إرسال طرد فوري',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
                elevation: 0,
                backgroundColor: isDark
                    ? AppColors.surfaceDark
                    : AppColors.white,
                foregroundColor:
                    isDark ? AppColors.white : AppColors.gray900,
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s20,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Info Banner
                          _buildInfoBanner(isDark),
                          AppSpacing.h20,

                          // 1. Sender Info Card
                          _buildSectionHeader('1. بيانات المرسل', Icons.person_pin_rounded),
                          AppSpacing.h8,
                          ParcelSenderCard(
                            isDark: isDark,
                            nameController: _senderNameController,
                            phoneController: _senderPhoneController,
                          ),
                          AppSpacing.h20,

                          // 2. Recipient Info Card
                          _buildSectionHeader('2. بيانات المستلم', Icons.person_add_alt_1_rounded),
                          AppSpacing.h8,
                          ParcelRecipientCard(
                            isDark: isDark,
                            nameController: _receiverNameController,
                            phoneController: _receiverPhoneController,
                          ),
                          AppSpacing.h20,

                          // 3. Locations Card
                          _buildSectionHeader('3. مسار التوصيل', Icons.alt_route_rounded),
                          AppSpacing.h8,
                          _buildLocationPickerCard(isDark),
                          AppSpacing.h20,

                          // 4. Parcel Details
                          _buildSectionHeader('4. مواصفات الطرد', Icons.inventory_2_rounded),
                          AppSpacing.h8,
                          _buildSizeSelector(isDark),
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
                            estimatedValueController:
                                _estimatedValueController,
                            notesController: _notesController,
                          ),
                          AppSpacing.h20,

                          // 5. Insurance Option
                          _buildSectionHeader('5. خيارات الأمان', Icons.security_rounded),
                          AppSpacing.h8,
                          ParcelInsuranceCard(
                            isDark: isDark,
                            isInsuranceEnabled: _isInsuranceEnabled,
                            onChanged: (val) {
                              setState(() => _isInsuranceEnabled = val);
                            },
                          ),
                          AppSpacing.h20,

                          // 6. Pricing Summary & Submit
                          _buildSectionHeader('6. ملخص التكلفة والتأكيد', Icons.receipt_long_rounded),
                          AppSpacing.h8,
                          ParcelPriceSummaryCard(
                            isDark: isDark,
                            baseFee: _baseFee,
                            isInsuranceEnabled: _isInsuranceEnabled,
                            insuranceFee: _insuranceFee,
                            totalPrice: _totalPrice,
                            onSubmit: () => _handleSubmit(context),
                          ),
                          AppSpacing.h32,
                        ],
                      ),
                    ),
                  ),

                  if (isLoading)
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: Card(
                          color: AppColors.surfaceDark,
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.s24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary500),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'جاري إرسال طلب الطرد...',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: AppColors.primary500.withValues(alpha: 0.12),
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: AppColors.primary500.withValues(alpha: 0.3),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.electric_moped_rounded,
            color: AppColors.primary500,
            size: 28,
          ),
          SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خدمة توصيل الطرود السريعة عبر لَفَّة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: AppColors.primary500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'توصيل موثوق من الباب إلى الباب بأسرع وقت وأفضل سعر في صنعاء.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary500),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: AppColors.primary500,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationPickerCard(bool isDark) {
    return GlassBox(
      borderRadius: AppSpacing.radiusMD,
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        children: [
          InkWell(
            onTap: () => _pickLocation(true),
            borderRadius: AppSpacing.radiusSM,
            child: IgnorePointer(
              child: TextFormField(
                controller: _pickupLocationController,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
                decoration: InputDecoration(
                  labelText: 'موقع الاستلام (نقطة البداية)',
                  hintText: 'حدد موقع استلام الطرد',
                  prefixIcon: const Icon(Icons.my_location_rounded, color: AppColors.primary500),
                  suffixIcon: const Icon(Icons.search_rounded, color: AppColors.primary500),
                  filled: true,
                  fillColor: isDark ? const Color(0x08FFFFFF) : AppColors.gray50,
                  border: const OutlineInputBorder(borderRadius: AppSpacing.radiusSM),
                ),
              ),
            ),
          ),
          AppSpacing.h16,
          InkWell(
            onTap: () => _pickLocation(false),
            borderRadius: AppSpacing.radiusSM,
            child: IgnorePointer(
              child: TextFormField(
                controller: _dropoffLocationController,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
                decoration: InputDecoration(
                  labelText: 'موقع التسليم (الوجهة)',
                  hintText: 'إلى أين تريد إرسال الطرد؟',
                  prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.error),
                  suffixIcon: const Icon(Icons.search_rounded, color: AppColors.primary500),
                  filled: true,
                  fillColor: isDark ? const Color(0x08FFFFFF) : AppColors.gray50,
                  border: const OutlineInputBorder(borderRadius: AppSpacing.radiusSM),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildSizeSelector(bool isDark) {
    final sizes = [
      {'key': 'صغير', 'label': 'صغير (مستندات/مفاتيح)', 'icon': Icons.mail_outline_rounded},
      {'key': 'متوسط', 'label': 'متوسط (حقيبة/ملابس)', 'icon': Icons.inventory_2_outlined},
      {'key': 'كبير', 'label': 'كبير (صندوق/أجهزة)', 'icon': Icons.all_inbox_rounded},
    ];

    return GlassBox(
      borderRadius: AppSpacing.radiusMD,
      padding: const EdgeInsets.all(AppSpacing.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'حجم الشحنة:',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: sizes.map((s) {
              final isSelected = _selectedSize == s['key'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedSize = s['key'] as String);
                    },
                    borderRadius: AppSpacing.radiusSM,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary500
                            : (isDark ? Colors.white10 : AppColors.gray100),
                        borderRadius: AppSpacing.radiusSM,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary500
                              : (isDark ? Colors.white12 : AppColors.gray300),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            s['icon'] as IconData,
                            size: 20,
                            color: isSelected ? Colors.white : AppColors.gray500,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s['key'] as String,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.white : AppColors.gray900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

