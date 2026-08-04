import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/glass_box.dart';
import '../../../../ride/presentation/bloc/ride_bloc.dart';
import '../../../../ride/presentation/bloc/ride_event.dart';

/// ParcelDeliveryFormBottomSheet - Form for entering parcel sender/recipient details, size, and type.
class ParcelDeliveryFormBottomSheet extends StatefulWidget {
  const ParcelDeliveryFormBottomSheet({super.key});

  @override
  State<ParcelDeliveryFormBottomSheet> createState() => _ParcelDeliveryFormBottomSheetState();
}

class _ParcelDeliveryFormBottomSheetState extends State<ParcelDeliveryFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _senderNameController = TextEditingController(text: 'أنس جلال');
  final _senderPhoneController = TextEditingController(text: '777123456');
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _itemDescriptionController = TextEditingController();

  String _selectedParcelType = 'طرد / علبة هدايا';
  String _selectedSize = 'small';
  bool _photoAttached = false;

  final List<String> _parcelTypes = [
    'وثائق / أوراق شحن بضائع',
    'طرد / علبة هدايا',
    'أطعمة ومأكولات ساخنة',
    'أغراض شخصية أخرى'
  ];

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _notesController.dispose();
    _itemDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GlassBox(
        borderRadius: AppSpacing.radiusBottomSheet,
        customBgColor: isDark 
            ? const Color(0xFF111827).withOpacity(0.9) 
            : const Color(0xFFF9FAFB).withOpacity(0.9),
        padding: EdgeInsets.only(
          top: AppSpacing.s16,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s24,
          left: AppSpacing.s20,
          right: AppSpacing.s20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15),
                      borderRadius: AppSpacing.radiusXS,
                    ),
                  ),
                ),
                AppSpacing.h16,

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'طلب إرسال طرد سريع',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: isDark ? AppColors.white : AppColors.gray700,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.h16,

                _buildSectionHeader('بيانات المرسل (أنت)', Icons.person_pin_circle_rounded),
                AppSpacing.h12,

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _senderNameController,
                        label: 'الاسم الكامل للمرسل',
                        hint: 'اسمك بالكامل',
                        validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال اسمك' : null,
                      ),
                    ),
                    AppSpacing.w12,
                    Expanded(
                      child: _buildTextField(
                        controller: _senderPhoneController,
                        label: 'رقم هاتف المرسل',
                        hint: '77xxxxxxx',
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال رقم هاتفك' : null,
                      ),
                    ),
                  ],
                ),
                AppSpacing.h16,

                _buildSectionHeader('بيانات المستلم للجهة الأخرى', Icons.person_pin_rounded),
                AppSpacing.h12,

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _receiverNameController,
                        label: 'اسم المستلم الثلاثي',
                        hint: 'اسم الشخص المستلم للشحنة',
                        validator: (value) => value == null || value.isEmpty ? 'الرجاء إدخال اسم المستلم للضرورة' : null,
                      ),
                    ),
                    AppSpacing.w12,
                    Expanded(
                      child: _buildTextField(
                        controller: _receiverPhoneController,
                        label: 'رقم هاتف المستلم المحمول',
                        hint: '77xxxxxxx',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رقم المستلم لتوجيه الكابتن';
                          }
                          if (!RegExp(r'^(77|73|71|70)\d{7}$').hasMatch(value)) {
                            return 'أدخل رقم يمني صحيح من 9 خانات';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                AppSpacing.h16,

                _buildSectionHeader('تفاصيل وحجم ومحتوى الطرد', Icons.inventory_2_rounded),
                AppSpacing.h12,

                DropdownButtonFormField<String>(
                  value: _selectedParcelType,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                  decoration: _buildInputDecoration('نوع وتصنيف محتويات الطرد والمستندات', isDark),
                  dropdownColor: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
                  items: _parcelTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
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
                AppSpacing.h12,

                _buildTextField(
                  controller: _itemDescriptionController,
                  label: 'وصف مختصر محتويات الشحنة',
                  hint: 'مثال: ملف أوراق تخرج جامعة صنعاء، علبة هدايا عطرية، علاج طبي...',
                  validator: (value) => value == null || value.isEmpty ? 'الرجاء وصف محتويات الشحنة لسلامتها' : null,
                ),
                AppSpacing.h16,

                Text(
                  'حجم الطرد التقريبي وتسعيرته التقديرية:',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.gray300 : AppColors.gray700,
                  ),
                ),
                AppSpacing.h8,
                Row(
                  children: [
                    _buildSizeOption('small', 'صغير جداً', 'مستندات، مفاتيح، لابتوب', '1,500 ريال', isDark),
                    AppSpacing.w8,
                    _buildSizeOption('medium', 'متوسط', 'كرتونة صغيرة، حقيبة ملابس', '2,000 ريال', isDark),
                    AppSpacing.w8,
                    _buildSizeOption('large', 'كبير الحجم', 'أكياس تسوق، كرتون بضائع', '3,000 ريال', isDark),
                  ],
                ),
                AppSpacing.h16,

                GestureDetector(
                  onTap: () {
                    setState(() {
                      _photoAttached = !_photoAttached;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: _photoAttached ? AppColors.success : AppColors.primary500,
                        content: Text(
                          _photoAttached ? 'تم إرفاق صورة إثبات الطرد بنجاح!' : 'تم إزالة الصورة المرفقة للطرد.',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _photoAttached 
                          ? AppColors.success.withOpacity(0.08) 
                          : AppColors.primary500.withOpacity(0.05),
                      borderRadius: AppSpacing.radiusSM,
                      border: Border.all(
                        color: _photoAttached ? AppColors.success : AppColors.primary500.withOpacity(0.2),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _photoAttached ? Icons.check_circle_rounded : Icons.add_photo_alternate_rounded,
                          color: _photoAttached ? AppColors.success : AppColors.primary500,
                          size: 20,
                        ),
                        AppSpacing.w10,
                        Text(
                          _photoAttached ? 'تم إلغاء أو تغيير صورة الطرد المرفقة ✓' : 'إرفاق صورة إثبات الطرد (اختياري للكابتن)',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: _photoAttached ? AppColors.success : AppColors.primary500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppSpacing.h12,

                _buildTextField(
                  controller: _notesController,
                  label: 'ملاحظات وتوجيهات خاصة للكابتن (اختياري)',
                  hint: 'مثال: يرجى الاتصال بي عند الوصول لباب العمارة...',
                  maxLines: 2,
                ),
                AppSpacing.h24,

                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppSpacing.radiusMD,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary500.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final parcelData = ParcelData(
                          senderName: _senderNameController.text.trim(),
                          senderPhone: _senderPhoneController.text.trim(),
                          receiverName: _receiverNameController.text.trim(),
                          receiverPhone: _receiverPhoneController.text.trim(),
                          parcelType: _selectedParcelType,
                          size: _selectedSize,
                          notes: _notesController.text.trim(),
                        );

                        context.read<RideBloc>().add(SubmitParcelOrder(parcelData));
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.radiusMD,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'تقديم طلب التوصيل والبحث عن كابتن',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(width: AppSpacing.s8),
                        Icon(
                          Icons.local_shipping_rounded,
                          color: AppColors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary500, size: 18),
        AppSpacing.w8,
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            color: AppColors.primary500,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.white : AppColors.gray900,
      ),
      validator: validator,
      decoration: _buildInputDecoration(label, isDark).copyWith(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          color: isDark ? AppColors.gray500 : AppColors.gray400,
          fontSize: 12,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        color: isDark ? AppColors.gray400 : AppColors.gray600,
        fontSize: 12.5,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
      filled: true,
      fillColor: isDark ? AppColors.surfaceElevatedDark.withOpacity(0.5) : AppColors.gray100,
      border: OutlineInputBorder(
        borderRadius: AppSpacing.radiusSM,
        borderSide: BorderSide(color: isDark ? AppColors.white.withOpacity(0.08) : AppColors.gray300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.radiusSM,
        borderSide: BorderSide(color: isDark ? AppColors.white.withOpacity(0.08) : AppColors.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.radiusSM,
        borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.radiusSM,
        borderSide: const BorderSide(color: AppColors.danger, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.radiusSM,
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
    );
  }

  Widget _buildSizeOption(String value, String name, String desc, String price, bool isDark) {
    final isSelected = _selectedSize == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSize = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.s10),
          height: 104,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary500.withOpacity(0.08)
                : (isDark ? AppColors.white.withOpacity(0.01) : AppColors.white),
            borderRadius: AppSpacing.radiusSM,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary500
                  : (isDark ? AppColors.white.withOpacity(0.08) : AppColors.gray200),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? AppColors.primary500 : (isDark ? AppColors.white : AppColors.gray900),
                ),
              ),
              Text(
                desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 9.5,
                  height: 1.3,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.white : AppColors.gray850,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
