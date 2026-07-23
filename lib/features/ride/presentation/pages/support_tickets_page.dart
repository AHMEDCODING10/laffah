import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';

/// SupportTicketsPage - Portal to view, create, and track active customer support tickets.
/// Supports interactive form submission with categories, and semantic status color badges.
class SupportTicketsPage extends StatefulWidget {
  const SupportTicketsPage({super.key});

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage> {
  // Mock support tickets database
  final List<Map<String, dynamic>> _tickets = [
    {
      'id': 'TCK-948',
      'title': 'غرض مفقود بالسيارة',
      'category': 'فقدان متعلقات',
      'date': '12 أكتوبر 2025 • 11:00 ص',
      'status': 'Solved', // Solved -> success color
      'statusAr': 'تم الحل',
      'description': 'نسيت حقيبتي الصغيرة السوداء في المقعد الخلفي من رحلة شارع حدة.',
      'response': 'تم التواصل مع الكابتن أحمد وأفاد بالعثور على الحقيبة. تم حفظها بمركز لَفَّة الرئيسي للتسليم.'
    },
    {
      'id': 'TCK-201',
      'title': 'احتساب قيمة إضافية للمشوار',
      'category': 'الدفع والأسعار',
      'date': '10 أكتوبر 2025 • 08:30 م',
      'status': 'In Progress', // In Progress -> Info color
      'statusAr': 'جاري المعالجة',
      'description': 'تم خصم مبلغ إضافي يزيد عن المبلغ المقدر للرحلة بمقدار 300 ريال.',
      'response': null
    },
    {
      'id': 'TCK-105',
      'title': 'صعوبة فتح تطبيق لَفَّة بالدراجة',
      'category': 'مشكلة تقنية',
      'date': '05 أكتوبر 2025 • 04:15 م',
      'status': 'Pending', // Pending -> Warning color
      'statusAr': 'قيد المراجعة',
      'description': 'رمز تحقق الدخول OTP يستغرق طويلاً للوصول لبعض شبكات يمن موبايل.',
      'response': null
    }
  ];

  final List<String> _categories = [
    'مشكلة في الدفع والأسعار',
    'فقدان غرض شخصي',
    'شكوى ضد السلوك أو القيادة',
    'مشكلة في جودة الخدمة',
    'طلب استرجاع مالي',
    'ملاحظات ومقترحات تقنية',
  ];

  String _selectedCategory = 'مشكلة في الدفع والأسعار';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createNewTicketBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return GlassBox(
              borderRadius: AppSpacing.radiusBottomSheet,
              padding: EdgeInsets.only(
                left: AppSpacing.s24,
                right: AppSpacing.s24,
                top: AppSpacing.s24,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s24,
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.white.withOpacity(0.12) : AppColors.gray300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      AppSpacing.h16,
                      const Center(
                        child: Text(
                          'إنشاء تذكرة دعم جديدة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: AppColors.primary500,
                          ),
                        ),
                      ),
                      AppSpacing.h20,

                      // Category Dropdown
                      const Text(
                        'نوع المشكلة / التصنيف',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      AppSpacing.h8,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black.withOpacity(0.2) : AppColors.white,
                          borderRadius: AppSpacing.borderMD,
                          border: Border.all(
                            color: isDark ? AppColors.white.withOpacity(0.08) : AppColors.gray300,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            dropdownColor: isDark ? AppColors.surfaceDark : AppColors.white,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary500),
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setModalState(() {
                                  _selectedCategory = newValue;
                                });
                              }
                            },
                            items: _categories.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'IBM Plex Sans Arabic',
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      AppSpacing.h16,

                      // Title Field
                      const Text(
                        'عنوان المشكلة',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      AppSpacing.h8,
                      TextField(
                        controller: _titleController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic'),
                        decoration: InputDecoration(
                          hintText: 'مثال: مشكلة في استلام الطرد',
                          hintStyle: TextStyle(
                            fontSize: 11,
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: isDark ? AppColors.gray500 : AppColors.gray400,
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.black.withOpacity(0.2) : AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppSpacing.borderMD,
                            borderSide: BorderSide(
                              color: isDark ? AppColors.white.withOpacity(0.08) : AppColors.gray300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppSpacing.borderMD,
                            borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
                          ),
                        ),
                      ),

                      AppSpacing.h16,

                      // Description Field
                      const Text(
                        'تفاصيل ووصف المشكلة بالتفصيل',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      AppSpacing.h8,
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic'),
                        decoration: InputDecoration(
                          hintText: 'يرجى كتابة تفاصيل المشكلة أو الشكوى، كود المشوار ومقدار السعر لمساعدتنا على معالجتها على الفور...',
                          hintStyle: TextStyle(
                            fontSize: 11,
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: isDark ? AppColors.gray500 : AppColors.gray400,
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.black.withOpacity(0.2) : AppColors.white,
                          contentPadding: const EdgeInsets.all(AppSpacing.s12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppSpacing.borderMD,
                            borderSide: BorderSide(
                              color: isDark ? AppColors.white.withOpacity(0.08) : AppColors.gray300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppSpacing.borderMD,
                            borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
                          ),
                        ),
                      ),

                      AppSpacing.h24,

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: AppSpacing.borderMD,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('يرجى ملء جميع الحقول المطلوبة', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                                    backgroundColor: AppColors.danger,
                                  ),
                                );
                                return;
                              }

                              // Add item and close
                              setState(() {
                                _tickets.insert(0, {
                                  'id': 'TCK-${100 + _tickets.length + 1}',
                                  'title': _titleController.text.trim(),
                                  'category': _selectedCategory,
                                  'date': 'اليوم • الآن',
                                  'status': 'Pending',
                                  'statusAr': 'قيد المراجعة',
                                  'description': _descriptionController.text.trim(),
                                  'response': null
                                });
                              });

                              // Clean Controllers
                              _titleController.clear();
                              _descriptionController.clear();

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'تم تقديم التذكرة بنجاح! سيقوم فريق الدعم بالرد خلال 15 دقيقة',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: AppColors.success,
                                  shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderMD),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderMD),
                            ),
                            child: const Text(
                              'تقديم التذكرة',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'IBM Plex Sans Arabic',
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'تذاكر الدعم والمساعدة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'IBM Plex Sans Arabic',
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          children: [
            // Upper assistance informational guide
            GlassBox(
              borderRadius: AppSpacing.radiusLG,
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.headset_mic_rounded,
                      color: AppColors.primary500,
                      size: 24,
                    ),
                  ),
                  AppSpacing.w16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'دعم لَفَّة الفوري (Laffah Care)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                        AppSpacing.h4,
                        Text(
                          'نحن هنا لخدمتك طوال اليوم في صنعاء. نضمن الاستجابة السريعة لحل المشكلات المالية وفقدان الأغراض.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: isDark ? AppColors.gray400 : AppColors.gray600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.h24,

            // Ticket Lists Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'تذاكري النشطة والسابقة',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
                Text(
                  '(${_tickets.length} تذاكر)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),

            AppSpacing.h12,

            // Ticket Builder
            if (_tickets.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(Icons.confirmation_number_outlined, size: 54, color: AppColors.primary500.withOpacity(0.3)),
                      AppSpacing.h12,
                      const Text(
                        'لا توجد لديك أي تذاكر دعم حالياً',
                        style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', color: AppColors.gray500),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(_tickets.length, (index) {
                final ticket = _tickets[index];
                final String status = ticket['status'];
                final String statusAr = ticket['statusAr'];

                // Badge semantic colors
                Color badgeBgColor;
                Color badgeTextColor;

                switch (status) {
                  case 'Solved':
                    badgeBgColor = AppColors.success.withOpacity(0.12);
                    badgeTextColor = AppColors.success;
                    break;
                  case 'In Progress':
                    badgeBgColor = AppColors.info.withOpacity(0.12);
                    badgeTextColor = AppColors.info;
                    break;
                  default: // Pending
                    badgeBgColor = AppColors.warning.withOpacity(0.12);
                    badgeTextColor = AppColors.warning;
                    break;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                  elevation: 0,
                  color: isDark ? AppColors.surfaceDark.withOpacity(0.6) : AppColors.surfaceLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderLG,
                    side: BorderSide(
                      color: isDark ? AppColors.white.withOpacity(0.06) : AppColors.gray200,
                      width: 1,
                    ),
                  ),
                  child: ExpansionTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ticket['id'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'IBM Plex Sans Arabic',
                                color: isDark ? AppColors.gray500 : AppColors.gray500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s2),
                              decoration: BoxDecoration(
                                color: badgeBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusAr,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  color: badgeTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.h4,
                        Text(
                          ticket['title'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'التصنيف: ' + ticket['category'] + ' • ' + ticket['date'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: isDark ? AppColors.gray500 : AppColors.gray500,
                        ),
                      ),
                    ),
                    childrenPadding: const EdgeInsets.all(AppSpacing.s16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Client Description Details
                      Text(
                        'وصف المشكلة:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      AppSpacing.h4,
                      Text(
                        ticket['description'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),

                      if (ticket['response'] != null) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.reply_rounded, size: 16, color: AppColors.success),
                            AppSpacing.w8,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'رد فريق الدعم (لَفَّة):',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                      fontFamily: 'IBM Plex Sans Arabic',
                                    ),
                                  ),
                                  AppSpacing.h4,
                                  Text(
                                    ticket['response'],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'IBM Plex Sans Arabic',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 14, color: AppColors.warning),
                            AppSpacing.w8,
                            const Text(
                              'جاري مراجعة التذكرة وتدقيقها بواسطة فريق الدعم الفني.',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray500,
                                fontFamily: 'IBM Plex Sans Arabic',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),
          ],
        ),
        floatingActionButton: Directionality(
          textDirection: TextDirection.rtl,
          child: FloatingActionButton.extended(
            onPressed: _createNewTicketBottomSheet,
            backgroundColor: AppColors.primary500,
            icon: const Icon(Icons.add_comment_rounded, color: AppColors.white),
            label: const Text(
              'إنشاء تذكرة جديدة',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBM Plex Sans Arabic',
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
