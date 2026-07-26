import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'captain_navigation_page.dart';
import 'widgets/captain_reject_reason_dialog.dart';
import 'widgets/captain_order_details_dialog.dart';

/// CaptainNotificationsPage — Dynamic notification logs, system alerts, and nearby trip requests panel.
/// Fully customized for Sana'a motorcycle rides & parcel express delivery, supporting multi-stop trips,
/// direct navigation acceptance, reject reason dialogs, and mark-all-as-read state.
class CaptainNotificationsPage extends StatefulWidget {
  const CaptainNotificationsPage({super.key});

  @override
  State<CaptainNotificationsPage> createState() => _CaptainNotificationsPageState();
}

class _CaptainNotificationsPageState extends State<CaptainNotificationsPage> {
  int _activeCategoryIndex = 0;
  bool _isAllRead = false;

  final List<String> _categories = ['الطلبات الجديدة ⚡', 'تحديثات النظام 📢', 'التنبيهات 🔔'];

  // Dynamic Nearby Orders List for Sana'a
  late List<Map<String, dynamic>> _nearbyOrders;

  // System Updates List
  final List<Map<String, dynamic>> _systemUpdates = [
    {
      'title': 'تحديث عمولة منصة لَفَّة ⚡',
      'description': 'نود إعلام كباتننا الأوفياء في صنعاء أنه تم تثبيت نسبة العمولة 10% فقط لدعم الدراجات النارية في اليمن.',
      'timeTag': 'قبل ساعة',
      'icon': Icons.shield_rounded,
      'isRead': false,
    },
    {
      'title': 'صيانة خوادم النظام الدورية',
      'description': 'تنبيه: ستجرى صيانة دورية مجدولة لخوادم التطبيق يوم الجمعة القادم بين الساعة 2:00 ص و 3:00 ص.',
      'timeTag': 'أمس',
      'icon': Icons.settings_rounded,
      'isRead': true,
    },
  ];

  // General Alerts List
  final List<Map<String, dynamic>> _generalAlerts = [
    {
      'title': 'تذكير السلامة المرورية 🏍️',
      'description': 'عزيزي الكابتن: يرجى دائماً ارتداء الخوذة الواقية والتأكد من استخدام الأضواء الخافتة أثناء القيادة ليلاً في شوارع صنعاء.',
      'timeTag': 'اليوم',
      'icon': Icons.two_wheeler_rounded,
      'isRead': false,
    },
    {
      'title': 'تقييم راكب ممتاز 🌟',
      'description': 'حصلت على تقييم 5 نجوم من الراكبة "سارة العامري" مع تعليق: "كابتن محترم وسريع جداً".',
      'timeTag': 'أمس',
      'icon': Icons.star_rounded,
      'isRead': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _nearbyOrders = [
      {
        'id': 'LF-88293',
        'title': 'طلب لَفَّة مشوار جديد',
        'passengerName': 'محمد المقطري',
        'passengerPhone': '+967 777 123 456',
        'passengerRating': 4.9,
        'description': 'العميل بانتظارك بالقرب من شارع المطار يطلب رحلة فورية إلى باب اليمن (صنعاء القديمة).',
        'pickup': 'حي الروضة - شارع المطار، صنعاء',
        'dropoff': 'باب اليمن - صنعاء القديمة',
        'distance': '3.5 كم',
        'eta': 'يصل خلال 8 دقائق',
        'duration': '8 دقائق',
        'price': '1,800 ر.ي',
        'grossFare': 1800.0,
        'timeTag': 'الآن',
        'isParcel': false,
      },
      {
        'id': 'LF-88290',
        'title': 'مشوار متعدد المحطات والتوقفات ⚡',
        'passengerName': 'المهندس ياسين',
        'passengerPhone': '+967 771 999 888',
        'passengerRating': 4.8,
        'description': 'مشوار يتضمن توقفين: السوبرماركت للشراء ثم الصيدلية ثم التوصيل للمنزل في حدة.',
        'pickup': 'شارع الستين - أمام مستشفى آزال',
        'dropoff': 'حدة - قرب مركز الكميم',
        'stops': [
          'توقف 1: سوبرماركت الهدى (شارع الستين)',
          'توقف 2: صيدلية النهدي (جولة حدة)',
        ],
        'distance': '5.8 كم',
        'eta': 'استلام خلال 12 دقيقة',
        'duration': '18 دقيقة',
        'price': '2,800 ر.ي',
        'grossFare': 2800.0,
        'timeTag': 'قبل 5 دقائق',
        'isParcel': false,
      },
      {
        'id': 'LF-88285',
        'title': 'طلب توصيل طرد سريع 📦',
        'passengerName': 'مكتبة الجيل الجديد',
        'passengerPhone': '+967 773 444 555',
        'passengerRating': 5.0,
        'description': 'شحنة مغلقة بحجم صغير جاهزة للاستلام من شارع الزبيري والتوصيل إلى المستشفى الجمهوري.',
        'pickup': 'شارع الزبيري - تقاطع جولة كنعان',
        'dropoff': 'المستشفى الجمهوري - شارع باب اليمن',
        'distance': '4.8 كم',
        'eta': 'استلام خلال 10 دقائق',
        'duration': '10 دقائق',
        'price': '2,200 ر.ي',
        'grossFare': 2200.0,
        'timeTag': 'قبل 15 دقيقة',
        'isParcel': true,
      },
    ];
  }

  void _acceptAndNavigate(Map<String, dynamic> order) {
    HapticFeedback.heavyImpact();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaptainNavigationPage(
          tripId: order['id'] ?? 'LF-88293',
          passengerName: order['passengerName'] ?? 'الراكب',
          passengerPhone: order['passengerPhone'] ?? '+967 777 000 000',
          passengerRating: (order['passengerRating'] as num?)?.toDouble() ?? 4.9,
          pickup: order['pickup'] ?? 'الاستلام',
          dropoff: order['dropoff'] ?? 'الوصول',
          fare: (order['grossFare'] as num?)?.toDouble() ?? 1800.0,
          distance: order['distance'] ?? '3.5 كم',
          duration: order['duration'] ?? '8 دقائق',
        ),
      ),
    );
  }

  void _rejectOrder(Map<String, dynamic> order) {
    CaptainRejectReasonDialog.show(
      context: context,
      orderTitle: order['title'] ?? 'الطلب',
      onConfirmReject: (reason) {
        setState(() {
          _nearbyOrders.removeWhere((o) => o['id'] == order['id']);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            content: Text(
              'تم رفض الطلب (${order['id']}) بسبب: "$reason".',
              style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        );
      },
    );
  }

  void _markAllAsRead() {
    HapticFeedback.lightImpact();
    setState(() {
      _isAllRead = true;
      for (var u in _systemUpdates) {
        u['isRead'] = true;
      }
      for (var a in _generalAlerts) {
        a['isRead'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.success,
        content: Text(
          'تم تحديد جميع التنبيهات كمقروءة بنجاح ✔️',
          style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'التنبيهات والطلبات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'IBM Plex Sans Arabic',
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.done_all_rounded,
              color: _isAllRead ? AppColors.gray500 : const Color(0xFFFF6B00),
            ),
            tooltip: 'تحديد الكل كمقروء',
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Segmented Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141822).withValues(alpha: 0.8)
                      : AppColors.gray100,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: List.generate(_categories.length, (index) {
                    final isSelected = _activeCategoryIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _activeCategoryIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF6B00)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _categories[index],
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.gray400 : AppColors.gray600),
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

            AppSpacing.h8,

            // Category Tab View Content
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
    if (_nearbyOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.success),
            AppSpacing.h12,
            Text(
              'لا توجد طلبات جديدة قريبة حالياً',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'سيتم إشعارك فور ورود أي مشوار جديد في صنعاء.',
              style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 11.5, color: AppColors.gray500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90), // Bottom padding for floating bar
      itemCount: _nearbyOrders.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final order = _nearbyOrders[index];
        return _buildInteractiveRequestCard(context, order, isDark);
      },
    );
  }

  Widget _buildInteractiveRequestCard(BuildContext context, Map<String, dynamic> order, bool isDark) {
    final bool isParcel = order['isParcel'] == true;
    final List<String> stops = (order['stops'] as List<dynamic>?)?.cast<String>() ?? [];
    final bool isMultiStop = stops.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s14),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF141822).withValues(alpha: 0.9)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isMultiStop
              ? const Color(0xFFFF6B00).withValues(alpha: 0.4)
              : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06)),
          width: isMultiStop ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B00).withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isParcel ? Icons.inventory_2_rounded : Icons.two_wheeler_rounded,
                      size: 18,
                      color: const Color(0xFFFF6B00),
                    ),
                  ),
                  AppSpacing.w10,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['title'] ?? '',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: isDark ? Colors.white : AppColors.gray900,
                        ),
                      ),
                      if (isMultiStop)
                        const Text(
                          'توقفات متعددة',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6B00),
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Text(
                order['timeTag'] ?? '',
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.gray500,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
            ],
          ),

          AppSpacing.h10,

          Text(
            order['description'] ?? '',
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.gray600,
              height: 1.4,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),

          AppSpacing.h12,

          // Info Badges Row & Price
          Row(
            children: [
              _buildSmallBadge(isDark, Icons.navigation_rounded, order['distance'] ?? ''),
              AppSpacing.w8,
              _buildSmallBadge(isDark, Icons.timer_rounded, order['eta'] ?? ''),
              const Spacer(),
              Text(
                order['price'] ?? '',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFF6B00),
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
            ],
          ),

          AppSpacing.h16,

          // Ergonomic Action Buttons Row (Accept, Details, Reject)
          Row(
            children: [
              // Reject Button (Fixed 42px width)
              SizedBox(
                width: 42,
                height: 44,
                child: IconButton(
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: AppColors.danger.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.close_rounded, color: AppColors.danger, size: 20),
                  tooltip: 'رفض الطلب',
                  onPressed: () => _rejectOrder(order),
                ),
              ),

              const SizedBox(width: 8),

              // Details Button
              Expanded(
                flex: 12,
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      CaptainOrderDetailsDialog.show(
                        context: context,
                        order: order,
                        onAccept: () => _acceptAndNavigate(order),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      foregroundColor: isDark ? AppColors.gray300 : AppColors.gray700,
                      side: BorderSide(color: isDark ? Colors.white24 : AppColors.gray300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'التفاصيل',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Accept Button
              Expanded(
                flex: 20,
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptAndNavigate(order),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.flash_on_rounded, size: 16),
                    label: const Text(
                      'قبول والبدء',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
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

  Widget _buildSmallBadge(bool isDark, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.gray500),
          AppSpacing.w4,
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
              fontWeight: FontWeight.bold,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemUpdatesList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
      itemCount: _systemUpdates.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = _systemUpdates[index];
        return _buildAlertCard(
          isDark: isDark,
          title: item['title'],
          description: item['description'],
          timeTag: item['timeTag'],
          icon: item['icon'],
          iconBg: const Color(0xFFFF6B00).withValues(alpha: 0.12),
          iconColor: const Color(0xFFFF6B00),
        );
      },
    );
  }

  Widget _buildGeneralAlertsList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
      itemCount: _generalAlerts.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = _generalAlerts[index];
        return _buildAlertCard(
          isDark: isDark,
          title: item['title'],
          description: item['description'],
          timeTag: item['timeTag'],
          icon: item['icon'],
          iconBg: AppColors.success.withValues(alpha: 0.12),
          iconColor: AppColors.success,
        );
      },
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
        color: isDark ? const Color(0xFF141822).withValues(alpha: 0.9) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
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
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: isDark ? Colors.white : AppColors.gray900,
                      ),
                    ),
                    Text(
                      timeTag,
                      style: const TextStyle(
                        fontSize: 9.5,
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
}
