import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/glass_box.dart';
import '../../../domain/entities/saved_place_entity.dart';
import '../../../data/models/saved_place_model.dart';

/// AddEditPlaceDialog — Modal form dialog for creating or editing saved places.
class AddEditPlaceDialog extends StatefulWidget {
  final bool isDark;
  final SavedPlaceEntity? placeToEdit;
  final ValueChanged<SavedPlaceModel> onSave;

  const AddEditPlaceDialog({
    super.key,
    required this.isDark,
    this.placeToEdit,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required bool isDark,
    SavedPlaceEntity? placeToEdit,
    required ValueChanged<SavedPlaceModel> onSave,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AddEditPlaceDialog(
        isDark: isDark,
        placeToEdit: placeToEdit,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddEditPlaceDialog> createState() => _AddEditPlaceDialogState();
}

class _AddEditPlaceDialogState extends State<AddEditPlaceDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.placeToEdit?.name ?? '');
    _addressController =
        TextEditingController(text: widget.placeToEdit?.address ?? '');
    _selectedType = widget.placeToEdit?.type ?? 'custom';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newPlace = SavedPlaceModel(
        id: widget.placeToEdit?.id ??
            'place_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        lat: widget.placeToEdit?.lat ?? 15.3694,
        lng: widget.placeToEdit?.lng ?? 44.1910,
        type: _selectedType,
      );

      widget.onSave(newPlace);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.placeToEdit != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: GlassBox(
          borderRadius: AppSpacing.radiusLG,
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'تعديل مكان محفوظ' : 'إضافة مكان جديد',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: widget.isDark
                              ? AppColors.white
                              : AppColors.gray900,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  AppSpacing.h16,

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 13,
                      color:
                          widget.isDark ? AppColors.white : AppColors.gray900,
                    ),
                    decoration: InputDecoration(
                      labelText: 'اسم المكان (مثال: البيت / العمل)',
                      prefixIcon: const Icon(Icons.label_outlined,
                          color: AppColors.primary500, size: 18),
                      filled: true,
                      fillColor: widget.isDark
                          ? AppColors.white.withValues(alpha: 0.03)
                          : AppColors.gray50,
                      contentPadding: const EdgeInsets.all(AppSpacing.s12),
                      border: const OutlineInputBorder(
                          borderRadius: AppSpacing.radiusSM),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'يرجى إدخال اسم المكان';
                      }
                      return null;
                    },
                  ),

                  AppSpacing.h12,

                  // Address Field
                  TextFormField(
                    controller: _addressController,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 13,
                      color:
                          widget.isDark ? AppColors.white : AppColors.gray900,
                    ),
                    decoration: InputDecoration(
                      labelText: 'تفاصيل العنوان / الشارع',
                      prefixIcon: const Icon(Icons.place_outlined,
                          color: AppColors.primary500, size: 18),
                      filled: true,
                      fillColor: widget.isDark
                          ? AppColors.white.withValues(alpha: 0.03)
                          : AppColors.gray50,
                      contentPadding: const EdgeInsets.all(AppSpacing.s12),
                      border: const OutlineInputBorder(
                          borderRadius: AppSpacing.radiusSM),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'يرجى إدخال تفاصيل العنوان';
                      }
                      return null;
                    },
                  ),

                  AppSpacing.h16,

                  // Type Selector
                  const Text(
                    'نوع المكان التصنيفي:',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.gray500,
                    ),
                  ),
                  AppSpacing.h8,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTypeChip('منزل', 'home'),
                      _buildTypeChip('عمل', 'work'),
                      _buildTypeChip('جامعة', 'university'),
                      _buildTypeChip('تسوق', 'shopping'),
                      _buildTypeChip('تاريخي', 'historic'),
                      _buildTypeChip('مخصص', 'custom'),
                    ],
                  ),

                  AppSpacing.h20,

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.borderMD,
                        ),
                      ),
                      child: Text(
                        isEdit ? 'حفظ التعديلات' : 'إضافة المكان الآن',
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String type) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? AppColors.white
              : (widget.isDark ? AppColors.gray300 : AppColors.gray700),
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary500,
      backgroundColor: widget.isDark
          ? AppColors.white.withValues(alpha: 0.05)
          : AppColors.gray100,
      onSelected: (val) {
        if (val) {
          setState(() => _selectedType = type);
        }
      },
    );
  }
}
