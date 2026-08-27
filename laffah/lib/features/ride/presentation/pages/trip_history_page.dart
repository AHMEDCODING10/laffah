import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // Fire event on global singleton without creating a new BlocProvider that kills it on dispose
    context.read<RideBloc>().add(const LoadTripHistoryEvent());
    return const _TripHistoryView();
  }
}

class _TripHistoryView extends StatefulWidget {
  const _TripHistoryView();

  @override
  State<_TripHistoryView> createState() => __TripHistoryViewState();
}

class __TripHistoryViewState extends State<_TripHistoryView> {
  String _selectedFilter = 'all'; // 'all', 'active', 'past', 'cancelled'

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      extendBody: true,
      appBar: LaffahAppBar(
        title: l10n.pass_trips_title,
        showMenuButton: false,
        showBackButton: false,
      ),
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
                        style:
                            const TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500),
                  ),
                ],
              ),
            );
          }

          final List<Map<String, dynamic>> allTrips =
              state is TripHistoryLoaded ? state.trips : [];

          int getTripTimestamp(Map<String, dynamic> t) {
            final val = t['cancelled_at'] ??
                t['updated_at'] ??
                t['completed_at'] ??
                t['created_at'];
            if (val != null) {
              final dt = DateTime.tryParse(val.toString());
              if (dt != null) return dt.millisecondsSinceEpoch;
            }
            return 0;
          }

          int getTripNumericId(Map<String, dynamic> t) {
            return int.tryParse(t['id']?.toString() ?? '0') ?? 0;
          }

          int compareTripsDesc(
              Map<String, dynamic> a, Map<String, dynamic> b) {
            final timeA = getTripTimestamp(a);
            final timeB = getTripTimestamp(b);
            if (timeB != timeA) {
              return timeB.compareTo(timeA); // Newest timestamp first
            }
            return getTripNumericId(b)
                .compareTo(getTripNumericId(a)); // Highest ID first
          }

          final sortedAllTrips = List<Map<String, dynamic>>.from(allTrips)
            ..sort(compareTripsDesc);

          final activeTrips = sortedAllTrips
              .where((t) =>
                  t['status'] == 'pending' ||
                  t['status'] == 'accepted' ||
                  t['status'] == 'arrived' ||
                  t['status'] == 'arrived_at_pickup' ||
                  t['status'] == 'picked_up' ||
                  t['status'] == 'in_transit')
              .toList();

          final pastTrips = sortedAllTrips
              .where((t) =>
                  t['status'] == 'completed' || t['status'] == 'delivered')
              .toList();

          final cancelledTrips = sortedAllTrips
              .where((t) => t['status'] == 'cancelled')
              .toList();

          List<Map<String, dynamic>> currentDisplayTrips;
          switch (_selectedFilter) {
            case 'active':
              currentDisplayTrips = activeTrips;
              break;
            case 'past':
              currentDisplayTrips = pastTrips;
              break;
            case 'cancelled':
              currentDisplayTrips = cancelledTrips;
              break;
            case 'all':
            default:
              currentDisplayTrips = sortedAllTrips;
              break;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Filter Options Chips (Matching Captain's Style) ──
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, AppSpacing.s12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'الكل',
                        isSelected: _selectedFilter == 'all',
                        isDark: isDark,
                        onTap: () => setState(() => _selectedFilter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'قيد التنفيذ',
                        isSelected: _selectedFilter == 'active',
                        isDark: isDark,
                        color: AppColors.warning,
                        onTap: () => setState(() => _selectedFilter = 'active'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'تم الانتهاء',
                        isSelected: _selectedFilter == 'past',
                        isDark: isDark,
                        color: AppColors.success,
                        onTap: () => setState(() => _selectedFilter = 'past'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'ملغاة',
                        isSelected: _selectedFilter == 'cancelled',
                        isDark: isDark,
                        color: AppColors.danger,
                        onTap: () =>
                            setState(() => _selectedFilter = 'cancelled'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Trips List with Animated Switcher ──
              Expanded(
                child: _buildTripList(
                  currentDisplayTrips,
                  isDark,
                  _selectedFilter,
                  l10n,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
    Color? color,
  }) {
    final chipColor = color ?? AppColors.primary500;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8.5),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.14)
              : (isDark
                  ? const Color(0xFF1A1F2B)
                  : AppColors.gray100.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? chipColor.withValues(alpha: 0.6)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.gray200),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
            color: isSelected
                ? chipColor
                : (isDark ? AppColors.gray400 : AppColors.gray600),
          ),
        ),
      ),
    );
  }

  Future<void> _showCancelConfirmationDialog(
      BuildContext context, String tripId) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor:
              isDark ? AppColors.surfaceElevatedDark : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_outlined,
                    color: AppColors.primary500, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'إلغاء الطلب',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في إلغاء هذا المشوار؟',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 14,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? Colors.white24 : AppColors.gray300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'تراجع',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: isDark ? Colors.white70 : AppColors.gray700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'تأكيد الإلغاء',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (shouldCancel == true && context.mounted) {
      context.read<RideBloc>().add(CancelRideRequested(tripId: tripId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'تم إلغاء الطلب بنجاح 🚫',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _handleDirectDelete(BuildContext context, String tripId) {
    context.read<RideBloc>().add(DeleteTripFromHistory(tripId));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary500,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2500),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.delete_sweep_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'تم حذف الرحلة بنجاح 🗑️',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripList(
      List<Map<String, dynamic>> trips, bool isDark, String filter, AppLocalizations l10n) {
    if (trips.isEmpty) {
      return _buildEmptyState(_emptyMessage(filter, l10n));
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
            AppSpacing.s16, AppSpacing.s4, AppSpacing.s16, 96),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final item = _mapApiTripToCard(trips[index], l10n);
          final status = (trips[index]['status'] ?? '').toString();

          if (status == 'cancelled') {
            return CancelledTripCard(
              item: item,
              isDark: isDark,
              onDelete: () =>
                  _handleDirectDelete(context, item['id'] as String),
            );
          } else if (status == 'completed' || status == 'delivered') {
            return PastTripCard(
              item: item,
              isDark: isDark,
              onDelete: () =>
                  _handleDirectDelete(context, item['id'] as String),
            );
          } else if (status == 'scheduled') {
            return ScheduledTripCard(
              item: item,
              isDark: isDark,
              onCancel: () =>
                  _showCancelConfirmationDialog(context, item['id'] as String),
            );
          } else {
            // Active / in_transit / arrived / pending / accepted
            return ActiveTripCard(
              item: item,
              isDark: isDark,
              onCancel: () =>
                  _showCancelConfirmationDialog(context, item['id'] as String),
            );
          }
        },
      ),
    );
  }

  /// Maps API response fields to the format expected by TripHistoryCards
  Map<String, dynamic> _mapApiTripToCard(Map<String, dynamic> trip, AppLocalizations l10n) {
    final bool isParcel = trip['isParcel'] == true ||
        trip['is_parcel'] == true ||
        trip['type'] == 'parcel' ||
        trip['type'] == 'delivery';

    final rawCaptainName = trip['captainName'] ??
        trip['captain']?['user']?['name'] ??
        trip['captain']?['name'];

    final captainName = (rawCaptainName != null && rawCaptainName.toString().trim().isNotEmpty)
        ? rawCaptainName.toString().trim()
        : (isParcel ? 'كابتن التوصيل' : l10n.pass_trips_captain_unknown);

    final rawPrice = trip['final_price'] ?? trip['estimated_price'] ?? trip['price'] ?? 0;
    final double price = (rawPrice is num)
        ? rawPrice.toDouble()
        : (double.tryParse(rawPrice.toString()) ?? 0.0);

    return {
      'id': trip['id']?.toString() ?? '',
      'type': isParcel ? 'إرسال طرد 📦' : l10n.pass_trips_type_ride,
      'statusAr': _statusToArabic(trip['status']?.toString(), isParcel, l10n),
      'captainName': captainName,
      'vehicleModel': trip['captain']?['vehicle_model'] ?? (isParcel ? 'دراجة توصيل' : ''),
      'vehiclePlate': trip['captain']?['plate_number'] ?? '',
      'pickup': trip['pickup_address'] ?? trip['pickup'] ?? '',
      'dropoff': trip['dropoff_address'] ?? trip['dropoff'] ?? '',
      'price': price,
      'fare': price,
      'distance': trip['distance_km']?.toString() ?? trip['distance']?.toString() ?? '',
      'rating': (trip['rating_by_user'] != null && trip['rating_by_user'] is num)
          ? (trip['rating_by_user'] as num).toDouble()
          : 5.0,
      'isRide': !isParcel,
      'isParcel': isParcel,
      'date': trip['timeTag'] ?? (isParcel ? 'تم التسليم' : 'مكتملة'),
      'scheduledAt': trip['scheduled_at'],
      'reason': trip['cancellation_reason'] ?? 'تم الإلغاء بواسطة الراكب',
      'cancelled_at': trip['cancelled_at'],
      'updated_at': trip['updated_at'],
      'created_at': trip['created_at'],
    };
  }

  String _statusToArabic(String? status, bool isParcel, AppLocalizations l10n) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return isParcel ? 'بانتظار كابتن' : l10n.pass_trips_status_pending;
      case 'accepted':
        return l10n.pass_trips_status_accepted;
      case 'arrived':
      case 'arrived_at_pickup':
        return isParcel ? 'الكابتن وصل للاستلام' : l10n.pass_trips_status_arrived;
      case 'picked_up':
        return 'تم استلام الطرد';
      case 'in_transit':
        return isParcel ? 'جاري التوصيل' : l10n.pass_trips_status_in_transit;
      case 'completed':
        return l10n.pass_trips_status_completed;
      case 'delivered':
        return 'تم التسليم';
      case 'cancelled':
      case 'canceled':
        return l10n.pass_trips_status_cancelled;
      case 'scheduled':
        return l10n.pass_trips_status_scheduled;
      default:
        return isParcel ? 'تم التسليم' : l10n.pass_trips_status_completed;
    }
  }

  String _emptyMessage(String filter, AppLocalizations l10n) {
    switch (filter) {
      case 'active':
        return 'لا توجد رحلات قيد التنفيذ حالياً';
      case 'past':
        return 'لا توجد رحلات مكتملة سابقة';
      case 'cancelled':
        return 'لا توجد رحلات ملغاة';
      case 'all':
      default:
        return 'لا توجد أي رحلات في سجلك حتى الآن';
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
                color: isDark
                    ? AppColors.surfaceElevatedDark
                    : AppColors.primary500.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.primary500,
              ),
            ),
            AppSpacing.h16,
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBM Plex Sans Arabic',
                color: isDark ? AppColors.gray300 : AppColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
