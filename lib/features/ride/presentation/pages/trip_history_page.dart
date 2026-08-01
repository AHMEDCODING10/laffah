import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../widgets/rating_and_support_dialog.dart';
import 'support_tickets_page.dart';

/// TripHistoryPage - Shown under the "طلباتي" (My Orders) tab.
/// Displays an elegant interactive tab bar with: Active, Scheduled, Past, and Cancelled orders.
/// Incorporates premium GlassBox design, route maps visual representation, and interactive support links.
class TripHistoryPage extends StatefulWidget {
  const TripHistoryPage({super.key});

  @override
  State<TripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Active / Current Trips
  final List<Map<String, dynamic>> _activeTrips = [
    {
      'id': 'active_1',
      'type': 'رحلة سريعة',
      'statusAr': 'في الطريق',
      'captainName': 'محمد علي',
      'vehicleModel': 'تويوتا كورولا',
      'vehiclePlate': '2022 • أبيض',
      'pickup': 'شارع حدة، أمام مركز الكميم',
      'dropoff': 'حي النهضة، شارع الستين',
      'captainImg': 'assets/images/captain_1.png',
      'isRide': true,
    },
    {
      'id': 'active_2',
      'type': 'إرسال طرد',
      'statusAr': 'جاري البحث عن كابتن',
      'orderNumber': 'رقم الطلب #LFX-782',
      'parcelContent': 'أوراق ومستندات رسمية',
      'isRide': false,
    }
  ];

  // Scheduled Trips
  final List<Map<String, dynamic>> _scheduledTrips = [
    {
      'id': 'scheduled_1',
      'type': 'رحلة مجدولة',
      'time': 'غداً، 08:00 ص',
      'pickup': 'بيت بوس، شارع الخمسين',
      'dropoff': 'مطار صنعاء الدولي',
      'vehicleType': 'سيارة لَفَّة سريع',
      'estimatedFare': 2400.0,
    }
  ];

  // Past / Previous Trips
  final List<Map<String, dynamic>> _pastTrips = [
    {
      'id': 'past_1',
      'type': 'رحلة سريعة',
      'date': '12 أكتوبر 2025 • 10:30 ص',
      'captainName': 'أحمد محمد',
      'vehicleModel': 'تويوتا كورولا',
      'vehiclePlate': '77213',
      'pickup': 'صنعاء مول، شارع حدة',
      'dropoff': 'شارع الزبيري، برج التسهيلات',
      'fare': 1200.0,
      'isRide': true,
    },
    {
      'id': 'past_2',
      'type': 'توصيل طرد',
      'date': '09 أكتوبر 2025 • 03:45 م',
      'captainName': 'أحمد منصور',
      'vehicleModel': 'دراجة نارية (كاديلات)',
      'vehiclePlate': '99432',
      'pickup': 'بيت بوس، صنعاء',
      'dropoff': 'شارع الستين، صنعاء',
      'fare': 800.0,
      'isRide': false,
    },
    {
      'id': 'past_3',
      'type': 'رحلة سريعة',
      'date': '08 أكتوبر 2025 • 09:00 ص',
      'captainName': 'محمد الغيلي',
      'vehicleModel': 'كيا سيراتو',
      'vehiclePlate': '82390',
      'pickup': 'بوابة جامعة صنعاء الرئيسية',
      'dropoff': 'صنعاء مول، شارع حدة',
      'fare': 1500.0,
      'isRide': true,
    }
  ];

  // Cancelled Trips
  final List<Map<String, dynamic>> _cancelledTrips = [
    {
      'id': 'cancelled_1',
      'type': 'توصيل طرد',
      'date': '05 أكتوبر 2025 • 11:15 ص',
      'reason': 'تم الإلغاء بواسطة المستخدم',
      'pickup': 'شارع حدة، مركز الكميم',
      'dropoff': 'الدائري، أمام الجامعة القديمة',
    }
  ];

  void _showRatingAndFeedbackDialog(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) => RatingAndSupportDialog(
        tripId: trip['id'] ?? 'unknown',
        captainName: trip['captainName'] ?? 'كابتن لَفَّة',
        tripType: trip['type'] ?? 'رحلة سريعة',
        fare: (trip['fare'] as num?)?.toDouble() ?? 1000.0,
        onOpenSupportTicket: () {
          // Open support tickets page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SupportTicketsPage(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark
            ? AppColors.backgroundDark.withValues(alpha: 0.95)
            : AppColors.backgroundLight.withValues(alpha: 0.95),
        elevation: 0,
        titleSpacing: 0,
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: Row(
              children: [
                // Hamburger Menu Button
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary500.withValues(alpha: 0.2),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.primary500,
                      size: 24,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                AppSpacing.w12,
                Text(
                  'رحلاتي وحجوزاتي',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                const Spacer(),
                // Notifications Bell
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.white.withValues(alpha: 0.08)
                          : AppColors.gray200,
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: isDark ? AppColors.gray400 : AppColors.gray700,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary500,
          unselectedLabelColor: isDark ? AppColors.gray500 : AppColors.gray500,
          indicatorColor: AppColors.primary500,
          indicatorWeight: 3.0,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'IBM Plex Sans Arabic',
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'IBM Plex Sans Arabic',
          ),
          tabs: const [
            Tab(text: 'الحالية'),
            Tab(text: 'المجدولة'),
            Tab(text: 'السابقة'),
            Tab(text: 'الملغاة'),
          ],
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildActiveTab(isDark),
            _buildScheduledTab(isDark),
            _buildPastTab(isDark),
            _buildCancelledTab(isDark),
          ],
        ),
      ),
    );
  }

  // Tab View 1: Active ("الحالية")
  Widget _buildActiveTab(bool isDark) {
    if (_activeTrips.isEmpty) {
      return _buildEmptyState('لا توجد طلبات نشطة حالياً');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, 96),
      itemCount: _activeTrips.length,
      itemBuilder: (context, index) {
        final item = _activeTrips[index];
        final isRide = item['isRide'] ?? true;

        return GlassBox(
          margin: const EdgeInsets.only(bottom: AppSpacing.s16),
          borderRadius: AppSpacing.radiusLG,
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header: Type, Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s8),
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isRide ? Icons.directions_car_filled_rounded : Icons.inventory_2_rounded,
                          color: AppColors.primary500,
                          size: 18,
                        ),
                      ),
                      AppSpacing.w12,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['type'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                          if (!isRide)
                            Text(
                              item['orderNumber'] ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'IBM Plex Sans Arabic',
                                color: isDark ? AppColors.gray500 : AppColors.gray500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
                    decoration: BoxDecoration(
                      color: isRide 
                          ? AppColors.primary500.withOpacity(0.15) 
                          : AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isRide 
                            ? AppColors.primary500.withOpacity(0.3) 
                            : AppColors.warning.withOpacity(0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      item['statusAr'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: isRide ? AppColors.primary500 : AppColors.primary800,
                      ),
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
                child: Divider(height: 1),
              ),

              // Route details if Ride
              if (isRide) ...[
                _buildRouteRow(Icons.radio_button_checked_rounded, AppColors.success, 'نقطة الانطلاق', item['pickup']),
                AppSpacing.h12,
                _buildRouteRow(Icons.place_rounded, AppColors.danger, 'الوجهة', item['dropoff']),
              ] else ...[
                // Parcel Details
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray100,
                        borderRadius: AppSpacing.borderSM,
                      ),
                      child: const Icon(Icons.mark_as_unread_rounded, size: 20, color: AppColors.primary500),
                    ),
                    AppSpacing.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'محتوى الطرد',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBM Plex Sans Arabic',
                              color: AppColors.gray500,
                            ),
                          ),
                          Text(
                            item['parcelContent'] ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
                child: Divider(height: 1),
              ),

              // Footer: Driver Info or Action Buttons
              if (isRide)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary300,
                          child: const Icon(Icons.person, color: AppColors.white),
                        ),
                        AppSpacing.w12,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['captainName'],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'IBM Plex Sans Arabic',
                              ),
                            ),
                            Text(
                              item['vehicleModel'] + ' • ' + item['vehiclePlate'],
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'IBM Plex Sans Arabic',
                                color: isDark ? AppColors.gray400 : AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      height: 38,
                      width: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.primary500,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.phone_rounded, color: AppColors.white, size: 18),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('جاري الاتصال بالكابتن...', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                              backgroundColor: AppColors.primary500,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('لا يمكن التعديل أثناء البحث عن كابتن', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isDark ? AppColors.white.withOpacity(0.12) : AppColors.gray400),
                          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderMD),
                        ),
                        child: Text(
                          'تعديل الطلب',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: isDark ? AppColors.white : AppColors.gray800,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.w12,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _activeTrips.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إلغاء الطلب بنجاح', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger.withOpacity(0.12),
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderMD),
                        ),
                        child: const Text(
                          'إلغاء الطلب',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  // Tab View 2: Scheduled ("المجدولة")
  Widget _buildScheduledTab(bool isDark) {
    if (_scheduledTrips.isEmpty) {
      return _buildEmptyState('لا توجد رحلات مجدولة');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, 96),
      itemCount: _scheduledTrips.length,
      itemBuilder: (context, index) {
        final item = _scheduledTrips[index];
        return GlassBox(
          margin: const EdgeInsets.only(bottom: AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s8),
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calendar_today_rounded, color: AppColors.primary500, size: 18),
                      ),
                      AppSpacing.w12,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['type'],
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'IBM Plex Sans Arabic'),
                          ),
                          Text(
                            item['time'],
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary500, fontFamily: 'IBM Plex Sans Arabic'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '${item['estimatedFare'].toStringAsFixed(0)} ريال مقدراً',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: AppColors.primary500,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
                child: Divider(height: 1),
              ),
              _buildRouteRow(Icons.radio_button_checked_rounded, AppColors.success, 'نقطة الانطلاق', item['pickup']),
              AppSpacing.h12,
              _buildRouteRow(Icons.place_rounded, AppColors.danger, 'الوجهة', item['dropoff']),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _scheduledTrips.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إلغاء جدولة المشوار', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.danger),
                        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderMD),
                      ),
                      child: const Text(
                        'إلغاء المشوار المجدول',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger, fontFamily: 'IBM Plex Sans Arabic'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Tab View 3: Past ("السابقة")
  Widget _buildPastTab(bool isDark) {
    if (_pastTrips.isEmpty) {
      return _buildEmptyState('لا توجد رحلات سابقة');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, 96),
      itemCount: _pastTrips.length,
      itemBuilder: (context, index) {
        final item = _pastTrips[index];
        final isRide = item['isRide'] ?? true;

        return GlassBox(
          margin: const EdgeInsets.only(bottom: AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Type, Fare
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s8),
                        decoration: BoxDecoration(
                          color: isRide 
                              ? AppColors.primary500.withOpacity(0.1) 
                              : AppColors.info.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isRide ? Icons.directions_car_filled_rounded : Icons.inventory_2_rounded,
                          color: isRide ? AppColors.primary500 : AppColors.info,
                          size: 18,
                        ),
                      ),
                      AppSpacing.w12,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['type'],
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'IBM Plex Sans Arabic'),
                          ),
                          Text(
                            item['date'],
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'IBM Plex Sans Arabic',
                              color: isDark ? AppColors.gray500 : AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '${item['fare'].toStringAsFixed(0)} ريال',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: AppColors.primary500,
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
                child: Divider(height: 1),
              ),

              // Routes (From/To)
              _buildRouteRow(Icons.radio_button_checked_rounded, AppColors.success, 'من', item['pickup']),
              AppSpacing.h12,
              _buildRouteRow(Icons.place_rounded, AppColors.danger, 'إلى', item['dropoff']),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
                child: Divider(height: 1),
              ),

              // Captain details + Rate Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.gray400,
                        child: Icon(Icons.person, color: AppColors.white, size: 16),
                      ),
                      AppSpacing.w12,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['captainName'],
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic'),
                          ),
                          Text(
                            item['vehicleModel'] + ' • ' + item['vehiclePlate'],
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'IBM Plex Sans Arabic',
                              color: isDark ? AppColors.gray500 : AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Opened Support ticket navigator
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.info, size: 20),
                        tooltip: 'تواصل مع الدعم',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SupportTicketsPage(),
                            ),
                          );
                        },
                      ),
                      AppSpacing.w4,
                      // Rate button trigger
                      ElevatedButton.icon(
                        onPressed: () => _showRatingAndFeedbackDialog(item),
                        icon: const Icon(Icons.star_rounded, size: 14, color: AppColors.white),
                        label: const Text(
                          'تقييم الطلب',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: AppColors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSM),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Tab View 4: Cancelled ("الملغاة")
  Widget _buildCancelledTab(bool isDark) {
    if (_cancelledTrips.isEmpty) {
      return _buildEmptyState('لا يوجد طلبات ملغاة');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, 96),
      itemCount: _cancelledTrips.length,
      itemBuilder: (context, index) {
        final item = _cancelledTrips[index];
        return GlassBox(
          margin: const EdgeInsets.only(bottom: AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s8),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cancel_rounded, color: AppColors.danger, size: 18),
                      ),
                      AppSpacing.w12,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['type'],
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'IBM Plex Sans Arabic'),
                          ),
                          Text(
                            item['date'],
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'IBM Plex Sans Arabic',
                              color: isDark ? AppColors.gray500 : AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ملغي',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.danger,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
                child: Divider(height: 1),
              ),
              _buildRouteRow(Icons.radio_button_checked_rounded, AppColors.success, 'من', item['pickup']),
              AppSpacing.h12,
              _buildRouteRow(Icons.place_rounded, AppColors.danger, 'إلى', item['dropoff']),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
                child: Divider(height: 1),
              ),
              Text(
                'السبب: ${item['reason']}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.danger,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper row builder for route pins and text
  Widget _buildRouteRow(IconData icon, Color iconColor, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: iconColor),
        AppSpacing.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray500,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Empty state fallback widget
  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: AppColors.primary500.withOpacity(0.3)),
          AppSpacing.h16,
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'IBM Plex Sans Arabic',
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}
