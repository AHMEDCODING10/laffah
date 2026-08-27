import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../bloc/notifications/captain_notifications_bloc.dart';
import '../bloc/notifications/captain_notifications_event.dart';
import '../bloc/notifications/captain_notifications_state.dart';
import 'widgets/captain_reject_reason_dialog.dart';

class CaptainNotificationsPage extends StatefulWidget {
  const CaptainNotificationsPage({super.key});

  @override
  State<CaptainNotificationsPage> createState() =>
      _CaptainNotificationsPageState();
}

class _CaptainNotificationsPageState extends State<CaptainNotificationsPage> {
  int _activeCategoryIndex = 0;
  bool _isAllRead = false;

  late List<String> _categories;
  late CaptainNotificationsBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _categories = [
      AppLocalizations.of(context)!.capt_notif_new_requests,
      AppLocalizations.of(context)!.capt_notif_system_updates,
      AppLocalizations.of(context)!.capt_notif_alerts,
    ];
  }

  @override
  void initState() {
    super.initState();
    _bloc = sl<CaptainNotificationsBloc>();
    _bloc.add(FetchNotificationsAndRequests());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _markAllAsRead() {
    HapticFeedback.lightImpact();
    setState(() {
      _isAllRead = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        content: Text(
          AppLocalizations.of(context)!.capt_notif_all_read_success,
          style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF141822) : const Color(0xFFF7F9FC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            AppLocalizations.of(context)!.capt_notif_page_title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'IBM Plex Sans Arabic',
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.done_all_rounded,
                color: _isAllRead ? AppColors.gray500 : AppColors.primary500,
              ),
              tooltip: AppLocalizations.of(context)!.capt_notif_mark_all_read,
              onPressed: _markAllAsRead,
            ),
          ],
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // Segmented Filter Tabs
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2433) : AppColors.gray100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: List.generate(_categories.length, (index) {
                      final isSelected = _activeCategoryIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _activeCategoryIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.primary500
                                      : AppColors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isSelected && !isDark
                                  ? [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _categories[index],
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? (isDark
                                        ? Colors.white
                                        : AppColors.primary500)
                                    : AppColors.gray500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s8),

              Expanded(
                child: BlocBuilder<CaptainNotificationsBloc,
                    CaptainNotificationsState>(
                  builder: (context, state) {
                    if (state is CaptainNotificationsLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary500));
                    } else if (state is CaptainNotificationsError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: AppColors.danger),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.capt_notif_error_fetch,
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  _bloc.add(FetchNotificationsAndRequests()),
                              child: Text(AppLocalizations.of(context)!.capt_notif_retry),
                            )
                          ],
                        ),
                      );
                    } else if (state is CaptainNotificationsLoaded) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          _bloc.add(RefreshNotificationsAndRequests());
                        },
                        color: AppColors.primary500,
                        child: _buildListBasedOnCategory(state, isDark),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListBasedOnCategory(
      CaptainNotificationsLoaded state, bool isDark) {
    if (_activeCategoryIndex == 0) {
      if (state.nearbyRequests.isEmpty) {
        return _buildEmptyState(
            AppLocalizations.of(context)!.capt_notif_empty_requests, Icons.radar, isDark);
      }
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: state.nearbyRequests.length,
        itemBuilder: (context, index) {
          final order = state.nearbyRequests[index];
          return _buildOrderCard(order, isDark);
        },
      );
    } else if (_activeCategoryIndex == 1) {
      final tripAndSystemUpdates = state.notifications.where((n) {
        final t = n.type.toLowerCase();
        return t == 'system' ||
            t == 'trip_accepted' ||
            t == 'trip_completed' ||
            t == 'parcel' ||
            t == 'parcel_delivered' ||
            t == 'general' ||
            t == 'ride' ||
            t == 'delivery';
      }).toList();

      final displayList = tripAndSystemUpdates.isNotEmpty
          ? tripAndSystemUpdates
          : state.notifications;

      if (displayList.isEmpty) {
        return _buildEmptyState(AppLocalizations.of(context)!.capt_notif_empty_updates,
            Icons.system_security_update_good, isDark);
      }
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final notif = displayList[index];
          return _buildNotificationCard(notif, isDark);
        },
      );
    } else {
      final alerts = state.notifications.where((n) {
        final t = n.type.toLowerCase();
        return t == 'alert' ||
            t == 'wallet' ||
            t == 'payout' ||
            t == 'bonus' ||
            t == 'warning' ||
            t == 'trip_completed' ||
            t == 'parcel_delivered';
      }).toList();

      final displayList = alerts.isNotEmpty ? alerts : state.notifications;

      if (displayList.isEmpty) {
        return _buildEmptyState(
            AppLocalizations.of(context)!.capt_notif_empty_alerts, Icons.notifications_none, isDark);
      }
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final notif = displayList[index];
          return _buildNotificationCard(notif, isDark);
        },
      );
    }
  }

  Widget _buildEmptyState(String message, IconData icon, bool isDark) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 80, color: AppColors.gray400.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 16,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(dynamic order, bool isDark) {
    final isParcel = order.isParcel;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2433) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary500.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
        border: Border.all(
          color: isParcel
              ? AppColors.info.withValues(alpha: 0.3)
              : AppColors.primary500.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isParcel
                        ? AppColors.info.withValues(alpha: 0.1)
                        : AppColors.primary500.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isParcel
                        ? Icons.inventory_2_rounded
                        : Icons.local_taxi_rounded,
                    color: isParcel ? AppColors.info : AppColors.primary500,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.title,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person_rounded,
                              size: 14, color: AppColors.gray500),
                          const SizedBox(width: 4),
                          Text(
                            order.passengerName,
                            style: const TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 13,
                              color: AppColors.gray500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(
                            order.passengerRating.toString(),
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isDark ? Colors.white : AppColors.gray800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A3143) : AppColors.gray100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.timeTag,
                    style: const TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
              height: 1, color: isDark ? Colors.white10 : AppColors.gray200),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRouteItem(
                    Icons.my_location_rounded, order.pickup, isDark, true),
                _buildRouteLine(isDark),
                _buildRouteItem(
                    Icons.location_on_rounded, order.dropoff, isDark, false,
                    color: AppColors.primary),
                if (order.stops.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              AppColors.primary500.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: order.stops
                          .map<Widget>((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.add_location_alt_rounded,
                                        size: 16, color: AppColors.primary500),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: Text(s,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.black87,
                                                fontFamily:
                                                    'IBM Plex Sans Arabic'))),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickStat(
                        Icons.route_rounded, order.distance, isDark),
                    _buildQuickStat(
                        Icons.schedule_rounded, order.duration, isDark),
                    _buildQuickStat(Icons.payments_rounded, order.price, isDark,
                        isHighlight: true),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      CaptainRejectReasonDialog.show(
                        context: context,
                        orderTitle: order.title,
                        onConfirmReject: (reason) {
                          _bloc.add(
                              RefreshNotificationsAndRequests()); // Refresh after reject
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(AppLocalizations.of(context)!.capt_notif_reject,
                        style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      context.push(
                        '/captain/navigation',
                        extra: {
                          'tripId': order.id,
                          'passengerName': order.passengerName,
                          'passengerPhone': order.passengerPhone,
                          'passengerRating': order.passengerRating,
                          'pickup': order.pickup,
                          'dropoff': order.dropoff,
                          'fare': order.grossFare,
                          'distance': order.distance,
                          'duration': order.duration,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(AppLocalizations.of(context)!.capt_notif_accept,
                        style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notif, bool isDark) {
    bool isRead = notif.isRead || _isAllRead;

    IconData iconData = Icons.notifications;
    if (notif.icon == 'shield') iconData = Icons.shield_rounded;
    if (notif.icon == 'bike') iconData = Icons.two_wheeler_rounded;
    if (notif.icon == 'star') iconData = Icons.star_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead
            ? (isDark ? const Color(0xFF1A1F2C) : Colors.white)
            : (isDark
                ? const Color(0xFF242A38)
                : AppColors.primary.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(16),
        border: isRead
            ? null
            : Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A3143) : AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData,
                color: isRead ? AppColors.gray500 : AppColors.primary500,
                size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight:
                              isRead ? FontWeight.w600 : FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppColors.gray900,
                        ),
                      ),
                    ),
                    Text(
                      notif.timeTag,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notif.description,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 13,
                    color: isDark ? Colors.white70 : AppColors.gray600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteItem(
      IconData icon, String title, bool isDark, bool isPickup,
      {Color? color}) {
    return Row(
      children: [
        Icon(icon,
            size: 20,
            color: color ?? (isDark ? Colors.white70 : AppColors.gray500)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDark ? Colors.white : AppColors.gray800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteLine(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 9, top: 4, bottom: 4),
      height: 16,
      width: 2,
      color: isDark ? Colors.white24 : AppColors.gray300,
    );
  }

  Widget _buildQuickStat(IconData icon, String value, bool isDark,
      {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color: isHighlight ? AppColors.primary500 : AppColors.gray500),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
            color: isHighlight
                ? AppColors.primary500
                : (isDark ? Colors.white70 : AppColors.gray700),
          ),
        ),
      ],
    );
  }
}
