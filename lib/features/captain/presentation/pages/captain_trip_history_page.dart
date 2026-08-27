import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/dio_client.dart';
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
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(AppSpacing.s24),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                            ],
                          ),
                        ),
                      ),
                      if (state.trips.isEmpty)
                        const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Text('لا يوجد سجل رحلات حتى الآن.',
                                  style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      color: AppColors.gray500)),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                          sliver: SliverList.builder(
                            itemCount: state.trips.length,
                            itemBuilder: (context, index) {
                              final trip = state.trips[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.s16), // Apply some spacing between items
                                child: _buildTripItem(
                                  tripId: trip.id,
                                  type: trip.isParcel ? 'parcel' : 'ride',
                                  destination: trip.dropoff.isNotEmpty
                                      ? trip.dropoff
                                      : 'وجهة غير معروفة',
                                  time: trip.date,
                                  earnings: trip.price,
                                  status: trip.status,
                                  statusColor: trip.statusColor,
                                  isDark: isDark,
                                  onDelete: () => _confirmDelete(context, trip.id, isDark),
                                ),
                              );
                            },
                          ),
                        ),
                      // Bottom padding for scroll view
                      const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
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

  void _confirmDelete(BuildContext context, String tripId, bool isDark) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1B2232) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 24),
              SizedBox(width: 10),
              Text(
                'حذف السجل',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في حذف هذا السجل من قائمة الرحلات؟',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: AppColors.gray500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _deleteTrip(tripId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'تأكيد الحذف',
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

  Future<void> _deleteTrip(String tripId) async {
    try {
      final dio = sl<DioClient>().dio;
      await dio.delete('/trips/$tripId');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primary500,
            content: Text(
              'تم حذف السجل بنجاح 🗑️',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        _tripsBloc.add(const FetchCaptainTrips(isRefresh: true));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.danger,
            content: Text(
              'فشل حذف السجل.',
              style: TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
            ),
          ),
        );
      }
    }
  }

  Widget _buildStatSummary(CaptainTripsLoaded state, bool isDark) {
    int totalTrips = state.trips.length;
    double totalEarnings =
        state.trips.fold(0.0, (sum, trip) => sum + trip.grossFare);
    int totalParcels = state.trips.where((t) => t.isParcel).length;
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
    required String tripId,
    required String type,
    required String destination,
    required String time,
    required String earnings,
    required String status,
    required Color statusColor,
    required bool isDark,
    required VoidCallback onDelete,
  }) {
    final bool isCanceled = status == 'ملغاة' || status == 'cancelled';
    final IconData icon =
        type == 'ride' ? Icons.two_wheeler_rounded : Icons.inventory_2_rounded;
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
                color: isCanceled ? AppColors.gray500 : iconColor, size: 22),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: (type == 'ride' ? AppColors.primary500 : Colors.blue)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        type == 'ride' ? 'مشوار 🛵' : 'طرد 📦',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: type == 'ride' ? AppColors.primary500 : Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        destination,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                AppSpacing.h4,
                Text(
                  time,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11.5,
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
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: isCanceled
                      ? (isDark ? AppColors.gray400 : AppColors.gray500)
                      : AppColors.primary500,
                ),
              ),
              AppSpacing.h4,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.radiusSM,
                    ),
                    child: Text(
                      status == 'delivered' ? 'تم التسليم' : (status == 'completed' ? 'مكتملة' : status),
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 15,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
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
