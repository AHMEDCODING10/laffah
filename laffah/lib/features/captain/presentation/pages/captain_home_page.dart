import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/laffah_map_view.dart';
import '../bloc/core/captain_bloc.dart';
import '../bloc/core/captain_event.dart';
import '../bloc/core/captain_state.dart';
import 'widgets/floating_captain_trip_request_card.dart';
import 'widgets/captain_floating_bottom_bar.dart';
import 'captain_earnings_page.dart';
import 'captain_account_page.dart';
import 'captain_notifications_page.dart';
import 'captain_trips_sub_page.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/trips/captain_trips_bloc.dart';
import '../bloc/trips/captain_trips_event.dart';
import '../bloc/wallet/captain_wallet_bloc.dart';
import '../bloc/wallet/captain_wallet_event.dart';
import '../bloc/notifications/captain_notifications_bloc.dart';
import '../bloc/notifications/captain_notifications_event.dart';

/// CaptainHomePage - Overhauled dashboard & interactive map for Laffah Captains.
/// Incorporates iOS-inspired floating glassmorphic navigation dock,
/// synchronized online/offline status, real-time trip request overlay,
/// and interactive map pin info cards.
class CaptainHomePage extends StatefulWidget {
  const CaptainHomePage({super.key});

  @override
  State<CaptainHomePage> createState() => _CaptainHomePageState();
}

class _CaptainHomePageState extends State<CaptainHomePage>
    with WidgetsBindingObserver {
  int _currentIndex =
      0; // 0: Home, 1: Trips, 2: Earnings, 3: Notifications, 4: Account
  bool _isOnline = false;

  late final CaptainTripsBloc _tripsBloc;
  late final CaptainWalletBloc _walletBloc;
  late final CaptainNotificationsBloc _notificationsBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tripsBloc = di.sl<CaptainTripsBloc>()
      ..add(const FetchCaptainTrips(isRefresh: true));
    _walletBloc = di.sl<CaptainWalletBloc>()..add(const FetchWalletDetails());
    _notificationsBloc = di.sl<CaptainNotificationsBloc>()
      ..add(FetchNotificationsAndRequests());

    final captainState = context.read<CaptainBloc>().state;
    _isOnline = captainState is CaptainOnline;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tripsBloc.close();
    _walletBloc.close();
    _notificationsBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshActiveData();
    }
  }

  void _refreshActiveData() {
    _walletBloc.add(const FetchWalletDetails(isSilent: true));
    _tripsBloc.add(const FetchCaptainTrips(isRefresh: true, isSilent: true));
    _notificationsBloc.add(FetchNotificationsAndRequests());
  }

  void _onTabChanged(int index) {
    if (_currentIndex != index) {
      if (index == 1) {
        // Tapped Trips tab -> auto-fetch latest trips silently in background
        _tripsBloc.add(const FetchCaptainTrips(isRefresh: true, isSilent: true));
      } else if (index == 2) {
        // Tapped Earnings/Wallet tab -> auto-fetch latest balance & transactions silently
        _walletBloc.add(const FetchWalletDetails(isSilent: true));
      } else if (index == 3) {
        // Tapped Notifications tab
        _notificationsBloc.add(FetchNotificationsAndRequests());
      }
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _tripsBloc),
        BlocProvider.value(value: _walletBloc),
        BlocProvider.value(value: _notificationsBloc),
      ],
      child: BlocListener<CaptainBloc, CaptainState>(
        listenWhen: (previous, current) {
          return current is TripCompleted ||
              (previous is TripAccepted && current is CaptainOnline);
        },
        listener: (context, state) {
          _refreshActiveData();
        },
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Indexed screens stack takes full screen due to StackFit.expand
              IndexedStack(
                index: _currentIndex,
                children: [
                  _HomeMapSubPage(
                    isOnline: _isOnline,
                    onOnlineChanged: (val) {
                      setState(() {
                        _isOnline = val;
                      });
                    },
                  ),
                  CaptainTripsSubPage(tripsBloc: _tripsBloc),
                  CaptainEarningsPage(walletBloc: _walletBloc),
                  CaptainNotificationsPage(bloc: _notificationsBloc),
                  const CaptainAccountPage(),
                ],
              ),

              // Floating iOS Glassmorphic Bottom Navigation Dock
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CaptainFloatingBottomBar(
                  currentIndex: _currentIndex,
                  onTap: _onTabChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interactive Home Map View SubPage
class _HomeMapSubPage extends StatefulWidget {
  final bool isOnline;
  final ValueChanged<bool> onOnlineChanged;

  const _HomeMapSubPage({
    required this.isOnline,
    required this.onOnlineChanged,
  });

  @override
  State<_HomeMapSubPage> createState() => _HomeMapSubPageState();
}

class _HomeMapSubPageState extends State<_HomeMapSubPage> {
  // Selected map marker details info card state
  String? _selectedPinTitle;
  String? _selectedPinSnippet;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final captainState = context.read<CaptainBloc>().state;
    if (captainState is CaptainOnline && !widget.isOnline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onOnlineChanged(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const bool hasInternet = true;

    return BlocListener<CaptainBloc, CaptainState>(
      listenWhen: (previous, current) {
        if (current is CaptainFailureState) return true;
        if (current is CaptainOnline || current is CaptainOffline) return true;
        // Only trigger navigation push when transitioning into a new accepted trip, NOT on status updates within the same trip
        if (current is TripAccepted) {
          if (previous is! TripAccepted) return true;
          return previous.tripId != current.tripId;
        }
        return false;
      },
      listener: (context, state) {
        if (state is CaptainFailureState) {
          widget.onOnlineChanged(false);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.message,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is CaptainOnline) {
          widget.onOnlineChanged(true);
        } else if (state is CaptainOffline) {
          widget.onOnlineChanged(false);
        } else if (state is TripAccepted) {
          final targetRoute = state.isParcel
              ? '/captain/parcel/navigation'
              : '/captain/navigation';

          // Push captain navigation screen once a trip/parcel is accepted
          context.push(
            targetRoute,
            extra: {
              'parcelId': state.tripId,
              'tripId': state.tripId,
              'trackingCode': state.trackingCode ?? state.tripId,
              'senderName': state.passengerName,
              'senderPhone': state.passengerPhone,
              'receiverName': state.receiverName,
              'receiverPhone': state.receiverPhone,
              'passengerName': state.passengerName,
              'passengerPhone': state.passengerPhone,
              'passengerRating': state.passengerRating,
              'parcelType': state.parcelType ?? 'طرد',
              'size': state.size ?? 'متوسط',
              'pickup': state.pickup,
              'dropoff': state.dropoff,
              'fare': state.fare,
              'distance': state.distance,
              'duration': state.duration,
              'pickupLat': state.routePoints.isNotEmpty ? state.routePoints.first.latitude : 15.3605,
              'pickupLng': state.routePoints.isNotEmpty ? state.routePoints.first.longitude : 44.1852,
              'dropoffLat': state.routePoints.isNotEmpty ? state.routePoints.last.latitude : 15.3521,
              'dropoffLng': state.routePoints.isNotEmpty ? state.routePoints.last.longitude : 44.2014,
              'paymentMethod': state.paymentMethod,
              'status': state.tripProgress, // PASS STATUS
            },
          ).then((_) {
            // Keep captain ONLINE when returning to Home so they can receive new requests immediately!
            if (context.mounted) {
              context.read<CaptainBloc>().add(const ResetCaptainState(keepOnline: true));
              widget.onOnlineChanged(true);
            }
          });
        }
      },
      child: Stack(
        children: [
          // Interactive OpenStreetMap background with tap listener for markers
          // This widget NO LONGER rebuilds on every bloc state change! (Huge performance gain)
          Positioned.fill(
            child: BlocBuilder<CaptainBloc, CaptainState>(
              buildWhen: (previous, current) {
                // Prevent rebuild of the entire map widget tree on periodic GPS location pings
                if (current is CaptainLocationUpdated && previous is CaptainLocationUpdated) {
                  return false;
                }
                if (current is CaptainLocationUpdated && previous is CaptainOnline) {
                  return false;
                }
                return previous.runtimeType != current.runtimeType;
              },
              builder: (context, state) {
                final captainPos = state is CaptainLocationUpdated
                    ? state.position
                    : context.read<CaptainBloc>().currentCaptainPosition;
                final routePoints =
                    (state is TripAccepted && state.routePoints.isNotEmpty)
                        ? state.routePoints
                        : null;

                return LaffahMapView(
                  isDark: isDark,
                  captainLocation: captainPos,
                  routePoints: routePoints,
                  followCaptain: true,
                  showDefaultMockData: false,
                  onMarkerTap: (title, snippet, pos) {
                    setState(() {
                      _selectedPinTitle = title;
                      _selectedPinSnippet = snippet;
                    });
                  },
                );
              },
            ),
          ),

          // Top Status Panel (Unified Captain Online / Offline Control)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: BlocSelector<CaptainBloc, CaptainState, bool>(
                  selector: (state) =>
                      widget.isOnline && state is! CaptainOffline,
                  builder: (context, isOnlineState) {
                    final bool currentOnlineState =
                        isOnlineState && hasInternet;
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: _buildTopStatusGlassPanel(
                          context, isDark, currentOnlineState, hasInternet),
                    );
                  },
                ),
              ),
            ),
          ),

          // Interactive Pin Detail Info Card (shows when tapping any map marker)
          if (_selectedPinTitle != null)
            Positioned(
              bottom: 92,
              left: 16,
              right: 16,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: _buildMarkerDetailCard(isDark),
              ),
            ),

          // Incoming Request Floating Card above Bottom Dock
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BlocBuilder<CaptainBloc, CaptainState>(
              buildWhen: (previous, current) =>
                  previous is IncomingTripRequest ||
                  current is IncomingTripRequest,
              builder: (context, state) {
                if (state is IncomingTripRequest) {
                  return FloatingCaptainTripRequestCard(
                    tripId: state.tripId,
                    passengerName: state.passengerName,
                    passengerRating: state.passengerRating,
                    pickup: state.pickup,
                    dropoff: state.dropoff,
                    fare: state.fare,
                    distance: state.distance,
                    duration: state.duration,
                    timeTag: state.timeTag,
                    isParcel: state.isParcel,
                    parcelType: state.parcelType,
                    onAccept: () {
                      if (_isSubmitting) return;
                      setState(() => _isSubmitting = true);
                      HapticFeedback.heavyImpact();
                      context.read<CaptainBloc>().add(const AcceptTrip());
                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) setState(() => _isSubmitting = false);
                      });
                    },
                    onReject: () {
                      if (_isSubmitting) return;
                      setState(() => _isSubmitting = true);
                      HapticFeedback.mediumImpact();
                      context.read<CaptainBloc>().add(const RejectTrip());
                      Future.delayed(const Duration(seconds: 1), () {
                        if (mounted) setState(() => _isSubmitting = false);
                      });
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatusGlassPanel(
      BuildContext context, bool isDark, bool isOnline, bool hasInternet) {
    if (!hasInternet) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                AppLocalizations.of(context)?.capt_no_internet ??
                    'لا يوجد اتصال بالإنترنت',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        final newStatus = !isOnline;
        widget.onOnlineChanged(newStatus);
        context.read<CaptainBloc>().add(ToggleOnlineStatus(newStatus));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isOnline
              ? const Color(0xFF00C853)
              : (isDark
                  ? const Color(0xFF1E2330).withValues(alpha: 0.94)
                  : Colors.white.withValues(alpha: 0.96)),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isOnline
                ? const Color(0xFF69F0AE).withValues(alpha: 0.6)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : AppColors.gray300.withValues(alpha: 0.8)),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isOnline
                  ? const Color(0xFF00C853).withValues(alpha: 0.38)
                  : Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: isOnline ? 18 : 10,
              spreadRadius: isOnline ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Leading Icon / Animated Status Indicator
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: isOnline
                  ? Container(
                      key: const ValueKey('online_spinner'),
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Container(
                      key: const ValueKey('offline_icon'),
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF263044)
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.power_settings_new_rounded,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        size: 20,
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Middle: Search Status and Helper Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isOnline
                        ? 'جاري البحث عن طلبات...'
                        : 'أنت غير متصل',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: isOnline
                          ? Colors.white
                          : (isDark ? Colors.white : AppColors.gray900),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOnline
                        ? 'الرادار نشط • انقر للإيقاف'
                        : 'اضغط للاتصال وبدء البحث',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: isOnline
                          ? Colors.white.withValues(alpha: 0.85)
                          : AppColors.gray500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Trailing Action Badge (إيقاف when online / اتصال when offline)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: isOnline
                  ? Container(
                      key: const ValueKey('badge_stop'),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.power_settings_new_rounded,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'إيقاف',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      key: const ValueKey('badge_start'),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              const Color(0xFF00C853).withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded,
                              color: Color(0xFF00C853), size: 16),
                          SizedBox(width: 2),
                          Text(
                            'اتصال',
                            style: TextStyle(
                              color: Color(0xFF00C853),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkerDetailCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF141822).withValues(alpha: 0.94)
            : Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary500.withValues(alpha: 0.4),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary500.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.primary500,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedPinTitle ?? AppLocalizations.of(context)!.capt_selected_location,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: isDark ? Colors.white : AppColors.gray900,
                  ),
                ),
                if (_selectedPinSnippet != null &&
                    _selectedPinSnippet!.isNotEmpty)
                  Text(
                    _selectedPinSnippet!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.gray500,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 20, color: AppColors.gray500),
            onPressed: () {
              setState(() {
                _selectedPinTitle = null;
                _selectedPinSnippet = null;
              });
            },
          ),
        ],
      ),
    );
  }
}
