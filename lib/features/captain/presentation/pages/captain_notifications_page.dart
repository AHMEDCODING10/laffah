import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// CaptainNotificationsPage - Dynamic notification logs and nearby trip requests panel.
/// Contains segmented tabs, accept/reject quick triggers, and system alert layouts.
class CaptainNotificationsPage extends StatefulWidget {
  const CaptainNotificationsPage({super.key});

  @override
  State<CaptainNotificationsPage> createState() => _CaptainNotificationsPageState();
}

class _CaptainNotificationsPageState extends State<CaptainNotificationsPage> {
  int _activeCategoryIndex = 0;
  final List<String> _categories = ['الطلبات الجديدة', 'تحديثات النظام', 'التنبيهات'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'التنبيهات والطلبات',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: 'IBM Plex Sans Arabic',
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: AppColors.primary500),
            tooltip: 'تحديد الكل كمقروء',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديد جميع التنبيهات كمقروءة')),
              );
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // 1. Segmented control tabs (Yemeni-styled pills)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.gray100,
                  borderRadius: AppSpacing.borderLG,
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: List.generate(_categories.length, (index) {
                    final isSelected = _activeCategoryIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeCategoryIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.primary900 : AppColors.white)
                                : Colors.transparent,
                            borderRadius: AppSpacing.borderMD,
                            boxShadow: isSelected && !isDark
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _categories[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                              color: isSelected
                                  ? (isDark ? Colors.white : AppColors.primary900)
                                  : AppColors.gray500,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // 2. Notifications List
            Expanded(
              child: _activeCategoryIndex == 0
                  ? _buildTripRequestsList(isDark)
                  : _activeCategoryIndex == 1
                      ? _buildSystemUpdatesList(isDark)
                      : _buildGeneralAlertsList(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripRequestsList(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      children: [
        _buildInteractiveRequestCard(
          isDark: isDark,
          title: 'طلب لَفَّة مشوار جديد',
          description: 'العميل "محمد م." بالقرب من موقعك يطلب رحلة فورية إلى باب اليمن (حي الروضة).',
          distance: '2.5 كم',
          eta: 'يصل خلال 6 دقائق',
          price: '1,800 ر.ي',
          timeTag: 'الآن',
          icon: Icons.motorcycle_rounded,
          iconColor: AppColors.primary500,
          iconBgColor: AppColors.primary500.withOpacity(0.12),
        ),
        _buildInteractiveRequestCard(
          isDark: isDark,
          title: 'طلب توصيل طرد سريع',
          description: 'شحنة صغيرة مغلقة جاهزة للاستلام من شارع الزبيري والتوصيل إلى مستشفى الجمهوري.',
          distance: '4.8 كم',
          eta: 'استلام خلال 10 دقائق',
          price: '2,200 ر.ي',
          timeTag: 'قبل 15 دقيقة',
          icon: Icons.local_shipping_rounded,
          iconColor: AppColors.warning,
          iconBgColor: AppColors.warning.withOpacity(0.12),
        ),
      ],
    );
  }

  Widget _buildSystemUpdatesList(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      children: [
        _buildAlertCard(
          isDark: isDark,
          title: 'تحديث شروط الخدمة والعمولة',
          description: 'نود إعلام جميع كباتن لفة الأوفياء أنه تم تحديث نسبة العمولة لتصبح 8% فقط بدلاً من 10% لدعم كباتننا في اليمن.',
          timeTag: 'قبل ساعة',
          icon: Icons.shield_rounded,
          iconBg: AppColors.primary500.withOpacity(0.12),
          iconColor: AppColors.primary500,
        ),
        _buildAlertCard(
          isDark: isDark,
          title: 'صيانة خوادم النظام',
          description: 'تنبيه: سيتم إجراء أعمال صيانة دورية مجدولة لخوادم التطبيق يوم الجمعة القادم بين الساعة 2:00 صباحاً و3:00 صباحاً. قد تتأثر الخدمة مؤقتاً.',
          timeTag: 'أمس',
          icon: Icons.settings_rounded,
          iconBg: AppColors.gray500.withOpacity(0.12),
          iconColor: AppColors.gray600,
        ),
      ],
    );
  }

  Widget _buildGeneralAlertsList(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      children: [
        _buildAlertCard(
          isDark: isDark,
          title: 'مكافأة الإنجاز الأسبوعية 🎉',
          description: 'تهانينا كابتن أحمد! لقد حققت التارجت الأسبوعي بإكمال 40 لفة هذا الأسبوع. تمت إضافة 500 ر.ي مكافأة تشجيعية إلى محفظتك.',
          timeTag: 'أمس',
          icon: Icons.military_tech_rounded,
          iconBg: AppColors.success.withOpacity(0.12),
          iconColor: AppColors.success,
        ),
        _buildAlertCard(
          isDark: isDark,
          title: 'تقييم ركاب ممتاز',
          description: 'لقد حصلت على تقييم 5 نجوم من آخر 8 ركاب لك. نشكرك على معاملتك الراقية وأمانتك التي تمثل هوية لفة!',
          timeTag: 'قبل يومين',
          icon: Icons.star_rounded,
          iconBg: Colors.amber.withOpacity(0.12),
          iconColor: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildInteractiveRequestCard({
    required bool isDark,
    required String title,
    required String description,
    required String distance,
    required String eta,
    required String price,
    required String timeTag,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppSpacing.borderXL,
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withOpacity(isDark ? 0.0 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon and time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  AppSpacing.w12,
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ],
              ),
              Text(
                timeTag,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.gray500,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
            ],
          ),

          AppSpacing.h12,

          // Description content
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.gray600,
              height: 1.5,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),

          AppSpacing.h12,

          // Info Badges Row
          Row(
            children: [
              _buildSmallBadge(Icons.navigation_rounded, distance),
              AppSpacing.w8,
              _buildSmallBadge(Icons.timer_rounded, eta),
              const Spacer(),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary900,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
            ],
          ),

          AppSpacing.h16,

          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppSpacing.radiusMD,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _showTripAcceptanceNotification(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusMD),
                    ),
                    child: const Text(
                      'قبول الطلب والبدء',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ),
                ),
              ),
              AppSpacing.w10,
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? AppColors.white.withOpacity(0.12) : AppColors.gray300),
                      shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusMD),
                    ),
                    child: const Text(
                      'التفاصيل',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray600,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.gray500),
          AppSpacing.w4,
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.gray600,
              fontWeight: FontWeight.bold,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required bool isDark,
    required String title,
    required String description,
    required String timeTag,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppSpacing.borderLG,
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s8),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          AppSpacing.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                    Text(
                      timeTag,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.gray500,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ],
                ),
                AppSpacing.h6,
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.gray600,
                    height: 1.4,
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTripAcceptanceNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 4),
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            AppSpacing.w12,
            Expanded(
              child: Text(
                'تم قبول الطلب كابتن أحمد! جاري تحميل المسار والوجهة على الخريطة المباشرة.',
                style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
