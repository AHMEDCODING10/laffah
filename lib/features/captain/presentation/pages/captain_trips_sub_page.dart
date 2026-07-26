import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import 'widgets/captain_trip_details_sheet.dart';

/// CaptainTripsSubPage - Interactive Sub-Page for Captain's Trip History & Active Orders.
/// Features instant real-time search filtering, status filter chips, authentic Sana'a locations,
/// and rich trip detail bottom sheets.
class CaptainTripsSubPage extends StatefulWidget {
  const CaptainTripsSubPage({super.key});

  @override
  State<CaptainTripsSubPage> createState() => _CaptainTripsSubPageState();
}

class _CaptainTripsSubPageState extends State<CaptainTripsSubPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'الكل'; // 'الكل', 'قيد التنفيذ', 'تم الانتهاء', 'ملغاة'

  // Authentic Sana'a Trips Data List
  final List<Map<String, dynamic>> _allTrips = [
    {
      'id': 'LF-88293',
      'status': 'قيد التنفيذ',
      'statusColor': AppColors.warning,
      'passengerName': 'سارة العامري',
      'passengerPhone': '+967 777 123 456',
      'rating': 4.9,
      'pickup': 'شارع الستين - أمام مستشفى آزال، صنعاء',
      'dropoff': 'مول العرب - شارع حدة، صنعاء',
      'price': '2,400 ر.ي',
      'grossFare': 2400.0,
      'date': 'اليوم، 10:30 ص',
      'distance': '4.5 كم',
      'duration': '12 دقيقة',
      'paymentMethod': 'نقداً (Cash)',
    },
    {
      'id': 'LF-88290',
      'status': 'تم الانتهاء',
      'statusColor': AppColors.success,
      'passengerName': 'أحمد منصور',
      'passengerPhone': '+967 771 999 888',
      'rating': 4.8,
      'pickup': 'شارع حدة - أمام مركز الكميم، صنعاء',
      'dropoff': 'جامعة صنعاء - البوابة الرئيسية، صنعاء',
      'price': '1,800 ر.ي',
      'grossFare': 1800.0,
      'date': 'اليوم، 09:15 ص',
      'distance': '3.4 كم',
      'duration': '9 دقائق',
      'paymentMethod': 'محفظة لَفَّة',
    },
    {
      'id': 'LF-88285',
      'status': 'تم الانتهاء',
      'statusColor': AppColors.success,
      'passengerName': 'خالد العنسي',
      'passengerPhone': '+967 773 444 555',
      'rating': 5.0,
      'pickup': 'ميدان التحرير - صنعاء القديمة',
      'dropoff': 'جبل نقم - شارع الأربعين، صنعاء',
      'price': '2,100 ر.ي',
      'grossFare': 2100.0,
      'date': 'أمس، 08:00 م',
      'distance': '5.2 كم',
      'duration': '16 دقيقة',
      'paymentMethod': 'نقداً (Cash)',
    },
    {
      'id': 'LF-88270',
      'status': 'ملغاة',
      'statusColor': AppColors.danger,
      'passengerName': 'محمد علي',
      'passengerPhone': '+967 770 111 222',
      'rating': 4.7,
      'pickup': 'الصافية - خلف مبنى البريد العام، صنعاء',
      'dropoff': 'حدة أسطنبول - أمام المطعم التركي، صنعاء',
      'price': '1,500 ر.ي',
      'grossFare': 1500.0,
      'date': 'أمس، 04:30 م',
      'distance': '2.8 كم',
      'duration': '7 دقائق',
      'paymentMethod': 'نقداً (Cash)',
    },
    {
      'id': 'LF-88262',
      'status': 'تم الانتهاء',
      'statusColor': AppColors.success,
      'passengerName': 'ياسر الحداد',
      'passengerPhone': '+967 775 666 777',
      'rating': 4.9,
      'pickup': 'شارع الزبيري - تقاطع جولة كنعان، صنعاء',
      'dropoff': 'السيلية - قرب باب اليمن، صنعاء',
      'price': '2,200 ر.ي',
      'grossFare': 2200.0,
      'date': 'منذ يومين، 02:15 م',
      'distance': '4.1 كم',
      'duration': '11 دقيقة',
      'paymentMethod': 'محفظة لَفَّة',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTrips {
    return _allTrips.where((trip) {
      // 1. Filter by Status
      if (_selectedStatusFilter != 'الكل') {
        if (trip['status'] != _selectedStatusFilter) {
          return false;
        }
      }

      // 2. Filter by Search Query
      if (_searchQuery.trim().isEmpty) return true;

      final query = _searchQuery.trim().toLowerCase();
      final id = (trip['id'] as String).toLowerCase();
      final passenger = (trip['passengerName'] as String).toLowerCase();
      final pickup = (trip['pickup'] as String).toLowerCase();
      final dropoff = (trip['dropoff'] as String).toLowerCase();

      return id.contains(query) ||
          passenger.contains(query) ||
          pickup.contains(query) ||
          dropoff.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredTrips;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'سجل الرحلات والمشاوير',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'IBM Plex Sans Arabic',
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Search & Filter Header Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Column(
                children: [
                  // Functional Real-time Search TextField
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141822).withValues(alpha: 0.8)
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.gray200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 13.5,
                        color: isDark ? Colors.white : AppColors.gray900,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'ابحث برقم الرحلة، اسم الراكب، أو الشارع...',
                        hintStyle: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12.5,
                          color: AppColors.gray500,
                        ),
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFF6B00)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.gray500),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),

                  AppSpacing.h12,

                  // Filter Chips Bar (All, In Progress, Completed, Cancelled)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('الكل', _selectedStatusFilter == 'الكل', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('قيد التنفيذ', _selectedStatusFilter == 'قيد التنفيذ', isDark, color: AppColors.warning),
                        const SizedBox(width: 8),
                        _buildFilterChip('تم الانتهاء', _selectedStatusFilter == 'تم الانتهاء', isDark, color: AppColors.success),
                        const SizedBox(width: 8),
                        _buildFilterChip('ملغاة', _selectedStatusFilter == 'ملغاة', isDark, color: AppColors.danger),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.h16,

            // Trips List or Empty Search View
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90), // Extra space for floating bottom bar
                      itemCount: filtered.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final trip = filtered[index];
                        return _buildTripCard(context, trip, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, bool isDark, {Color? color}) {
    final chipColor = color ?? const Color(0xFFFF6B00);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedStatusFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.16)
              : (isDark ? const Color(0xFF141822).withValues(alpha: 0.5) : AppColors.gray100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? chipColor
                : (isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.gray200),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
            color: isSelected
                ? chipColor
                : (isDark ? AppColors.gray400 : AppColors.gray600),
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Map<String, dynamic> trip, bool isDark) {
    final String status = trip['status'];
    final Color statusColor = trip['statusColor'];

    return GestureDetector(
      onTap: () => CaptainTripDetailsSheet.show(context, trip),
      child: GlassBox(
        margin: const EdgeInsets.only(bottom: AppSpacing.s12),
        borderRadius: AppSpacing.radiusLG,
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: ID & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, size: 16, color: Color(0xFFFF6B00)),
                    const SizedBox(width: 6),
                    Text(
                      'رقم الرحلة: ${trip['id']}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? AppColors.gray400 : AppColors.gray700,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.h12,

            // Passenger Name
            Row(
              children: [
                const Icon(Icons.person_rounded, size: 15, color: AppColors.gray500),
                const SizedBox(width: 6),
                Text(
                  'الراكب: ${trip['passengerName']}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: isDark ? Colors.white : AppColors.gray900,
                  ),
                ),
              ],
            ),

            AppSpacing.h8,

            // Route representation
            Row(
              children: [
                const Icon(Icons.circle_rounded, color: Colors.green, size: 12),
                AppSpacing.w10,
                Expanded(
                  child: Text(
                    trip['pickup'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Container(
                width: 1.5,
                height: 10,
                color: isDark ? Colors.white24 : AppColors.gray300,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 12),
                AppSpacing.w10,
                Expanded(
                  child: Text(
                    trip['dropoff'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),

            // Price, Date & Details Hint
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trip['price'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFF6B00),
                    fontWeight: FontWeight.w900,
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
                Row(
                  children: [
                    Text(
                      trip['date'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.gray500,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_back_ios_rounded, size: 12, color: AppColors.gray500),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Color(0xFFFF6B00),
              ),
            ),
            AppSpacing.h16,
            Text(
              'لا توجد رحلات مطابقة لبحثك',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.gray900,
              ),
            ),
            AppSpacing.h6,
            const Text(
              'جرّب البحث باسم آخر أو اختر "الكل" لإعادة عرض كافة الرحلات.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
            AppSpacing.h20,
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedStatusFilter = 'الكل';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'عرض كل الرحلات',
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
