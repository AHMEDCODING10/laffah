import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/upload_document_usecase.dart';

/// Enum representing the verification status of a document
enum DocumentStatus {
  empty,        // Not uploaded yet
  underReview,  // Uploaded, waiting for admin approval
  approved,     // Verified and approved
  rejected,     // Rejected with feedback
}

/// Model class representing a Captain Document
class CaptainDocument {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  DocumentStatus status;
  String? feedback;
  String? filePath;

  CaptainDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.status,
    this.feedback,
    this.filePath,
  });
}

/// CaptainDocumentUploadPage - A production-grade Document Upload & Onboarding Wizard
/// designed for Laffah Captains in Sana'a, Yemen.
/// Offers beautiful, reactive feedback, mock upload state animations, and clear instructions.
class CaptainDocumentUploadPage extends StatefulWidget {
  const CaptainDocumentUploadPage({super.key});

  @override
  State<CaptainDocumentUploadPage> createState() => _CaptainDocumentUploadPageState();
}

class _CaptainDocumentUploadPageState extends State<CaptainDocumentUploadPage> with SingleTickerProviderStateMixin {
  late List<CaptainDocument> _documents;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeDocuments();
  }

  void _initializeDocuments() {
    _documents = [
      CaptainDocument(
        id: 'national_id',
        title: 'البطاقة الشخصية (الهوية الوطنية)',
        description: 'صورة واضحة للوجهين الأمامي والخلفي للبطاقة الشخصية الذكية أو جواز السفر الساري.',
        icon: Icons.badge_rounded,
        status: DocumentStatus.empty,
      ),
      CaptainDocument(
        id: 'drivers_license',
        title: 'رخصة القيادة الشخصية',
        description: 'رخصة قيادة سارية المفعول صادرة من الإدارة العامة للمرور في الجمهورية اليمنية.',
        icon: Icons.card_membership_rounded,
        status: DocumentStatus.empty,
      ),
      CaptainDocument(
        id: 'vehicle_ownership',
        title: 'كرت ملكية المركبة (الاستمارة)',
        description: 'صورة واضحة لكرت الملكية الخاص بالدراجة النارية أو ط§ظ„ط³ظٹط§رة المستخدمة في التوصيل.',
        icon: Icons.assignment_rounded,
        status: DocumentStatus.empty,
      ),
      CaptainDocument(
        id: 'criminal_record',
        title: 'صحيفة الحالة الجنائية (الفيش والتشبيه)',
        description: 'شهادة حسن سيرة وسلوك حديثة صادرة من إدارة الأدلة الجنائية بوزارة الداخلية.',
        icon: Icons.gavel_rounded,
        status: DocumentStatus.empty,
      ),
    ];
  }

  // Calculate dynamic verification completion percentage
  double _calculateProgress() {
    int score = 0;
    for (var doc in _documents) {
      if (doc.status == DocumentStatus.approved) {
        score += 25;
      } else if (doc.status == DocumentStatus.underReview) {
        score += 15; // Partial progress for submitted documents
      }
    }
    return score / 100.0;
  }

  int _getApprovedCount() {
    return _documents.where((doc) => doc.status == DocumentStatus.approved).length;
  }

  int _getSubmittedCount() {
    return _documents.where((doc) => doc.status != DocumentStatus.empty).length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _calculateProgress();
    final isAllSubmitted = _documents.every((doc) => doc.status == DocumentStatus.approved || doc.status == DocumentStatus.underReview);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
            'توثيق وثائق الكابتن',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s16),
                  children: [
                    // ==========================================
                    // Dynamic Header & Onboarding Progress Card
                    // ==========================================
                    _buildProgressHeaderCard(isDark, progress),
                    
                    AppSpacing.h24,

                    // ==========================================
                    // Guide / Instruction Text
                    // ==========================================
                    _buildGuideSection(isDark),

                    AppSpacing.h20,

                    // ==========================================
                    // Interactive Documents List
                    // ==========================================
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _documents.length,
                      separatorBuilder: (context, index) => AppSpacing.h16,
                      itemBuilder: (context, index) {
                        return _buildDocumentCard(isDark, _documents[index]);
                      },
                    ),

                    AppSpacing.h32,
                  ],
                ),
              ),

              // ==========================================
              // Persistent Action Footer Button
              // ==========================================
              _buildStickyFooter(isDark, isAllSubmitted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeaderCard(bool isDark, double progress) {
    final approvedCount = _getApprovedCount();
    final submittedCount = _getSubmittedCount();

    return GlassBox(
      borderRadius: AppSpacing.radiusXL,
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحلة تفعيل الحساب',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    'تم رفع ($submittedCount) وقبول ($approvedCount) من (${_documents.length}) وثائق',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s6),
                decoration: BoxDecoration(
                  color: progress == 1.0 
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.primary500.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: progress == 1.0 
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.primary500.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  progress == 1.0 ? 'حساب موثق ✓' : 'قيد الاكتمال',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    color: progress == 1.0 ? AppColors.success : AppColors.primary500,
                  ),
                ),
              ),
            ],
          ),
          
          AppSpacing.h16,

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  color: isDark ? AppColors.white.withValues(alpha: 0.06) : AppColors.gray200,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  height: 8,
                  width: MediaQuery.of(context).size.width * 0.8 * progress,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.h12,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'نسبة التوثيق الإجمالية:',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  color: isDark ? AppColors.gray500 : AppColors.gray500,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: AppSpacing.borderSM,
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.info,
            size: 20,
          ),
          AppSpacing.w10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تعليمات تصوير الوثائق',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h4,
                Text(
                  'يرجى التقاط صور واضحة ومباشرة دون انعكاسات ضوئية. تأكد من أن جميع زوايا المستند ظاهرة بوضوح وأن النصوص مقروءة ظ„طھفادي تأخير مراجعة الطلب.',
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

  Widget _buildDocumentCard(bool isDark, CaptainDocument doc) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (doc.status) {
      case DocumentStatus.approved:
        statusColor = AppColors.success;
        statusText = 'مقبول ومعتمد';
        statusIcon = Icons.check_circle_rounded;
        break;
      case DocumentStatus.underReview:
        statusColor = AppColors.warning;
        statusText = 'جاري المراجعة والتدقيق';
        statusIcon = Icons.pending_rounded;
        break;
      case DocumentStatus.rejected:
        statusColor = AppColors.danger;
        statusText = 'مرفوض - يتطلب إعادة رفع';
        statusIcon = Icons.error_outline_rounded;
        break;
      case DocumentStatus.empty:
        statusColor = AppColors.gray500;
        statusText = 'لم يتم الرفع بعد';
        statusIcon = Icons.cloud_upload_outlined;
        break;
    }

    return GestureDetector(
      onTap: () => _handleDocumentTap(doc),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.6) : AppColors.white.withValues(alpha: 0.9),
          borderRadius: AppSpacing.borderLG,
          border: Border.all(
            color: doc.status == DocumentStatus.rejected
                ? AppColors.danger.withValues(alpha: 0.3)
                : (isDark ? AppColors.white.withValues(alpha: 0.04) : AppColors.gray200),
            width: doc.status == DocumentStatus.rejected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Icon, Title & Status Indicator
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s10),
                  decoration: BoxDecoration(
                    color: doc.status == DocumentStatus.approved
                        ? AppColors.success.withValues(alpha: 0.1)
                        : (doc.status == DocumentStatus.rejected
                            ? AppColors.danger.withValues(alpha: 0.1)
                            : AppColors.primary500.withValues(alpha: 0.1)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    doc.icon,
                    color: doc.status == DocumentStatus.approved
                        ? AppColors.success
                        : (doc.status == DocumentStatus.rejected
                            ? AppColors.danger
                            : AppColors.primary500),
                    size: 22,
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                      AppSpacing.h4,
                      Text(
                        doc.description,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 11,
                          height: 1.4,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            AppSpacing.h16,
            const Divider(height: 1, thickness: 0.8),
            AppSpacing.h12,

            // Row 2: Verification Status Pill & Action button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 16,
                    ),
                    AppSpacing.w6,
                    Text(
                      statusText,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                _buildActionButton(doc),
              ],
            ),

            // Conditional Feedback Message Box
            if (doc.feedback != null) ...[
              AppSpacing.h12,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.s10),
                decoration: BoxDecoration(
                  color: doc.status == DocumentStatus.rejected
                      ? AppColors.danger.withValues(alpha: 0.06)
                      : (doc.status == DocumentStatus.approved
                          ? AppColors.success.withValues(alpha: 0.06)
                          : AppColors.gray100.withValues(alpha: 0.5)),
                  borderRadius: AppSpacing.borderSM,
                  border: Border.all(
                    color: doc.status == DocumentStatus.rejected
                        ? AppColors.danger.withValues(alpha: 0.15)
                        : (doc.status == DocumentStatus.approved
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.gray200),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.status == DocumentStatus.rejected
                          ? 'ملاحظات فريق المراجعة لتعديل الرفض:'
                          : 'ملاحظة التدقيق:',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: doc.status == DocumentStatus.rejected
                            ? AppColors.danger
                            : (doc.status == DocumentStatus.approved
                                ? AppColors.success
                                : AppColors.gray700),
                      ),
                    ),
                    AppSpacing.h4,
                    Text(
                      doc.feedback!,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11,
                        height: 1.4,
                        color: isDark ? AppColors.gray300 : AppColors.gray800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(CaptainDocument doc) {
    String btnText;
    IconData btnIcon;
    Color btnColor;

    switch (doc.status) {
      case DocumentStatus.approved:
        btnText = 'عرض المستند';
        btnIcon = Icons.visibility_outlined;
        btnColor = AppColors.success;
        break;
      case DocumentStatus.underReview:
        btnText = 'جاري التحقق';
        btnIcon = Icons.hourglass_empty_rounded;
        btnColor = AppColors.warning;
        break;
      case DocumentStatus.rejected:
        btnText = 'إعادة الرفع';
        btnIcon = Icons.refresh_rounded;
        btnColor = AppColors.danger;
        break;
      case DocumentStatus.empty:
        btnText = 'رفع الوثيقة';
        btnIcon = Icons.arrow_outward_rounded;
        btnColor = AppColors.primary500;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s6),
      decoration: BoxDecoration(
        color: doc.status == DocumentStatus.underReview
            ? btnColor.withValues(alpha: 0.08)
            : btnColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: btnColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            btnText,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 11,
              color: btnColor,
            ),
          ),
          AppSpacing.w4,
          Icon(
            btnIcon,
            color: btnColor,
            size: 13,
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(bool isDark, bool isAllSubmitted) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.rLG),
          topRight: Radius.circular(AppSpacing.rLG),
        ),
      ),
      child: _isSubmitting
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary500),
                ),
              ),
            )
          : SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isAllSubmitted ? _submitAllDocuments : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: isDark ? AppColors.gray800 : AppColors.gray200,
                  disabledForegroundColor: isDark ? AppColors.gray600 : AppColors.gray400,
                  elevation: isAllSubmitted ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderMD,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isAllSubmitted ? 'إرسال الملف الكامل للمراجعة والتفعيل' : 'يرجى استكمال جميع الوثائق أولًا',
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    AppSpacing.w8,
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _handleDocumentTap(CaptainDocument doc) {
    if (doc.status == DocumentStatus.approved) {
      _showApprovedDocumentDialog(doc);
    } else if (doc.status == DocumentStatus.underReview) {
      _showUnderReviewDialog(doc);
    } else {
      // Empty or Rejected -> Open beautiful Upload Bottom Sheet wizard
      _showUploadBottomSheet(doc);
    }
  }

  void _showApprovedDocumentDialog(CaptainDocument doc) {
    showDialog(
      context: context,
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
            Icons.verified_user_rounded,
            color: AppColors.success,
            size: 40,
          ),
          title: Text(
            doc.title,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'حالة الوثيقة: معتمدة وموثقة بالكامل',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.success,
                ),
              ),
              AppSpacing.h12,
              Text(
                doc.feedback ?? 'لا توجد ملاحظات إضافية.',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.gray300
                      : AppColors.gray700,
                ),
              ),
              AppSpacing.h16,
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.05),
                  borderRadius: AppSpacing.borderMD,
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_rounded,
                        color: AppColors.success,
                        size: 32,
                      ),
                      AppSpacing.h8,
                      Text(
                        'صورة المستند مشفرة ومؤمنة حماية لخصوصيتك',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'إغلاق',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnderReviewDialog(CaptainDocument doc) {
    showDialog(
      context: context,
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
            Icons.hourglass_top_rounded,
            color: AppColors.warning,
            size: 40,
          ),
          title: Text(
            doc.title,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'حالة الوثيقة: جاري مطابقة البيانات',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.warning,
                ),
              ),
              AppSpacing.h12,
              const Text(
                'لقد استلمنا ملفك بنجاح. يقوم فريق التحقق والامتثال بمطاط¨ظ‚ط© البيانات مع المكاتب الحكومية ذات العلاقة في صنعاء. ط³نقوم بإرسال إشعار فوري فور تفعيلها.',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.gray600,
                ),
              ),
              AppSpacing.h12,
              Text(
                doc.feedback ?? '',
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'حسناً',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadBottomSheet(CaptainDocument doc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
                borderRadius: AppSpacing.borderBottomSheet,
              ),
              padding: EdgeInsets.only(
                top: AppSpacing.s24,
                left: AppSpacing.s24,
                right: AppSpacing.s24,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Drag handle
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.gray700 : AppColors.gray300,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  
                  AppSpacing.h24,

                  Row(
                    children: [
                      Icon(
                        doc.icon,
                        color: AppColors.primary500,
                        size: 26,
                      ),
                      AppSpacing.w12,
                      Expanded(
                        child: Text(
                          'رفع: ${doc.title}',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: isDark ? AppColors.white : AppColors.gray900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  AppSpacing.h16,

                  Text(
                    doc.description,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      height: 1.5,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),

                  AppSpacing.h24,

                  // Important notice
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.08),
                      borderRadius: AppSpacing.borderSM,
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        AppSpacing.w10,
                        Expanded(
                          child: Text(
                            'تأكد من عدم وجود تمويه أو تغطية لأي حقول هامة مثل الاسم، تاريخ الانتهاء، أو الرقم التسلسلي.',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.h24,

                  // Upload options
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleDocumentUpload(doc, 'كاميرا'),
                          icon: const Icon(
                            Icons.photo_camera_rounded,
                            color: AppColors.primary500,
                            size: 20,
                          ),
                          label: const Text(
                            'التقاط بالكاميرا',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary500,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppColors.primary500, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppSpacing.borderMD,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.w16,
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleDocumentUpload(doc, 'معرض الصور'),
                          icon: const Icon(
                            Icons.photo_library_rounded,
                            color: AppColors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'اختيار ملف/صورة',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary500,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppSpacing.borderMD,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  AppSpacing.h16,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleDocumentUpload(CaptainDocument doc, String source) async {
    // Close Bottom Sheet first
    Navigator.pop(context);

    final picker = ImagePicker();
    final isCamera = source == 'كاميرا';
    
    final XFile? image = await picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    // Show persistent Loading SnackBar for upload & processing
    final snackBar = SnackBar(
      backgroundColor: AppColors.black,
      duration: const Duration(seconds: 2),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary500),
                strokeWidth: 2,
              ),
            ),
            AppSpacing.w12,
            Expanded(
              child: Text(
                'جاري رفع الصورة وتشفيرها (حجم الملف: ${(await image.length() / 1024).toStringAsFixed(1)} KB)',
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Map document id to backend type expected by Laravel (id_card, driving_license, vehicle_registration)
    String apiType = 'id_card';
    if (doc.id == 'drivers_license') {
      apiType = 'driving_license';
    } else if (doc.id == 'vehicle_ownership') {
      apiType = 'vehicle_registration';
    } else if (doc.id == 'criminal_record') {
      apiType = 'id_card';
    }

    final result = await sl<UploadDocumentUseCase>()(File(image.path), apiType);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              'فشل رفع المستند: ${failure.message}',
              style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
            ),
          ),
        );
      },
      (data) {
        setState(() {
          doc.status = DocumentStatus.underReview;
          doc.filePath = image.path;
          doc.feedback = 'تم رفع المستند بنجاح وهو قيد المراجعة الآن.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text(
              'تم رفع المستند بنجاح! 🎉',
              style: TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
            ),
          ),
        );
      },
    );
  }


  void _submitAllDocuments() {
    setState(() {
      _isSubmitting = true;
    });

    // TODO: Submit to backend
    setState(() {
      _isSubmitting = false;
    });

    // Show Success dialog
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
            Icons.mark_email_read_rounded,
            color: AppColors.success,
            size: 50,
          ),
          title: const Text(
            'تم تقديم الملف للمراجعة النهائية',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          content: const Text(
            'تهانينا! لقد قمت بتقديم جميع وثائق توثيق حساب الكابتن بنجاح. ط³ظٹظ‚ظˆم فريق لَفَّة (لفّة) بمراجعة الملف وتنشيط حسابك بالكامل خلال ساعات قليلة.\n\nيمكنك الآن استئناف استكشاف الواجهات ومحاكاة الرحلات في غضون ذلك.',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 13,
              height: 1.5,
              color: AppColors.gray600,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Go back to Home or previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderXS,
                ),
              ),
              child: const Text(
                'حسناً، الانتقال للرئيسية',
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
