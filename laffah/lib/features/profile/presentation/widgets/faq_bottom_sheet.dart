import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class FaqItem {
  final String question;
  final String answer;
  final String category;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class LaffahFaqBottomSheet extends StatefulWidget {
  final String initialCategory;

  const LaffahFaqBottomSheet({
    super.key,
    this.initialCategory = 'all',
  });

  static void show(BuildContext context, {String initialCategory = 'all'}) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LaffahFaqBottomSheet(initialCategory: initialCategory),
    );
  }

  @override
  State<LaffahFaqBottomSheet> createState() => _LaffahFaqBottomSheetState();
}

class _LaffahFaqBottomSheetState extends State<LaffahFaqBottomSheet> {
  late String _selectedCategory;
  int _expandedIndex = 0; // Expand first item by default for great discoverability

  static const List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'جميع الأسئلة'},
    {'id': 'rides', 'label': 'المشاوير'},
    {'id': 'delivery', 'label': 'الطرود والتوصيل'},
    {'id': 'payment', 'label': 'الدفع والمحفظة'},
    {'id': 'captain', 'label': 'الكباتن'},
  ];

  static const List<FaqItem> _allFaqs = [
    FaqItem(
      question: 'كيف يتم احتساب تسعيرة المشوار في تطبيق لَفَّة؟',
      answer:
          'يتم احتساب الأجرة بدقة وفق خوارزمية ذكية وعادلة تعتمد على المسافة المقطوعة الفطرية بالكيلومتر والوقت المتوقع، دون أي زيادات عشوائية، وتظهر التسعيرة للراكب والكابتن بوضوح قبل تأكيد الرحلة.',
      category: 'rides',
    ),
    FaqItem(
      question: 'كيف تعمل خدمة توصيل الطرود والطلبات السريعة؟',
      answer:
          'عند طلب خدمة "لَفَّة طرود"، يقوم الكابتن باستلام الطرد من المرسل والتحقق من سلامته. يتم إرسال كود تحقق سري (OTP) إلى هاتف المستلم، ولا يكتمل تسليم الشحنة إلا بعد إدخال الكود الصحيح لضمان أمان الطرد 100%.',
      category: 'delivery',
    ),
    FaqItem(
      question: 'ما هي خيارات وطرق الدفع المتاحة في التطبيق؟',
      answer:
          'يوفر تطبيق لَفَّة مرونة كاملة في الدفع: يمكنك الدفع نقداً (كاش) للكابتن عند الوصول، أو الدفع عبر محفظة لَفَّة الرقمية، أو عبر المحافظ الإلكترونية اليمنية المعتمدة (مثل كاش، فلوسك، جايبي، محفظتي).',
      category: 'payment',
    ),
    FaqItem(
      question: 'ماذا أفعل إذا نسيت غرضاً في الرحلة أو مع الكابتن؟',
      answer:
          'يمكنك التواصل فوراً مع الدعم الفني المباشر للتطبيق عبر الاتصال السريع أو واتساب الدعم، وسيقوم فريق العمل بالتنسيق المباشر مع الكابتن المعني لتسليمك المفقودات في أسرع وقت.',
      category: 'rides',
    ),
    FaqItem(
      question: 'كيف يتم ضمان أمان الرحلات وجودة الخدمة؟',
      answer:
          'جميع كباتن لَفَّة مسجلون وموثقون بوثائق رسمية معتمدة (بطاقة شخصية، رخصة قيادة، كرت ملكية دراجة نارية، فحص دوري). كما يتيح التطبيق مشاركة مسار المشوار المباشر مع عائلتك وتقييم الكابتن بعد كل مشوار.',
      category: 'rides',
    ),
    FaqItem(
      question: 'للكباتن: متى وكيف تضاف أرباح الرحلات إلى الرصيد؟',
      answer:
          'تضاف أرباح الرحلات المنفذة مباشرة وبشكل فوري إلى محفظة الكابتن داخل التطبيق فور انتهاء الرحلة. يمكن للكابتن تحويل وسحب أرباحه أو شحن حسابه عبر مراكز ووكلاء لَفَّة المعتمدين.',
      category: 'captain',
    ),
    FaqItem(
      question: 'ما هي سياسة إلغاء المشاوير؟',
      answer:
          'يمكن للراكب أو الكابتن إلغاء الطلب مجاناً في حال وجود سبب طارئ أو قبل تحرك الكابتن لمسافة طويلة. نرجو دائماً ذكر سبب الإلغاء لمساعدتنا في تقديم أفضل تجربة ممكنة.',
      category: 'rides',
    ),
    FaqItem(
      question: 'ما هي الشروط والمتطلبات للانضمام ككابتن في لَفَّة؟',
      answer:
          'يتطلب الانضمام كابتن: بطاقة شخصية سارية، رخصة قيادة دراجة نارية صالحة، كرت ملكية الدراجة أو تفويض رسمي، ودراجة نارية بحالة فنية ممتازة وتوفر خوذة أمان.',
      category: 'captain',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  List<FaqItem> get _filteredFaqs {
    if (_selectedCategory == 'all') {
      return _allFaqs;
    }
    return _allFaqs.where((f) => f.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredFaqs;

    return Directionality(
      textDirection: TextDirection.rtl,
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
                    ? const Color(0xFF141822).withValues(alpha: 0.96)
                    : Colors.white.withValues(alpha: 0.97),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: AppColors.primary500.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
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
                  AppSpacing.h16,

                  // Header
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
                              Icons.quiz_rounded,
                              color: AppColors.primary500,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'الأسئلة الشائعة',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: isDark ? Colors.white : AppColors.gray900,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  AppSpacing.h12,

                  // Categories Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat['id'];
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChip(
                            label: Text(
                              cat['label']!,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.gray300
                                        : AppColors.gray700),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primary500,
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : AppColors.gray100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary500
                                    : Colors.transparent,
                              ),
                            ),
                            onSelected: (val) {
                              if (val) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedCategory = cat['id']!;
                                  _expandedIndex = 0;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  AppSpacing.h16,

                  // FAQ List
                  Flexible(
                    child: filtered.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'لا توجد أسئلة في هذا القسم حالياً',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  color: isDark
                                      ? AppColors.gray400
                                      : AppColors.gray600,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              final isExpanded = _expandedIndex == index;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(
                                          alpha: isExpanded ? 0.06 : 0.02)
                                      : (isExpanded
                                          ? AppColors.primary500
                                              .withValues(alpha: 0.04)
                                          : AppColors.gray50),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isExpanded
                                        ? AppColors.primary500
                                            .withValues(alpha: 0.6)
                                        : (isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.05)
                                            : AppColors.gray200),
                                    width: isExpanded ? 1.4 : 1.0,
                                  ),
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    dividerColor: Colors.transparent,
                                  ),
                                  child: ExpansionTile(
                                    key: Key('faq_${_selectedCategory}_$index'),
                                    initiallyExpanded: isExpanded,
                                    tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 4),
                                    childrenPadding:
                                        const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                    collapsedIconColor: isDark
                                        ? AppColors.gray400
                                        : AppColors.gray600,
                                    iconColor: AppColors.primary500,
                                    onExpansionChanged: (expanded) {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _expandedIndex =
                                            expanded ? index : -1;
                                      });
                                    },
                                    title: Text(
                                      item.question,
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isExpanded
                                            ? AppColors.primary500
                                            : (isDark
                                                ? Colors.white
                                                : AppColors.gray900),
                                        height: 1.4,
                                      ),
                                    ),
                                    children: [
                                      Text(
                                        item.answer,
                                        style: TextStyle(
                                          fontFamily: 'IBM Plex Sans Arabic',
                                          fontSize: 12,
                                          height: 1.55,
                                          color: isDark
                                              ? AppColors.gray300
                                              : AppColors.gray700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  AppSpacing.h16,

                  // Close Button
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: AppColors.primary500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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
          ),
        ),
      ),
    );
  }
}
