import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';

/// Enum representing the category of the incident / dispute ticket
enum IncidentCategory {
  lostItem,         // مفقودات في الدراجة/السيارة
  fareDispute,      // خلاف حول قيمة الأجرة المحتسبة
  safetyConcern,    // شكوى تتعلق بالسلامة أو السرعة الزائدة
  badBehavior,      // سوء سلوك أو معاملة غير لائقة من الكابتن
  appProblem,       // عطل تقني في التطبيق أو نظام تحديد المواقع
  other,            // أسباب وبلاغات أخرى
}

/// Model class representing a ticket submit confirmation
class DisputeTicket {
  final String ticketId;
  final IncidentCategory category;
  final String title;
  final String details;
  final String rideReference;
  final List<String> attachmentPaths;
  final DateTime submissionDate;
  final String status;

  DisputeTicket({
    required this.ticketId,
    required this.category,
    required this.title,
    required this.details,
    required this.rideReference,
    required this.attachmentPaths,
    required this.submissionDate,
    required this.status,
  });
}

/// ReportIncidentPage - Dedicated, robust workflow for passengers to lodge tickets,
/// lost item claims, safety complaints, or driver behavior reports with photo attachments.
/// Provides full RTL support, beautiful UI aesthetics, and precise input validation.
class ReportIncidentPage extends StatefulWidget {
  final String? preFilledRideId;
  final String? preFilledCaptainName;

  const ReportIncidentPage({
    super.key,
    this.preFilledRideId,
    this.preFilledCaptainName,
  });

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  
  IncidentCategory _selectedCategory = IncidentCategory.lostItem;
  final TextEditingController _rideReferenceController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();

  final List<String> _attachedPhotos = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.preFilledRideId != null) {
      _rideReferenceController.text = widget.preFilledRideId!;
    } else {
      _rideReferenceController.text = 'LFH-9284-SNA';
    }
    _contactPhoneController.text = '777123456'; // Default contact phone format
  }

  @override
  void dispose() {
    _rideReferenceController.dispose();
    _titleController.dispose();
    _detailsController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  String _getCategoryArabicName(IncidentCategory category) {
    switch (category) {
      case IncidentCategory.lostItem:
        return 'مفقودات وأغراض منسية في المشوار';
      case IncidentCategory.fareDispute:
        return 'خلاف أو مشكلة حول قيمة الأجرة المحسوبة';
      case IncidentCategory.safetyConcern:
        return 'شكوى تتعلق بالسلامة أو السرعة المفرطة';
      case IncidentCategory.badBehavior:
        return 'تقرير سلوك غير لائق أو معاملة غير محترمة';
      case IncidentCategory.appProblem:
        return 'خلل تقني أو مشكلة تحديد المواقع في التطبيق';
      case IncidentCategory.other:
        return 'بلاغ أو شكوى أخرى مخصصة';
    }
  }

  IconData _getCategoryIcon(IncidentCategory category) {
    switch (category) {
      case IncidentCategory.lostItem:
        return Icons.shopping_bag_rounded;
      case IncidentCategory.fareDispute:
        return Icons.monetization_on_rounded;
      case IncidentCategory.safetyConcern:
        return Icons.gpp_bad_rounded;
      case IncidentCategory.badBehavior:
        return Icons.sentiment_very_dissatisfied_rounded;
      case IncidentCategory.appProblem:
        return Icons.phonelink_erase_rounded;
      case IncidentCategory.other:
        return Icons.help_outline_rounded;
    }
  }

  void _addMockPhotoAttachment() {
    setState(() {
      final photoNum = _attachedPhotos.length + 1;
      _attachedPhotos.add('مستند_إثبات_صورة_$photoNum.jpg');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.primary500,
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'تم إرفاق الملف المرفق بنجاح.',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
            ),
          ),
        ),
      ),
    );
  }

  void _removePhotoAttachment(int index) {
    setState(() {
      _attachedPhotos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.white : AppColors.gray900,
              size: 20,
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          centerTitle: true,
          title: Text(
            'مركز بلاغات ودعم لَفَّة',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s16),
            children: [
              // Info Banner Header
              _buildTopInfoBanner(isDark),

              AppSpacing.h24,

              // Incident Details Form Card
              _buildIncidentFormCard(isDark),

              AppSpacing.h24,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopInfoBanner(bool isDark) {
    return GlassBox(
      borderRadius: AppSpacing.radiusXL,
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s10),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: AppColors.danger,
              size: 24,
            ),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أمانكم وجودة رحلتكم هي أولويتنا القصوى',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h4,
                Text(
                  'فريق خدمة العملاء والتحقيق في منصة لَفَّة يعمل على مدار 24 ساعة للرد على الشكاوى والبلاغات ومطابقة المفقودات مع الكباتن في صنعاء فورياً.',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11,
                    height: 1.5,
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

  Widget _buildIncidentFormCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withOpacity(0.6) : AppColors.white.withOpacity(0.9),
        borderRadius: AppSpacing.borderXL,
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray200,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل بلاغ المشوار والمشكلة',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),
            
            AppSpacing.h16,

            // Input: Ride ID
            const Text(
              'الرقم المرجعي للمشوار أو الرحلة:',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.gray600,
              ),
            ),
            AppSpacing.h8,
            TextFormField(
              controller: _rideReferenceController,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'مثال: LFH-9284-SNA',
                hintStyle: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: isDark ? AppColors.gray600 : AppColors.gray400,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 14),
                filled: true,
                fillColor: isDark ? AppColors.white.withOpacity(0.02) : AppColors.gray50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: BorderSide(
                    color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.primary500,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                    width: 1.5,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال الرقم المرجعي للرحلة للمطابقة';
                }
                return null;
              },
            ),

            AppSpacing.h16,

            // Select Incident Category
            const Text(
              'تصنيف وفئة البلاغ:',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.gray600,
              ),
            ),
            AppSpacing.h8,
            _buildCategorySelector(isDark),

            AppSpacing.h16,

            // Input: Contact Phone
            const Text(
              'رقم للتواصل والمتابعة معك:',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.gray600,
              ),
            ),
            AppSpacing.h8,
            TextFormField(
              controller: _contactPhoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                prefixText: '+967  ',
                prefixStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary500,
                ),
                hintText: 'مثال: 777123456',
                hintStyle: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: isDark ? AppColors.gray600 : AppColors.gray400,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 14),
                filled: true,
                fillColor: isDark ? AppColors.white.withOpacity(0.02) : AppColors.gray50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: BorderSide(
                    color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.primary500,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                    width: 1.5,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال رقم الهاتف للمتابعة الفورية';
                }
                if (value.trim().length < 9) {
                  return 'يرجى إدخال رقم هاتف يمني صحيح (9 خانات)';
                }
                return null;
              },
            ),

            AppSpacing.h16,

            // Input: Title
            const Text(
              'عنوان البلاغ الأساسي باختصار:',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.gray600,
              ),
            ),
            AppSpacing.h8,
            TextFormField(
              controller: _titleController,
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
              decoration: InputDecoration(
                hintText: _getCategoryPlaceholder(_selectedCategory),
                hintStyle: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: isDark ? AppColors.gray600 : AppColors.gray400,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 14),
                filled: true,
                fillColor: isDark ? AppColors.white.withOpacity(0.02) : AppColors.gray50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: BorderSide(
                    color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.primary500,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                    width: 1.5,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال عنوان للبلاغ';
                }
                return null;
              },
            ),

            AppSpacing.h16,

            // Input: Details
            const Text(
              'تفاصيل البلاغ والأحداث المرافقة:',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.gray600,
              ),
            ),
            AppSpacing.h8,
            TextFormField(
              controller: _detailsController,
              maxLines: 4,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 13,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
              decoration: InputDecoration(
                hintText: 'يرجى سرد كافة التفاصيل والظروف المرافقة للمشكلة بدقة وشفافية، لنتمكن من مساعدتك فورياً ومطابقة بيانات النظام.',
                hintStyle: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11.5,
                  fontWeight: FontWeight.normal,
                  color: isDark ? AppColors.gray600 : AppColors.gray400,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 12),
                filled: true,
                fillColor: isDark ? AppColors.white.withOpacity(0.02) : AppColors.gray50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: BorderSide(
                    color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.primary500,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderSM,
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                    width: 1.5,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى تقديم شرح مفصل للبلاغ لتسهيل المتابعة';
                }
                if (value.trim().length < 15) {
                  return 'يرجى إدخال شرح وافٍ ومفصل (15 حرفاً كحد أدنى)';
                }
                return null;
              },
            ),

            AppSpacing.h16,

            // Attachment section for files / photos
            const Text(
              'إرفاق صور أو مستندات كإثبات (اختياري):',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.gray600,
              ),
            ),
            AppSpacing.h8,
            _buildAttachmentPicker(isDark),

            AppSpacing.h24,

            // Submit Incident Report Button
            _isSubmitting
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary500),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submitIncidentReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: AppColors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.borderMD,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.report_gmailerrorred_rounded, size: 20),
                          AppSpacing.w10,
                          Text(
                            'تقديم بلاغ رسمي للتحقيق والتحقق',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.white.withOpacity(0.02) : AppColors.gray50,
        borderRadius: AppSpacing.borderSM,
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<IncidentCategory>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.danger),
          dropdownColor: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
          borderRadius: AppSpacing.borderMD,
          items: IncidentCategory.values.map((IncidentCategory cat) {
            return DropdownMenuItem<IncidentCategory>(
              value: cat,
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(cat),
                    color: AppColors.danger,
                    size: 18,
                  ),
                  AppSpacing.w12,
                  Expanded(
                    child: Text(
                      _getCategoryArabicName(cat),
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (IncidentCategory? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCategory = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  String _getCategoryPlaceholder(IncidentCategory category) {
    switch (category) {
      case IncidentCategory.lostItem:
        return 'مثال: نسيان هاتف ذكي سامسونج أسود في المشوار';
      case IncidentCategory.fareDispute:
        return 'مثال: الكابتن طلب قيمة أجرة أعلى من تسعيرة التطبيق';
      case IncidentCategory.safetyConcern:
        return 'مثال: الكابتن كان يقود بسرعة مفرطة وعكس السير';
      case IncidentCategory.badBehavior:
        return 'مثال: تعامل الكابتن بلهجة غير لائقة أثناء الحوار';
      case IncidentCategory.appProblem:
        return 'مثال: موقع الخارطة تجمد وظل يظهر معلومات خاطئة';
      case IncidentCategory.other:
        return 'مثال: بلاغ بخصوص مشوار لَفَّة الأخير';
    }
  }

  Widget _buildAttachmentPicker(bool isDark) {
    return Column(
      children: [
        if (_attachedPhotos.isNotEmpty) ...[
          Container(
            height: 90,
            alignment: Alignment.centerRight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _attachedPhotos.length + 1,
              separatorBuilder: (context, index) => AppSpacing.w10,
              itemBuilder: (context, index) {
                if (index == _attachedPhotos.length) {
                  return _buildAddAttachmentButton(isDark);
                }
                return _buildAttachmentPreviewTile(isDark, index);
              },
            ),
          ),
        ] else ...[
          InkWell(
            onTap: _addMockPhotoAttachment,
            borderRadius: AppSpacing.borderSM,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.white.withOpacity(0.01) : AppColors.gray50,
                borderRadius: AppSpacing.borderSM,
                border: Border.all(
                  color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray300,
                  style: BorderStyle.values[1], // Dashed border representation
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: isDark ? AppColors.gray500 : AppColors.gray600,
                    size: 32,
                  ),
                  AppSpacing.h8,
                  const Text(
                    'اضغط هنا لالتقاط صورة أو إرفاق مستند كإثبات',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                    ),
                  ),
                  AppSpacing.h4,
                  const Text(
                    'يدعم صيغ JPG, PNG أو لقطة شاشة للمحادثة (الحد الأقصى: 3 صور)',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 9.5,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddAttachmentButton(bool isDark) {
    if (_attachedPhotos.length >= 3) return const SizedBox.shrink();

    return InkWell(
      onTap: _addMockPhotoAttachment,
      borderRadius: AppSpacing.borderSM,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isDark ? AppColors.white.withOpacity(0.02) : AppColors.gray100,
          borderRadius: AppSpacing.borderSM,
          border: Border.all(
            color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray300,
          ),
        ),
        child: const Icon(
          Icons.add_a_photo_rounded,
          color: AppColors.primary500,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildAttachmentPreviewTile(bool isDark, int index) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.gray200,
        borderRadius: AppSpacing.borderSM,
        border: Border.all(
          color: AppColors.primary500.withOpacity(0.3),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_rounded,
                  color: AppColors.primary500,
                  size: 22,
                ),
                AppSpacing.h4,
                Text(
                  'ملف رقم ${index + 1}',
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => _removePhotoAttachment(index),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.white,
                  size: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitIncidentReport() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulate a dispute ticket lodgement process with Laffah servers
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          final ticketNum = 'TK-${1000 + DateTime.now().second}-SNA';
          _showTicketSuccessDialog(ticketNum);
        }
      });
    }
  }

  void _showTicketSuccessDialog(String ticketId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderLG,
          ),
          icon: const Icon(
            Icons.verified_rounded,
            color: AppColors.success,
            size: 48,
          ),
          title: const Text(
            'تم تسجيل بلاغكم وقيد التحقيق',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'لقد تم تدوين شكواكم وتوليد تذكرة دعم تحت رقم مرجعي رسمي في سجلات المنصة:',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12,
                  height: 1.4,
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.gray400 : AppColors.gray700,
                ),
              ),
              AppSpacing.h12,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withOpacity(0.06),
                  borderRadius: AppSpacing.borderSM,
                  border: Border.all(color: AppColors.primary500.withOpacity(0.12)),
                ),
                alignment: Alignment.center,
                child: Text(
                  ticketId,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.primary500,
                  ),
                ),
              ),
              AppSpacing.h12,
              Text(
                'سيقوم مسؤول خدمة العملاء وقسم التحقيق بمراجعة المشوار ومطابقة الموقع فورياً ثم التواصل معكم عبر رقم الهاتف لتسوية النزاع أو استلام المفقودات.',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  height: 1.4,
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Go back to safety screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderXS,
                ),
              ),
              child: const Text(
                'العودة لصفحة الأمان والرحلات',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
