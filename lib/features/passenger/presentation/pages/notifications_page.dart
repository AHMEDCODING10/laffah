import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Notification categories for filtering
enum NotificationCategory { rides, parcels, messages, offers }

/// Data model for notifications
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final NotificationCategory category;
  final IconData? icon;
  final Color? color;
  final String? captainName;
  final bool isUnread;
  final bool isToday;
  final String? routePath;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.category,
    this.icon,
    this.color,
    this.captainName,
    this.isUnread = false,
    this.isToday = true,
    this.routePath,
  });
}

/// NotificationsPage — Central hub for passenger notifications matching Stitch design.
/// Features 4 tabs (Rides, Parcels, Messages, Offers), relative time, red unread indicators,
/// captain message avatars, loyalty points card, and last week section.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // Mock Notification Data
  final List<NotificationModel> _allNotifications = [
    // ─── RIDES (الرحلات) ───
    NotificationModel(
      id: 'r1',
      title: 'وصول الكابتن',
      message: 'الكابتن أحمد محمد وصل الآن إلى موقع الانطلاق وبانتظارك.',
      time: 'منذ ٥ دقائق',
      category: NotificationCategory.rides,
      icon: Icons.directions_car_filled_rounded,
      color: AppColors.primary500,
      isUnread: true,
      isToday: true,
      routePath: LaffahRoutes.passengerRideTracking,
    ),
    NotificationModel(
      id: 'r2',
      title: 'رحلتك اكتملت بنجاح',
      message: 'نأمل أن تكون قد استمتعت برحلتك مع الكابتن محمد علي. لا تنسَ التقييم!',
      time: 'منذ ساعتين',
      category: NotificationCategory.rides,
      icon: Icons.check_circle_rounded,
      color: AppColors.success,
      isUnread: false,
      isToday: true,
      routePath: LaffahRoutes.passengerRideTracking,
    ),
    NotificationModel(
      id: 'r3',
      title: 'تم تأكيد طلب الرحلة',
      message: 'تم العثور على كابتن قريب وفي طريقه إليك الآن.',
      time: 'أمس، ٠٩:٣٠ م',
      category: NotificationCategory.rides,
      icon: Icons.local_taxi_rounded,
      color: AppColors.primary500,
      isUnread: false,
      isToday: false,
      routePath: LaffahRoutes.passengerRideTracking,
    ),

    // ─── PARCELS (الطرود) ───
    NotificationModel(
      id: 'p1',
      title: 'تسليم طرد بنجاح',
      message: 'تم توثيق تسليم الطرد رقم #LFX-782 بواسطة الكابتن وتوقيع المستلم.',
      time: 'منذ ٤٥ دقيقة',
      category: NotificationCategory.parcels,
      icon: Icons.all_inbox_rounded,
      color: AppColors.success,
      isUnread: true,
      isToday: true,
      routePath: LaffahRoutes.passengerParcelTracking,
    ),
    NotificationModel(
      id: 'p2',
      title: 'طردك في الطريق',
      message: 'الكابتن استلم المستندات وهو الآن متوجه نحو موقع التسليم بحدة.',
      time: 'منذ ٣ ساعات',
      category: NotificationCategory.parcels,
      icon: Icons.local_shipping_rounded,
      color: AppColors.warning,
      isUnread: false,
      isToday: true,
      routePath: LaffahRoutes.passengerParcelTracking,
    ),
    NotificationModel(
      id: 'p3',
      title: 'تأكيد شحنة طرد',
      message: 'تم تسجيل طلب إرسال طرد جديد بنجاح وفي انتظار قبول الكابتن.',
      time: 'منذ ٤ أيام',
      category: NotificationCategory.parcels,
      icon: Icons.inventory_2_rounded,
      color: AppColors.primary500,
      isUnread: false,
      isToday: false,
      routePath: LaffahRoutes.passengerParcelTracking,
    ),

    // ─── MESSAGES (الرسائل) ───
    NotificationModel(
      id: 'm1',
      title: 'أحمد محمد (كابتن)',
      message: 'أنا الآن بانتظارك عند مدخل المجمع الرئيسي بجانب البوابة الشرقية.',
      time: 'منذ ١٠ دقائق',
      category: NotificationCategory.messages,
      captainName: 'أحمد محمد',
      isUnread: true,
      isToday: true,
      routePath: LaffahRoutes.passengerRideTracking,
    ),
    NotificationModel(
      id: 'm2',
      title: 'خالد منصور (كابتن طرود)',
      message: 'وصلت إلى الموقع المحدد لاستلام الشحنة، يرجى التكرم بالنزول.',
      time: 'منذ ساعة',
      category: NotificationCategory.messages,
      captainName: 'خالد منصور',
      isUnread: false,
      isToday: true,
      routePath: LaffahRoutes.passengerParcelTracking,
    ),
    NotificationModel(
      id: 'm3',
      title: 'فريق دعم لَفَّة',
      message: 'تم معالجة استفسارك بشأن رصيد المحفظة وإضافة المبلغ المستحق.',
      time: 'منذ ٥ أيام',
      category: NotificationCategory.messages,
      icon: Icons.support_agent_rounded,
      color: AppColors.primary500,
      isUnread: false,
      isToday: false,
      routePath: LaffahRoutes.passengerSupportTickets,
    ),

    // ─── OFFERS (العروض) ───
    NotificationModel(
      id: 'o1',
      title: 'خصم 20% على رحلتك القادمة!',
      message: 'استخدم الكود LAFFAH20 واستمتع بتخفيض مُميز على مشوارك القادم.',
      time: 'منذ ساعتين',
      category: NotificationCategory.offers,
      icon: Icons.local_offer_rounded,
      color: Color(0xFF3B82F6),
      isUnread: true,
      isToday: true,
      routePath: LaffahRoutes.passengerPromoCode,
    ),
    NotificationModel(
      id: 'o2',
      title: 'عرض نهاية الأسبوع',
      message: 'شحن رصيد المحفظة بمبلغ 5000 ريال يمنحك 500 ريال بونص مجاني.',
      time: 'منذ ٤ ساعات',
      category: NotificationCategory.offers,
      icon: Icons.card_giftcard_rounded,
      color: Color(0xFF8B5CF6),
      isUnread: false,
      isToday: true,
      routePath: LaffahRoutes.passengerWallet,
    ),
    NotificationModel(
      id: 'o3',
      title: 'تحديث الأمان',
      message: 'تم تسجيل الدخول إلى حسابك من جهاز جديد في مدينة صنعاء.',
      time: 'منذ ٣ أيام',
      category: NotificationCategory.offers,
      icon: Icons.shield_rounded,
      color: AppColors.danger,
      isUnread: false,
      isToday: false,
      routePath: LaffahRoutes.helpCenter,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  NotificationCategory get _currentCategory {
    switch (_selectedTabIndex) {
      case 0:
        return NotificationCategory.rides;
      case 1:
        return NotificationCategory.parcels;
      case 2:
        return NotificationCategory.messages;
      case 3:
        return NotificationCategory.offers;
      default:
        return NotificationCategory.rides;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter notifications based on active tab
    final currentCat = _currentCategory;
    final categoryNotifications = _allNotifications.where((n) => n.category == currentCat).toList();
    final todayNotifications = categoryNotifications.where((n) => n.isToday).toList();
    final lastWeekNotifications = categoryNotifications.where((n) => !n.isToday).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.white : AppColors.gray900,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'الإشعارات',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: Column(
          children: [
            // ──────────────────────────────────────────
            // 1) FILTER TABS (الرحلات، الطرود، الرسائل، العروض)
            // ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.white.withValues(alpha: 0.08) : AppColors.gray200,
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary500,
                indicatorWeight: 3.0,
                labelColor: AppColors.primary500,
                unselectedLabelColor: isDark ? AppColors.gray400 : AppColors.gray600,
                labelStyle: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.directions_car_rounded, size: 18),
                    text: 'الرحلات',
                  ),
                  Tab(
                    icon: Icon(Icons.inventory_2_rounded, size: 18),
                    text: 'الطرود',
                  ),
                  Tab(
                    icon: Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    text: 'الرسائل',
                  ),
                  Tab(
                    icon: Icon(Icons.local_offer_outlined, size: 18),
                    text: 'العروض',
                  ),
                ],
              ),
            ),

            // ──────────────────────────────────────────
            // 2) SCROLLABLE NOTIFICATION LIST
            // ──────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s16),
                children: [
                  // ─── TODAY NOTIFICATIONS ───
                  if (todayNotifications.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
                      child: Text(
                        'اليوم',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                    ),
                    ...todayNotifications.map((n) => _buildNotificationCard(n, isDark)),
                    AppSpacing.h12,
                  ],

                  // ─── LOYALTY & ACTIVITY POINTS CARD ───
                  _buildLoyaltyPointsCard(isDark),
                  AppSpacing.h20,

                  // ─── LAST WEEK SECTION ───
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s10),
                    child: Text(
                      'الأسبوع الماضي',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ),
                  if (lastWeekNotifications.isNotEmpty)
                    ...lastWeekNotifications.map((n) => _buildNotificationCard(n, isDark))
                  else
                    _buildNotificationCard(
                      const NotificationModel(
                        id: 'lw_default',
                        title: 'تحديث الأمان',
                        message: 'تم تسجيل الدخول من جهاز جديد في صنعاء.',
                        time: 'منذ ٣ أيام',
                        category: NotificationCategory.offers,
                        icon: Icons.shield_rounded,
                        color: AppColors.primary500,
                        isUnread: false,
                        isToday: false,
                        routePath: LaffahRoutes.helpCenter,
                      ),
                      isDark,
                    ),

                  AppSpacing.h24,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // REUSABLE NOTIFICATION CARD (STITCH DESIGN)
  // ─────────────────────────────────────────────────────────────
  Widget _buildNotificationCard(NotificationModel item, bool isDark) {
    final Color badgeColor = item.color ?? AppColors.primary500;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: item.isUnread
              ? AppColors.primary500.withValues(alpha: 0.3)
              : (isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray200),
          width: item.isUnread ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppSpacing.radiusMD,
        child: InkWell(
          borderRadius: AppSpacing.radiusMD,
          onTap: () {
            if (item.routePath != null) {
              context.push(item.routePath!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) Leading Avatar / Circular Icon
                if (item.captainName != null)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary500.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppColors.primary500.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        item.captainName![0],
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon ?? Icons.notifications_rounded,
                      color: badgeColor,
                      size: 22,
                    ),
                  ),

                AppSpacing.w12,

                // 2) Content Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header line: Title + Time + Unread Red Dot
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 14,
                                fontWeight: item.isUnread ? FontWeight.w900 : FontWeight.w700,
                                color: isDark ? AppColors.white : AppColors.gray900,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                item.time,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.gray400 : AppColors.gray500,
                                ),
                              ),
                              if (item.isUnread) ...[
                                AppSpacing.w6,
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.danger,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                      AppSpacing.h6,

                      // Description Message
                      Text(
                        item.message,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LOYALTY & ACTIVITY POINTS CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildLoyaltyPointsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFFD97706), const Color(0xFFB45309)]
              : [AppColors.primary500, const Color(0xFFF59E0B)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: AppSpacing.radiusLG,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Points icon star badge
          Container(
            padding: const EdgeInsets.all(AppSpacing.s10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: AppColors.white,
              size: 26,
            ),
          ),
          AppSpacing.w12,
          // Points earned
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'النشاط والنقاط',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: AppColors.white,
                  ),
                ),
                AppSpacing.h2,
                Text(
                  '٤٥ نقطة مكافأة',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          // Vertical divider
          Container(
            height: 32,
            width: 1,
            color: AppColors.white.withValues(alpha: 0.3),
          ),
          AppSpacing.w12,
          // Last trip price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                'آخر رحلة',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: AppColors.white,
                ),
              ),
              AppSpacing.h2,
              Text(
                '٢,٤٠٠ ر.ي',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
