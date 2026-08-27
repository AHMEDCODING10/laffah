import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/laffah_app_bar.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        extendBody: true,
        appBar: LaffahAppBar(title: l10n.pass_trips_title),
        bottomNavigationBar: HomeBottomNavBar(isDark: isDark, currentIndex: 1),
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
                      label: Text(l10n.pass_trips_retry,
                          style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
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
                    tabs: [
                      Tab(text: l10n.pass_trips_tab_active),
                      Tab(text: l10n.pass_trips_tab_scheduled),
                      Tab(text: l10n.pass_trips_tab_past),
                      Tab(text: l10n.pass_trips_tab_cancelled),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTripList(activeTrips, isDark, 'active', l10n),
                      _buildTripList(scheduledTrips, isDark, 'scheduled', l10n),
                      _buildTripList(pastTrips, isDark, 'past', l10n),
                      _buildTripList(cancelledTrips, isDark, 'cancelled', l10n),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
  }

  Widget _buildTripList(
      List<Map<String, dynamic>> trips, bool isDark, String type, AppLocalizations l10n) {
    if (trips.isEmpty) {
      return _buildEmptyState(_emptyMessage(type, l10n));
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<RideBloc>().add(const LoadTripHistoryEvent());
        await Future.delayed(const Duration(milliseconds: 800));
      },
      color: AppColors.primary500,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, 96),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final item = _mapApiTripToCard(trips[index], l10n);
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
    ),
  );
}

  /// Maps API response fields to the format expected by TripHistoryCards
  Map<String, dynamic> _mapApiTripToCard(Map<String, dynamic> trip, AppLocalizations l10n) {
    return {
      'id': trip['id']?.toString() ?? '',
      'type': trip['type'] == 'parcel' ? l10n.pass_trips_type_parcel : l10n.pass_trips_type_ride,
      'statusAr': _statusToArabic(trip['status'], l10n),
      'captainName': trip['captain']?['user']?['name'] ?? l10n.pass_trips_captain_unknown,
      'vehicleModel': trip['captain']?['vehicle_model'] ?? '',
      'vehiclePlate': trip['captain']?['plate_number'] ?? '',
      'pickup': trip['pickup_address'] ?? '',
      'dropoff': trip['dropoff_address'] ?? '',
      'price': (trip['final_price'] ?? trip['estimated_price'] ?? 0).toDouble(),
      'distance': trip['distance_km']?.toString() ?? '',
      'rating': (trip['rating_by_user'] ?? 0).toDouble(),
      'isRide': trip['type'] != 'parcel',
      'scheduledAt': trip['scheduled_at'],
    };
  }

  String _statusToArabic(String? status, AppLocalizations l10n) {
    switch (status) {
      case 'pending':
        return l10n.pass_trips_status_pending;
      case 'accepted':
        return l10n.pass_trips_status_accepted;
      case 'arrived':
        return l10n.pass_trips_status_arrived;
      case 'in_transit':
        return l10n.pass_trips_status_in_transit;
      case 'completed':
        return l10n.pass_trips_status_completed;
      case 'cancelled':
        return l10n.pass_trips_status_cancelled;
      case 'scheduled':
        return l10n.pass_trips_status_scheduled;
      default:
        return l10n.pass_trips_status_unknown;
    }
  }

  String _emptyMessage(String type, AppLocalizations l10n) {
    switch (type) {
      case 'active':
        return l10n.pass_trips_empty_active;
      case 'scheduled':
        return l10n.pass_trips_empty_scheduled;
      case 'past':
        return l10n.pass_trips_empty_past;
      case 'cancelled':
        return l10n.pass_trips_empty_cancelled;
      default:
        return l10n.pass_trips_empty_unknown;
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
