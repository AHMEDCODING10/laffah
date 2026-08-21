import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../bloc/trips/captain_trips_bloc.dart';
import '../bloc/trips/captain_trips_event.dart';
import '../bloc/trips/captain_trips_state.dart';

class CaptainTripHistoryPage extends StatefulWidget {
  const CaptainTripHistoryPage({super.key});

  @override
  State<CaptainTripHistoryPage> createState() => _CaptainTripHistoryPageState();
}

class _CaptainTripHistoryPageState extends State<CaptainTripHistoryPage> {
  late CaptainTripsBloc _tripsBloc;

  @override
  void initState() {
    super.initState();
    _tripsBloc = sl<CaptainTripsBloc>()
      ..add(const FetchCaptainTrips(isRefresh: true));
  }

  @override
  void dispose() {
    _tripsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider.value(
        value: _tripsBloc,
        child: Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF141822) : const Color(0xFFF7F9FC),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: isDark ? AppColors.white : AppColors.gray900,
                  size: 20),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(LaffahRoutes.captainHome);
                }
              },
            ),
            title: Text(
              'سجل الرحلات',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),
          ),
          body: BlocBuilder<CaptainTripsBloc, CaptainTripsState>(
            builder: (context, state) {
              if (state is CaptainTripsInitial ||
                  (state is CaptainTripsLoading && state.isFirstFetch)) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary500));
              } else if (state is CaptainTripsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.danger),
                      const SizedBox(height: 16),
                      Text(state.message,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontFamily: 'IBM Plex Sans Arabic')),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _tripsBloc
                            .add(const FetchCaptainTrips(isRefresh: true)),
                        child: const Text('إعادة المحاولة',
                            style:
                                TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                      )
                    ],
                  ),
                );
              } else if (state is CaptainTripsLoaded) {
                return RefreshIndicator(
                  color: AppColors.primary500,
                  onRefresh: () async {
                    _tripsBloc.add(const FetchCaptainTrips(isRefresh: true));
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.s24),
                    children: [
                      _buildStatSummary(state, isDark),
                      AppSpacing.h32,
                      Text(
                        'قائمة الرحلات',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                      AppSpacing.h16,
                      if (state.trips.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Text('لا يوجد سجل رحلات حتى الآن.',
                                style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    color: AppColors.gray500)),
                          ),
                        )
                      else
                        ...state.trips.map((trip) => _buildTripItem(
                              type: trip.distance.contains('طرد')
                                  ? 'parcel'
                                  : 'ride', // Simplistic heuristic if no dedicated type field
                              destination: trip.dropoff.isNotEmpty
                                  ? trip.dropoff
                                  : 'وجهة غير معروفة',
                              time: trip.date,
                              earnings: trip.price,
                              status: trip.status,
                              statusColor: trip.statusColor,
                              isDark: isDark,
                            )),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatSummary(CaptainTripsLoaded state, bool isDark) {
    int totalTrips = state.trips.length;
    double totalEarnings =
        state.trips.fold(0.0, (sum, trip) => sum + trip.grossFare);
    // Simple heuristic for parcels based on status or type if available
    int totalParcels = state.trips
        .where((t) => t.pickup.contains('طرد') || t.distance.contains('طرد'))
        .length;
    int rides = totalTrips - totalParcels;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.primary500.withValues(alpha: 0.1),
        borderRadius: AppSpacing.radiusLG,
        border: Border.all(
          color: AppColors.primary500.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(title: 'الرحلات', value: rides.toString(), isDark: isDark),
          Container(
              width: 1,
              height: 40,
              color: AppColors.primary500.withValues(alpha: 0.3)),
          _StatItem(
              title: 'الطرود', value: totalParcels.toString(), isDark: isDark),
          Container(
              width: 1,
              height: 40,
              color: AppColors.primary500.withValues(alpha: 0.3)),
          _StatItem(
              title: 'الأرباح',
              value: '${totalEarnings.toInt()}',
              isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildTripItem({
    required String type,
    required String destination,
    required String time,
    required String earnings,
    required String status,
    required Color statusColor,
    required bool isDark,
  }) {
    final bool isCanceled = status == 'ملغاة' || status == 'cancelled';
    final IconData icon =
        type == 'ride' ? Icons.motorcycle_rounded : Icons.inventory_2_rounded;
    final Color iconColor =
        type == 'ride' ? AppColors.primary500 : const Color(0xFF3B82F6);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2433) : AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.05)
              : AppColors.gray200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCanceled
                  ? AppColors.gray500.withValues(alpha: 0.1)
                  : iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: isCanceled ? AppColors.gray500 : iconColor, size: 24),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.h4,
                Text(
                  time,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    color: isDark ? AppColors.gray400 : AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                earnings,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isCanceled
                      ? (isDark ? AppColors.gray400 : AppColors.gray500)
                      : AppColors.primary500,
                ),
              ),
              AppSpacing.h4,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.radiusSM,
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isDark;

  const _StatItem({
    required this.title,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        AppSpacing.h4,
        Text(
          title,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
        ),
      ],
    );
  }
}
