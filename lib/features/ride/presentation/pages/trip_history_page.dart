import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/laffah_app_bar.dart';
import '../../data/datasources/fake_trip_history_repository.dart';
import '../widgets/passenger/cards/trip_history_cards.dart';

/// TripHistoryPage — Passenger order & ride history page with 4 tabs:
/// (Active, Scheduled, Past, Cancelled).
/// Refactored for Clean Architecture & Backend readiness.
class TripHistoryPage extends StatefulWidget {
  const TripHistoryPage({super.key});

  @override
  State<TripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late final List<Map<String, dynamic>> _activeTrips;
  late final List<Map<String, dynamic>> _scheduledTrips;
  late final List<Map<String, dynamic>> _pastTrips;
  late final List<Map<String, dynamic>> _cancelledTrips;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);

    _activeTrips = FakeTripHistoryRepository.getActiveTrips();
    _scheduledTrips = FakeTripHistoryRepository.getScheduledTrips();
    _pastTrips = FakeTripHistoryRepository.getPastTrips();
    _cancelledTrips = FakeTripHistoryRepository.getCancelledTrips();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: const LaffahAppBar(title: 'رحلاتي وحجوزاتي'),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s8,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                borderRadius: AppSpacing.borderLG,
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primary500,
                  borderRadius: AppSpacing.borderLG,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: AppColors.white,
                unselectedLabelColor:
                    isDark ? AppColors.white : AppColors.black,
                labelStyle: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                tabs: const [
                  Tab(text: 'الحالية'),
                  Tab(text: 'المجدولة'),
                  Tab(text: 'السابقة'),
                  Tab(text: 'الملغاة'),
                ],
              ),
            ),
            Expanded(
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
          ],
        ),
      ),
    );
  }

  // Tab View 1: Active ("الحالية")
  Widget _buildActiveTab(bool isDark) {
    if (_activeTrips.isEmpty) {
      return _buildEmptyState('لا توجد طلبات أو رحلات نشطة حالياً');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, 96),
      itemCount: _activeTrips.length,
      itemBuilder: (context, index) {
        final item = _activeTrips[index];
        return ActiveTripCard(
          item: item,
          isDark: isDark,
          onCancel: () {
            setState(() {
              _activeTrips.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'تم إلغاء الطلب بنجاح',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
                ),
                backgroundColor: AppColors.danger,
              ),
            );
          },
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
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, 96),
      itemCount: _scheduledTrips.length,
      itemBuilder: (context, index) {
        final item = _scheduledTrips[index];
        return ScheduledTripCard(
          item: item,
          isDark: isDark,
          onCancel: () {
            setState(() {
              _scheduledTrips.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'تم إلغاء جدولة المشوار',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
                ),
                backgroundColor: AppColors.danger,
              ),
            );
          },
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
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, 96),
      itemCount: _pastTrips.length,
      itemBuilder: (context, index) {
        final item = _pastTrips[index];
        return PastTripCard(
          item: item,
          isDark: isDark,
        );
      },
    );
  }

  // Tab View 4: Cancelled ("الملغاة")
  Widget _buildCancelledTab(bool isDark) {
    if (_cancelledTrips.isEmpty) {
      return _buildEmptyState('لا توجد رحلات ملغاة');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, 96),
      itemCount: _cancelledTrips.length,
      itemBuilder: (context, index) {
        final item = _cancelledTrips[index];
        return CancelledTripCard(
          item: item,
          isDark: isDark,
        );
      },
    );
  }

  // Reusable Empty State Widget
  Widget _buildEmptyState(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceElevatedDark
                    : AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 48,
                color: AppColors.gray400,
              ),
            ),
            AppSpacing.h16,
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBM Plex Sans Arabic',
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
