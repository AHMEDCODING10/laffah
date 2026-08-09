import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/laffah_app_bar.dart';
import '../../../../core/di/injection_container.dart';
import '../../presentation/bloc/ride_bloc.dart';
import '../widgets/passenger/cards/trip_history_cards.dart';

/// TripHistoryPage — يعرض الرحلات الحقيقية من API الخادم عبر RideBloc
class TripHistoryPage extends StatelessWidget {
  const TripHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RideBloc>()..add(const LoadTripHistoryEvent()),
      child: const _TripHistoryView(),
    );
  }
}

class _TripHistoryView extends StatefulWidget {
  const _TripHistoryView();

  @override
  State<_TripHistoryView> createState() => __TripHistoryViewState();
}

class __TripHistoryViewState extends State<_TripHistoryView>
    with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        extendBody: true,
        appBar: const LaffahAppBar(title: 'رحلاتي وحجوزاتي'),
        body: BlocBuilder<RideBloc, RideState>(
          builder: (context, state) {
            if (state is TripHistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary500),
              );
            }

            if (state is TripHistoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 48, color: AppColors.gray400),
                    AppSpacing.h12,
                    Text(
                      state.message,
                      style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: AppColors.gray600),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.h16,
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<RideBloc>()
                          .add(const LoadTripHistoryEvent()),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('إعادة المحاولة',
                          style:
                              TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500),
                    ),
                  ],
                ),
              );
            }

            final List<Map<String, dynamic>> allTrips =
                state is TripHistoryLoaded ? state.trips : [];

            final activeTrips = allTrips
                .where((t) =>
                    t['status'] == 'pending' ||
                    t['status'] == 'accepted' ||
                    t['status'] == 'arrived' ||
                    t['status'] == 'in_transit')
                .toList();
            final scheduledTrips =
                allTrips.where((t) => t['status'] == 'scheduled').toList();
            final pastTrips =
                allTrips.where((t) => t['status'] == 'completed').toList();
            final cancelledTrips =
                allTrips.where((t) => t['status'] == 'cancelled').toList();

            return Column(
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
                      _buildTripList(activeTrips, isDark, 'active'),
                      _buildTripList(scheduledTrips, isDark, 'scheduled'),
                      _buildTripList(pastTrips, isDark, 'past'),
                      _buildTripList(cancelledTrips, isDark, 'cancelled'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTripList(
      List<Map<String, dynamic>> trips, bool isDark, String type) {
    if (trips.isEmpty) {
      return _buildEmptyState(_emptyMessage(type));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, 96),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final item = _mapApiTripToCard(trips[index]);
        switch (type) {
          case 'active':
            return ActiveTripCard(
              item: item,
              isDark: isDark,
              onCancel: () {
                context
                    .read<RideBloc>()
                    .add(CancelRideRequested(tripId: item['id']));
              },
            );
          case 'scheduled':
            return ScheduledTripCard(
              item: item,
              isDark: isDark,
              onCancel: () {
                context
                    .read<RideBloc>()
                    .add(CancelRideRequested(tripId: item['id']));
              },
            );
          case 'past':
            return PastTripCard(item: item, isDark: isDark);
          case 'cancelled':
            return CancelledTripCard(item: item, isDark: isDark);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  /// Maps API response fields to the format expected by TripHistoryCards
  Map<String, dynamic> _mapApiTripToCard(Map<String, dynamic> trip) {
    final double priceVal =
        ((trip['final_price'] ?? trip['estimated_price'] ?? trip['fare'] ?? trip['price'] ?? 0) as num).toDouble();

    return {
      'id': trip['id']?.toString() ?? '',
      'type': trip['type'] == 'parcel' ? 'إرسال طرد' : (trip['type'] ?? 'رحلة'),
      'statusAr': _statusToArabic(trip['status']),
      'captainName': trip['captain']?['user']?['name'] ?? trip['captainName'] ?? 'غير محدد',
      'vehicleModel': trip['captain']?['vehicle_model'] ?? trip['vehicleModel'] ?? '',
      'vehiclePlate': trip['captain']?['plate_number'] ?? trip['vehiclePlate'] ?? '',
      'pickup': trip['pickup_address'] ?? trip['pickup'] ?? '',
      'dropoff': trip['dropoff_address'] ?? trip['dropoff'] ?? '',
      'price': priceVal,
      'fare': priceVal,
      'estimatedFare': priceVal,
      'distance': trip['distance_km']?.toString() ?? trip['distance']?.toString() ?? '',
      'rating': ((trip['rating_by_user'] ?? trip['rating'] ?? 0) as num).toDouble(),
      'isRide': trip['type'] != 'parcel' && trip['isRide'] != false,
      'scheduledAt': trip['scheduled_at'] ?? trip['scheduledAt'] ?? trip['time'] ?? 'غير محدد',
      'time': trip['time'] ?? trip['scheduled_at'] ?? trip['scheduledAt'] ?? 'غداً، 08:00 ص',
      'date': trip['date'] ?? trip['created_at'] ?? 'اليوم',
      'reason': trip['reason'] ?? trip['cancellation_reason'] ?? 'تم الإلغاء بواسطة الراكب',
      'orderNumber': trip['orderNumber'] ?? 'رقم الطلب #LFX-782',
      'parcelContent': trip['parcelContent'] ?? 'مستندات وأوراق رسمية',
    };
  }

  String _statusToArabic(String? status) {
    switch (status) {
      case 'pending':
        return 'بانتظار كابتن';
      case 'accepted':
        return 'تم القبول';
      case 'arrived':
        return 'الكابتن في الطريق';
      case 'in_transit':
        return 'في التنقل';
      case 'completed':
        return 'مكتملة';
      case 'cancelled':
        return 'ملغاة';
      case 'scheduled':
        return 'مجدولة';
      default:
        return 'غير معروفة';
    }
  }

  String _emptyMessage(String type) {
    switch (type) {
      case 'active':
        return 'لا توجد طلبات أو رحلات نشطة حالياً';
      case 'scheduled':
        return 'لا توجد رحلات مجدولة';
      case 'past':
        return 'لا توجد رحلات سابقة';
      case 'cancelled':
        return 'لا توجد رحلات ملغاة';
      default:
        return 'لا توجد بيانات';
    }
  }

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
                color:
                    isDark ? AppColors.surfaceElevatedDark : AppColors.gray100,
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
