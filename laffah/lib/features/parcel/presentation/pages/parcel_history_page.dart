import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';
import '../../../ride/presentation/bloc/ride_bloc.dart';

/// ParcelHistoryPage — Shows all past and current parcel deliveries for the Passenger.
/// Fully connected to real backend via RideBloc & TripHistory API.
class ParcelHistoryPage extends StatefulWidget {
  const ParcelHistoryPage({super.key});

  @override
  State<ParcelHistoryPage> createState() => _ParcelHistoryPageState();
}

class _ParcelHistoryPageState extends State<ParcelHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<RideBloc>().add(const LoadTripHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: isDark ? AppColors.white : AppColors.gray900, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'سجل الطرود والأمانات',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: BlocBuilder<RideBloc, RideState>(
          builder: (context, state) {
            if (state is TripHistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary500),
              );
            }

            final List<Map<String, dynamic>> allTrips =
                state is TripHistoryLoaded ? state.trips : [];

            // Filter out parcel orders
            final parcels = allTrips.where((t) {
              final type = t['type']?.toString().toLowerCase();
              return type == 'parcel' ||
                  t['tracking_code'] != null ||
                  t['parcel_type'] != null ||
                  t['sender_name'] != null;
            }).toList();

            final currentParcels = parcels.where((p) {
              final status = p['status']?.toString().toLowerCase();
              return status == 'pending' ||
                  status == 'accepted' ||
                  status == 'arrived' ||
                  status == 'arrived_at_pickup' ||
                  status == 'picked_up' ||
                  status == 'in_transit';
            }).toList();

            final pastParcels = parcels.where((p) {
              final status = p['status']?.toString().toLowerCase();
              return status == 'delivered' ||
                  status == 'completed' ||
                  status == 'cancelled';
            }).toList();

            return RefreshIndicator(
              color: AppColors.primary500,
              onRefresh: () async {
                context.read<RideBloc>().add(const LoadTripHistoryEvent());
              },
              child: parcels.isEmpty
                  ? _buildEmptyState(context, isDark)
                  : ListView(
                      padding: const EdgeInsets.all(AppSpacing.s20),
                      children: [
                        if (currentParcels.isNotEmpty) ...[
                          Text(
                            'الطرود الحالية (${currentParcels.length})',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.white : AppColors.gray900,
                            ),
                          ),
                          AppSpacing.h12,
                          for (final p in currentParcels)
                            _buildParcelCard(p, isDark),
                          AppSpacing.h24,
                        ],
                        if (pastParcels.isNotEmpty) ...[
                          Text(
                            'الطرود السابقة (${pastParcels.length})',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.white : AppColors.gray900,
                            ),
                          ),
                          AppSpacing.h12,
                          for (final p in pastParcels)
                            _buildParcelCard(p, isDark),
                        ],
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.primary500,
              ),
            ),
            AppSpacing.h24,
            Text(
              'لا توجد طلبات طرود حالياً',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),
            AppSpacing.h8,
            Text(
              'يمكنك إرسال واستلام الطرود والأمانات والمستندات بسرعة وأمان مع كباتن لَفَّة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 14,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
                height: 1.5,
              ),
            ),
            AppSpacing.h24,
            ElevatedButton.icon(
              onPressed: () => context.push(LaffahRoutes.passengerParcelSend),
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              label: const Text(
                'إرسال طرد جديد الآن',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParcelCard(Map<String, dynamic> parcel, bool isDark) {
    final String trackingId = parcel['tracking_code'] ??
        parcel['id']?.toString() ??
        'LF-${DateTime.now().millisecondsSinceEpoch % 10000}';
    final String dropoff = parcel['dropoff_address'] ??
        parcel['dropoff_location'] ??
        parcel['dropoff'] ??
        'وجهة التسليم';
    final String rawStatus = parcel['status']?.toString().toLowerCase() ?? 'pending';

    String statusText = 'قيد المعالجة';
    Color statusColor = AppColors.warning;

    switch (rawStatus) {
      case 'pending':
        statusText = 'قيد البحث عن كابتن';
        statusColor = AppColors.warning;
        break;
      case 'accepted':
      case 'arrived':
      case 'arrived_at_pickup':
        statusText = 'الكابتن في الطريق للاستلام';
        statusColor = const Color(0xFF3B82F6);
        break;
      case 'picked_up':
      case 'in_transit':
        statusText = 'جاري التوصيل';
        statusColor = AppColors.primary500;
        break;
      case 'delivered':
      case 'completed':
        statusText = 'تم التسليم بنجاح';
        statusColor = const Color(0xFF22C55E);
        break;
      case 'cancelled':
        statusText = 'ملغي';
        statusColor = AppColors.danger;
        break;
    }

    final price = parcel['price'] ?? parcel['fare'] ?? parcel['total_fare'];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.06)
              : AppColors.gray200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSpacing.radiusMD,
          onTap: () {
            context.push(
              LaffahRoutes.passengerParcelTracking,
              extra: trackingId,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    rawStatus == 'delivered' || rawStatus == 'completed'
                        ? Icons.check_circle_rounded
                        : (rawStatus == 'cancelled'
                            ? Icons.cancel_rounded
                            : Icons.inventory_2_rounded),
                    color: statusColor,
                    size: 24,
                  ),
                ),
                AppSpacing.w16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            trackingId,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.white : AppColors.gray900,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.h6,
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: isDark ? AppColors.gray400 : AppColors.gray500,
                          ),
                          AppSpacing.w4,
                          Expanded(
                            child: Text(
                              dropoff,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 12,
                                color: isDark ? AppColors.gray400 : AppColors.gray600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (price != null) ...[
                        AppSpacing.h4,
                        Text(
                          '$price ريال يمني',
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? AppColors.gray600 : AppColors.gray400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
