import '../../../../../l10n/app_localizations.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/laffah_glass_snackbar.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../../profile/presentation/bloc/profile_event.dart';
import '../../../../profile/presentation/widgets/faq_bottom_sheet.dart';
import '../../../../profile/presentation/pages/legal/terms_of_service_page.dart';
import '../../../../profile/presentation/pages/legal/privacy_policy_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// Base custom glassmorphic bottom sheet wrapper for unified design aesthetics
Widget _buildGlassSheetWrapper({
  required BuildContext context,
  required Widget child,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

  return Directionality(
    textDirection: TextDirection.rtl,
    child: AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutQuad,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141822).withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.96),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: AppColors.primary500.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 44,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    AppSpacing.h20,
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// 1. Edit Profile Modal Sheet
class EditProfileSheet extends StatefulWidget {
  final String currentName;
  final String currentPhone;
  final Function(String name, String phone) onSave;

  const EditProfileSheet({
    super.key,
    required this.currentName,
    required this.currentPhone,
    required this.onSave,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.capt_edit_profile,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h20,
          // Full Name
          _buildTextFieldLabel(AppLocalizations.of(context)!.capt_full_name),
          _buildInputField(
            controller: _nameController,
            hint: AppLocalizations.of(context)!.capt_enter_name_3,
            icon: Icons.person_outline_rounded,
            isDark: isDark,
          ),
          AppSpacing.h16,
          // Phone Number
          _buildTextFieldLabel(
              AppLocalizations.of(context)!.capt_mobile_number),
          _buildInputField(
            controller: _phoneController,
            hint: '77XXXXXXX',
            icon: Icons.phone_android_rounded,
            isDark: isDark,
            keyboardType: TextInputType.phone,
          ),
          AppSpacing.h24,
          // Save Button
          ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
              widget.onSave(_nameController.text, _phoneController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              AppLocalizations.of(context)!.capt_save_changes,
              style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 14),
            ),
          ),
          AppSpacing.h16,
        ],
      ),
    );
  }
}

/// 2. Vehicle Details Modal Sheet
class VehicleDetailsSheet extends StatefulWidget {
  final Map<String, String> vehicleInfo;
  final bool isVerified;
  final Function(String type, String model, String plate, String color)? onSave;

  const VehicleDetailsSheet({
    super.key,
    required this.vehicleInfo,
    this.isVerified = false,
    this.onSave,
  });

  @override
  State<VehicleDetailsSheet> createState() => _VehicleDetailsSheetState();
}

class _VehicleDetailsSheetState extends State<VehicleDetailsSheet> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _typeController;
  late TextEditingController _modelController;
  late TextEditingController _plateController;
  late TextEditingController _colorController;

  @override
  void initState() {
    super.initState();
    final type = widget.vehicleInfo['type'];
    final model = widget.vehicleInfo['model'];
    final plate = widget.vehicleInfo['plate'];
    final color = widget.vehicleInfo['color'];

    _typeController = TextEditingController(text: (type != null && type != 'غير محدد') ? type : '');
    _modelController = TextEditingController(text: (model != null && model != 'غير محدد') ? model : '');
    _plateController = TextEditingController(text: (plate != null && plate != 'غير محدد') ? plate : '');
    _colorController = TextEditingController(text: (color != null && color != 'غير محدد') ? color : '');
  }

  @override
  void dispose() {
    _typeController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final type = _typeController.text.trim();
    final model = _modelController.text.trim();
    final plate = _plateController.text.trim();
    final color = _colorController.text.trim();

    if (type.isEmpty && model.isEmpty && plate.isEmpty && color.isEmpty) {
      LaffahSnackBar.error(context, 'يرجى إدخال بيانات المركبة لحفظها.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    if (widget.onSave != null) {
      widget.onSave!(type, model, plate, color);
    } else {
      // Direct bloc fallback
      final profileBloc = context.read<ProfileBloc>();
      final currentProfile = profileBloc.cachedProfile;
      profileBloc.add(UpdateProfileEvent(
        name: currentProfile?.name ?? 'الكابتن',
        phone: currentProfile?.phone,
        email: currentProfile?.email,
        vehicleType: type.isNotEmpty ? type : currentProfile?.vehicleType,
        vehicleModel: model.isNotEmpty ? model : currentProfile?.vehicleModel,
        plateNumber: plate.isNotEmpty ? plate : currentProfile?.plateNumber,
        vehicleColor: color.isNotEmpty ? color : currentProfile?.vehicleColor,
      ));
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _isEditing = false;
    });

    LaffahSnackBar.success(context, 'تم تحديث بيانات المركبة بنجاح في النظام');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayType = _typeController.text.isNotEmpty
        ? _typeController.text
        : (widget.vehicleInfo['type'] ?? 'غير محدد');
    final displayModel = _modelController.text.isNotEmpty
        ? _modelController.text
        : (widget.vehicleInfo['model'] ?? 'غير محدد');
    final displayPlate = _plateController.text.isNotEmpty
        ? _plateController.text
        : (widget.vehicleInfo['plate'] ?? 'غير محدد');
    final displayColor = _colorController.text.isNotEmpty
        ? _colorController.text
        : (widget.vehicleInfo['color'] ?? 'غير محدد');

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.two_wheeler_rounded,
                      color: AppColors.primary500,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.capt_bike_data,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                ],
              ),
              if (!_isEditing)
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  tooltip: 'تعديل البيانات',
                  icon: const Icon(Icons.edit_note_rounded,
                      color: AppColors.primary500, size: 24),
                ),
            ],
          ),
          AppSpacing.h16,

          if (_isEditing) ...[
            // Editable Form Mode
            _buildTextFieldLabel('نوع المركبة / الدراجة النارية'),
            _buildInputField(
              controller: _typeController,
              hint: 'مثال: دراجة نارية، دباب، سيارة...',
              icon: Icons.two_wheeler_rounded,
              isDark: isDark,
            ),
            AppSpacing.h12,

            _buildTextFieldLabel('الموديل وسنة الصنع'),
            _buildInputField(
              controller: _modelController,
              hint: 'مثال: دايون 150 - 2023',
              icon: Icons.calendar_today_rounded,
              isDark: isDark,
            ),
            AppSpacing.h12,

            _buildTextFieldLabel('رقم لوحة الأرقام الرسمية'),
            _buildInputField(
              controller: _plateController,
              hint: 'مثال: 1/ص 48291',
              icon: Icons.pin_rounded,
              isDark: isDark,
            ),
            AppSpacing.h12,

            _buildTextFieldLabel('لون المركبة'),
            _buildInputField(
              controller: _colorController,
              hint: 'مثال: أسود، أحمر، فضي...',
              icon: Icons.palette_outlined,
              isDark: isDark,
            ),
            AppSpacing.h20,

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'حفظ التعديلات',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                AppSpacing.w12,
                OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          setState(() {
                            _isEditing = false;
                          });
                        },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gray400),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: AppColors.gray500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // View Mode
            _buildInfoRow(AppLocalizations.of(context)!.capt_bike_type,
                displayType, isDark),
            _buildInfoRow(AppLocalizations.of(context)!.capt_model_year,
                displayModel, isDark),
            _buildInfoRow(AppLocalizations.of(context)!.capt_plate_num,
                displayPlate, isDark),
            _buildInfoRow('لون المركبة', displayColor, isDark),
            _buildInfoRow(
              AppLocalizations.of(context)!.capt_periodic_inspection,
              widget.isVerified ? 'سليم وموثق رسمياً' : 'بانتظار تدقيق التوثيق',
              isDark,
              color: widget.isVerified ? AppColors.success : AppColors.warning,
            ),
            AppSpacing.h20,

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text(
                      'تعديل بيانات المركبة',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                AppSpacing.w12,
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary500),
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: AppColors.primary500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
          AppSpacing.h16,
        ],
      ),
    );
  }
}

/// 3. Official Documents Modal Sheet
class _OfficialDocItem {
  final String key;
  final String name;
  final String description;
  final IconData icon;
  int? backendId;
  String status = 'empty'; // 'empty', 'pending', 'approved', 'rejected'
  String? rejectionReason;
  String? fileUrl;
  String? localPath;
  DateTime? updatedAt;

  _OfficialDocItem({
    required this.key,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class OfficialDocumentsSheet extends StatefulWidget {
  const OfficialDocumentsSheet({super.key});

  @override
  State<OfficialDocumentsSheet> createState() => _OfficialDocumentsSheetState();
}

class _OfficialDocumentsSheetState extends State<OfficialDocumentsSheet> {
  bool _isLoading = true;
  bool _isVerified = false;
  String? _uploadingKey;

  late List<_OfficialDocItem> _documents;

  @override
  void initState() {
    super.initState();
    _initializeDocuments();
    _fetchDocuments();
  }

  void _initializeDocuments() {
    _documents = [
      _OfficialDocItem(
        key: 'id_card',
        name: 'البطاقة الشخصية اليمنية (الهوية الوطنية)',
        description: 'صورة واضحة للوجهين الأمامي والخلفي للبطاقة الشخصية الذكية أو جواز السفر الساري.',
        icon: Icons.badge_outlined,
      ),
      _OfficialDocItem(
        key: 'bike_license',
        name: 'كرت ملكية الدراجة النارية / المركبة',
        description: 'صورة واضحة لكرت ملكية الدراجة أو وثيقة التمليك الرسمية للمركبة.',
        icon: Icons.two_wheeler_rounded,
      ),
      _OfficialDocItem(
        key: 'driving_license',
        name: 'رخصة قيادة دراجة نارية / رخصة القيادة',
        description: 'رخصة قيادة سارية المفعول صادرة من الإدارة العامة للمرور في الجمهورية اليمنية.',
        icon: Icons.card_membership_rounded,
      ),
      _OfficialDocItem(
        key: 'inspection',
        name: 'شهادة الفحص الدوري الفني',
        description: 'شهادة الفحص الفني المعتمدة لسلامة المركبة أو السجل الدوري.',
        icon: Icons.fact_check_outlined,
      ),
    ];
  }

  Future<void> _fetchDocuments() async {
    try {
      final dio = sl<DioClient>().dio;
      final response = await dio.get(ApiEndpoints.captainDocuments);

      if (response.data != null && response.data['status'] == 'success') {
        final data = response.data['data'];
        final bool verified = data['is_verified'] == true;
        final List docsList = (data['documents'] as List?) ?? [];

        if (mounted) {
          setState(() {
            _isVerified = verified;
            for (var docItem in _documents) {
              final match = docsList.firstWhere(
                (d) {
                  final type = d['type']?.toString();
                  if (docItem.key == 'id_card') {
                    return type == 'id_card' || type == 'identity';
                  }
                  if (docItem.key == 'bike_license') {
                    return type == 'bike_license' ||
                        type == 'vehicle_card' ||
                        type == 'vehicle_ownership' ||
                        type == 'vehicle_registration';
                  }
                  if (docItem.key == 'driving_license') {
                    return type == 'driving_license' ||
                        type == 'drivers_license' ||
                        type == 'license';
                  }
                  if (docItem.key == 'inspection') {
                    return type == 'inspection' || type == 'criminal_record';
                  }
                  return type == docItem.key;
                },
                orElse: () => null,
              );

              if (match != null) {
                docItem.backendId = match['id'];
                docItem.status = match['status']?.toString() ?? 'pending';
                docItem.rejectionReason = match['rejection_reason']?.toString();
                docItem.fileUrl = match['file_url']?.toString();
                if (match['updated_at'] != null) {
                  docItem.updatedAt = DateTime.tryParse(match['updated_at'].toString());
                }
              }
            }
            _isLoading = false;
          });
        }
        return;
      }
    } catch (_) {
      // Offline fallback
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage(_OfficialDocItem doc, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (pickedFile == null) return;

      setState(() {
        _uploadingKey = doc.key;
      });

      final dio = sl<DioClient>().dio;
      final formData = FormData.fromMap({
        'document_type': doc.key,
        'type': doc.key,
        'file': await MultipartFile.fromFile(
          pickedFile.path,
          filename: pickedFile.name.isNotEmpty ? pickedFile.name : '${doc.key}.jpg',
        ),
      });

      final response = await dio.post(
        ApiEndpoints.captainDocuments,
        data: formData,
      );

      if (response.data != null &&
          (response.data['status'] == 'success' || response.statusCode == 200)) {
        doc.localPath = pickedFile.path;
        doc.status = 'pending';
        doc.rejectionReason = null;
        if (response.data['data'] != null && response.data['data']['file_url'] != null) {
          doc.fileUrl = response.data['data']['file_url'];
        }

        if (mounted) {
          LaffahSnackBar.success(
            context,
            'تم رفع وثيقة (${doc.name}) بنجاح وهي قيد التدقيق والمراجعة.',
          );
          // Sync captain profile so main account screen badge updates
          context.read<ProfileBloc>().add(GetProfileEvent());
        }
      } else {
        if (mounted) {
          LaffahSnackBar.error(
            context,
            response.data?['message']?.toString() ?? 'تعذر رفع الوثيقة، يرجى المحاولة لاحقاً',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        LaffahSnackBar.error(context, 'فشل رفع الوثيقة: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploadingKey = null;
        });
        _fetchDocuments();
      }
    }
  }

  void _showDocumentPreview(_OfficialDocItem doc, bool isDark) {
    HapticFeedback.lightImpact();

    if (doc.status == 'empty') {
      LaffahSnackBar.info(
        context,
        'لم يتم رفع هذه الوثيقة بعد. يرجى الضغط على "رفع الوثيقة" لإرفاقها.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF141822) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(doc.icon, color: AppColors.primary500, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  doc.name,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                    color: isDark ? Colors.white : AppColors.gray900,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.gray100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.gray200,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: doc.localPath != null
                      ? Image.file(
                          File(doc.localPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderPreview(doc),
                        )
                      : (doc.fileUrl != null
                          ? FutureBuilder<Response<List<int>>>(
                              future: sl<DioClient>().dio.get<List<int>>(
                                    doc.fileUrl!,
                                    options: Options(responseType: ResponseType.bytes),
                                  ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(AppColors.primary500),
                                    ),
                                  );
                                }
                                if (snapshot.hasData && snapshot.data?.data != null) {
                                  return Image.memory(
                                    Uint8List.fromList(snapshot.data!.data!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildPlaceholderPreview(doc),
                                  );
                                }
                                return _buildPlaceholderPreview(doc);
                              },
                            )
                          : _buildPlaceholderPreview(doc)),
                ),
              ),
              AppSpacing.h16,
              _buildModalDetailRow(
                'حالة الوثيقة:',
                doc.status == 'approved'
                    ? 'معتمد وموثق'
                    : (doc.status == 'pending' ? 'قيد المراجعة والتدقيق' : 'مرفوض - يتطلب تعديل'),
                isDark,
                valueColor: doc.status == 'approved'
                    ? AppColors.success
                    : (doc.status == 'pending' ? AppColors.warning : AppColors.danger),
              ),
              if (doc.rejectionReason != null && doc.rejectionReason!.isNotEmpty) ...[
                AppSpacing.h8,
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    'سبب الرفض: ${doc.rejectionReason}',
                    style: const TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showUploadOption(doc);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary500),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'إعادة رفع الوثيقة',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'إغلاق',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderPreview(_OfficialDocItem doc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            doc.status == 'approved' ? Icons.verified_user_rounded : Icons.file_present_rounded,
            size: 42,
            color: doc.status == 'approved' ? AppColors.success : AppColors.primary500,
          ),
          const SizedBox(height: 8),
          Text(
            doc.status == 'approved' ? 'وثيقة رسمية معتمدة ومطابقة للمعايير' : 'تم استلام الملف بنجاح',
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalDetailRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            color: AppColors.gray500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isDark ? Colors.white : AppColors.gray900),
          ),
        ),
      ],
    );
  }

  void _showUploadOption(_OfficialDocItem doc) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141822) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                AppSpacing.h16,
                Text(
                  'رفع أو تحديث ${doc.name}',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h8,
                const Text(
                  'يرجى التأكد من وضوح الصورة وتطابق البيانات مع الهوية الرسمية.',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11.5,
                    color: AppColors.gray500,
                  ),
                ),
                AppSpacing.h16,
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary500),
                  ),
                  title: const Text('التقاط صورة عبر الكاميرا',
                      style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickAndUploadImage(doc, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.primary500),
                  ),
                  title: const Text('اختيار ملف من المعرض',
                      style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickAndUploadImage(doc, ImageSource.gallery);
                  },
                ),
                AppSpacing.h12,
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate real header badge state
    final hasRejected = _documents.any((d) => d.status == 'rejected');
    final hasPending = _documents.any((d) => d.status == 'pending');
    final isAllApproved = _documents.every((d) => d.status == 'approved');

    Color headerBadgeColor;
    String headerBadgeText;
    IconData headerBadgeIcon;

    if (_isVerified || isAllApproved) {
      headerBadgeColor = AppColors.success;
      headerBadgeText = 'مكتملة وموثقة';
      headerBadgeIcon = Icons.check_circle_rounded;
    } else if (hasRejected) {
      headerBadgeColor = AppColors.danger;
      headerBadgeText = 'وثائق تتطلب تعديل';
      headerBadgeIcon = Icons.error_outline_rounded;
    } else if (hasPending) {
      headerBadgeColor = AppColors.warning;
      headerBadgeText = 'قيد المراجعة والتدقيق';
      headerBadgeIcon = Icons.hourglass_top_rounded;
    } else {
      headerBadgeColor = AppColors.gray500;
      headerBadgeText = 'غير مكتملة';
      headerBadgeIcon = Icons.pending_actions_rounded;
    }

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.folder_shared_rounded,
                      color: AppColors.primary500,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'الوثائق والأوراق الرسمية',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: headerBadgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: headerBadgeColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(headerBadgeIcon, color: headerBadgeColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      headerBadgeText,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: headerBadgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.h8,
          const Text(
            'جميع وثائق اعتماد كابتن لَفَّة الرسمية وفق اشتراطات السلامة واللوائح في الجمهورية اليمنية.',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 11.5,
              color: AppColors.gray500,
              height: 1.4,
            ),
          ),
          AppSpacing.h16,
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary500),
                ),
              ),
            )
          else ...[
            ..._documents.map((doc) => _buildDocumentCard(doc, isDark)),
          ],
          AppSpacing.h20,
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'حسناً، فهمت',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          AppSpacing.h16,
        ],
      ),
    );
  }

  Widget _buildDocumentCard(_OfficialDocItem doc, bool isDark) {
    final isUploadingThis = _uploadingKey == doc.key;

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (doc.status) {
      case 'approved':
        statusColor = AppColors.success;
        statusLabel = 'معتمد وموثق';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'pending':
        statusColor = AppColors.warning;
        statusLabel = 'قيد المراجعة والتدقيق';
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case 'rejected':
        statusColor = AppColors.danger;
        statusLabel = 'مرفوض - يتطلب تعديل';
        statusIcon = Icons.error_outline_rounded;
        break;
      default:
        statusColor = AppColors.gray500;
        statusLabel = 'لم يتم الرفع بعد';
        statusIcon = Icons.cloud_upload_outlined;
        break;
    }

    final bool isUploaded = doc.status != 'empty';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: doc.status == 'rejected'
              ? AppColors.danger.withValues(alpha: 0.3)
              : (isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.gray200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUploaded
                      ? statusColor.withValues(alpha: 0.12)
                      : AppColors.primary500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  doc.icon,
                  color: isUploaded ? statusColor : AppColors.primary500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.name,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doc.description,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 10.5,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (doc.rejectionReason != null && doc.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
              ),
              child: Text(
                'ملاحظة الرفض من الإدارة: ${doc.rejectionReason}',
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.danger,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          if (isUploadingThis)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary500),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'جاري رفع الوثيقة وتشفيرها...',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: isUploaded ? () => _showDocumentPreview(doc, isDark) : null,
                    icon: Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: isUploaded ? AppColors.primary500 : AppColors.gray400,
                    ),
                    label: Text(
                      'عرض الوثيقة',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isUploaded ? AppColors.primary500 : AppColors.gray400,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
                Container(width: 1, height: 18, color: AppColors.gray300),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showUploadOption(doc),
                    icon: Icon(
                      isUploaded ? Icons.file_upload_outlined : Icons.cloud_upload_rounded,
                      size: 16,
                      color: isUploaded
                          ? (isDark ? AppColors.gray300 : AppColors.gray700)
                          : AppColors.primary500,
                    ),
                    label: Text(
                      isUploaded ? 'تحديث / تعديل' : 'رفع الوثيقة',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: isUploaded
                            ? (isDark ? AppColors.gray300 : AppColors.gray700)
                            : AppColors.primary500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// 4. Change Password Modal Sheet
class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تغيير كلمة المرور',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h16,
          _buildTextFieldLabel(
              AppLocalizations.of(context)!.capt_current_password),
          _buildInputField(
              controller: _oldController,
              hint: AppLocalizations.of(context)!.capt_enter_current_pass,
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              obscureText: true),
          AppSpacing.h12,
          _buildTextFieldLabel('كلمة المرور الجديدة'),
          _buildInputField(
              controller: _newController,
              hint: AppLocalizations.of(context)!.capt_enter_new_pass,
              icon: Icons.lock_open_rounded,
              isDark: isDark,
              obscureText: true),
          AppSpacing.h12,
          _buildTextFieldLabel(
              AppLocalizations.of(context)!.capt_confirm_new_pass),
          _buildInputField(
              controller: _confirmController,
              hint: AppLocalizations.of(context)!.capt_reenter_new_pass,
              icon: Icons.verified_user_outlined,
              isDark: isDark,
              obscureText: true),
          AppSpacing.h24,
          ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.success,
                  content: Text(
                    AppLocalizations.of(context)!.capt_pass_updated_success,
                    style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              AppLocalizations.of(context)!.capt_confirm_change_now,
              style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900),
            ),
          ),
          AppSpacing.h16,
        ],
      ),
    );
  }
}

/// 5. Help Center Modal Sheet
class HelpCenterSheet extends StatelessWidget {
  const HelpCenterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.capt_help_center,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h16,
          _buildHelpCard(
              AppLocalizations.of(context)!.capt_ways_increase_income,
              AppLocalizations.of(context)!.capt_increase_income_desc,
              isDark),
          _buildHelpCard(AppLocalizations.of(context)!.capt_guide_parcels,
              AppLocalizations.of(context)!.capt_guide_parcels_desc, isDark),
          _buildHelpCard(AppLocalizations.of(context)!.capt_safety_rules,
              AppLocalizations.of(context)!.capt_safety_rules_desc, isDark),
          AppSpacing.h24,
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary500),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(AppLocalizations.of(context)!.capt_understood,
                style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: AppColors.primary500,
                    fontWeight: FontWeight.bold)),
          ),
          AppSpacing.h16,
        ],
      ),
    );
  }

  Widget _buildHelpCard(String title, String body, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 11,
              color: AppColors.gray500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// 6. FAQ Modal Sheet
class FAQSheet extends StatelessWidget {
  const FAQSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const LaffahFaqBottomSheet(initialCategory: 'captain');
  }
}

/// 7. Direct Support Modal Sheet
class DirectSupportSheet extends StatelessWidget {
  const DirectSupportSheet({super.key});

  static const String _supportPhone = '770291452';
  static const String _fullPhone = '+967770291452';
  static const String _supportEmail = 'support@laffah.com';

  Future<void> _launchOrCopy(
    BuildContext context, {
    required String urlString,
    required String fallbackCopyText,
    required String fallbackMessage,
  }) async {
    Navigator.pop(context);
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await Clipboard.setData(ClipboardData(text: fallbackCopyText));
        if (context.mounted) {
          LaffahSnackBar.info(context, fallbackMessage);
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: fallbackCopyText));
      if (context.mounted) {
        LaffahSnackBar.info(context, fallbackMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تواصل مع الدعم الفني للكباتن',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h8,
          const Text(
            'فريق دعم لَفَّة متاح لمساعدتك على مدار 24 ساعة في جميع مشاكل الرحلات، الحساب والمحفظة.',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              color: AppColors.gray500,
              height: 1.4,
            ),
          ),
          AppSpacing.h16,
          // Phone Support
          _buildContactButton(
            isDark: isDark,
            label: 'اتصال هاتفي مباشر ($_supportPhone)',
            icon: Icons.phone_in_talk_rounded,
            color: AppColors.primary500,
            onTap: () => _launchOrCopy(
              context,
              urlString: 'tel:$_fullPhone',
              fallbackCopyText: _supportPhone,
              fallbackMessage: 'تم نسخ رقم الهاتف للحافظة: $_supportPhone',
            ),
          ),
          AppSpacing.h10,
          // WhatsApp Support
          _buildContactButton(
            isDark: isDark,
            label: 'محادثة واتساب سريعة',
            icon: Icons.chat_rounded,
            color: const Color(0xFF25D366),
            onTap: () => _launchOrCopy(
              context,
              urlString: 'https://wa.me/967$_supportPhone',
              fallbackCopyText: _supportPhone,
              fallbackMessage: 'تم نسخ رقم الواتساب للحافظة: $_supportPhone',
            ),
          ),
          AppSpacing.h10,
          // Email Support
          _buildContactButton(
            isDark: isDark,
            label: 'مراسلة عبر البريد الإلكتروني',
            icon: Icons.email_outlined,
            color: const Color(0xFF3B82F6),
            onTap: () => _launchOrCopy(
              context,
              urlString: 'mailto:$_supportEmail',
              fallbackCopyText: _supportEmail,
              fallbackMessage: 'تم نسخ البريد الإلكتروني للحافظة: $_supportEmail',
            ),
          ),
          AppSpacing.h24,
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required bool isDark,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 8. Terms and Privacy Modal Sheet
class TermsAndPrivacySheet extends StatelessWidget {
  final bool isPrivacy;

  const TermsAndPrivacySheet({super.key, required this.isPrivacy});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isPrivacy
                ? AppLocalizations.of(context)!.capt_privacy_policy
                : AppLocalizations.of(context)!.capt_terms_conditions,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h16,
          Text(
            isPrivacy
                ? AppLocalizations.of(context)!.capt_privacy_desc
                : AppLocalizations.of(context)!.capt_terms_desc,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              height: 1.5,
              color: isDark ? AppColors.gray300 : AppColors.gray800,
            ),
          ),
          AppSpacing.h24,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => isPrivacy
                            ? const PrivacyPolicyPage()
                            : const TermsOfServicePage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'قراءة الوثيقة الكاملة',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.capt_agree,
                    style: const TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.h16,
        ],
      ),
    );
  }
}

/// 9. Language Selector Modal Sheet
class LanguageSelectorSheet extends StatelessWidget {
  final String currentLang;
  final Function(String lang) onSelected;

  const LanguageSelectorSheet({
    super.key,
    required this.currentLang,
    required this.onSelected,
  });

  static void show({
    required BuildContext context,
    required String currentLang,
    required Function(String lang) onSelected,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSelectorSheet(
        currentLang: currentLang,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassSheetWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.capt_select_language,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          AppSpacing.h20,
          _buildLangOption(context,
              AppLocalizations.of(context)!.capt_arabic_ye, 'ar', isDark),
          _buildLangOption(context, 'English (🇬🇧 English)', 'en', isDark),
          AppSpacing.h16,
        ],
      ),
    );
  }

  Widget _buildLangOption(
      BuildContext context, String name, String code, bool isDark) {
    final isSelected = currentLang == code;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pop(context);
        onSelected(code);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary500.withValues(alpha: 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : AppColors.gray50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary500
                : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.gray200),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                fontSize: 13,
                color: isSelected
                    ? AppColors.primary500
                    : (isDark ? Colors.white : AppColors.gray900),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary500, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Helper Label widgets
Widget _buildTextFieldLabel(String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6, right: 4),
    child: Text(
      label,
      style: const TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.gray500,
      ),
    ),
  );
}

/// Helper Input Field
Widget _buildInputField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  required bool isDark,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.gray200),
    ),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.gray900,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hint,
        hintStyle: const TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            color: AppColors.gray500),
        icon: Icon(icon, color: AppColors.primary500, size: 18),
      ),
    ),
  );
}

/// Helper Row Info renderer
Widget _buildInfoRow(String label, String value, bool isDark, {Color? color}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.gray200),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12.5,
              color: AppColors.gray500,
              fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            color: color ?? (isDark ? Colors.white : AppColors.gray900),
          ),
        ),
      ],
    ),
  );
}
