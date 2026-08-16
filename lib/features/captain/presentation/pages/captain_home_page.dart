import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/laffah_map_view.dart';
import '../bloc/core/captain_bloc.dart';
import '../bloc/core/captain_event.dart';
import '../bloc/core/captain_state.dart';
import 'widgets/trip_request_dialog.dart';
import 'widgets/captain_floating_bottom_bar.dart';
import 'captain_earnings_page.dart';
import 'captain_account_page.dart';
import 'captain_notifications_page.dart';
import 'captain_trips_sub_page.dart';

/// CaptainHomePage - Overhauled dashboard & interactive map for Laffah Captains.
/// Incorporates iOS-inspired floating glassmorphic navigation dock,
/// synchronized online/offline status, real-time trip request overlay,
/// and interactive map pin info cards.
class CaptainHomePage extends StatefulWidget {
  const CaptainHomePage({super.key});

  @override
  State<CaptainHomePage> createState() => _CaptainHomePageState();
}

class _CaptainHomePageState extends State<CaptainHomePage> {
  int _currentIndex =
      0; // 0: Home, 1: Trips, 2: Earnings, 3: Notifications, 4: Account
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            isDark ? const Color(0xFF0E1116) : Colors.white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
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
              const CaptainTripsSubPage(),
              const CaptainEarningsPage(),
              const CaptainNotificationsPage(),
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
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const bool hasInternet = true;

    return BlocListener<CaptainBloc, CaptainState>(
      listener: (context, state) {
        if (state is TripAccepted) {
          // Push captain navigation screen once a trip is accepted
          context.push(
            '/captain/navigation',
            extra: {
              'tripId': state.tripId,
              'passengerName': state.passengerName,
              'passengerPhone': state.passengerPhone,
              'passengerRating': state.passengerRating,
              'pickup': state.pickup,
              'dropoff': state.dropoff,
              'fare': state.fare,
              'distance': state.distance,
              'duration': state.duration,
            },
          ).then((_) {
            // When returning from navigation, reset online toggle
            if (context.mounted) {
              context.read<CaptainBloc>().add(const ToggleOnlineStatus(false));
              widget.onOnlineChanged(false);
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
              builder: (context, state) {
                final captainPos =
                    state is CaptainLocationUpdated ? state.position : null;
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

          // Top Status Panel (Glowing Status Indicator & Online Toggle Switch)
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.s12,
            left: AppSpacing.s16,
            right: AppSpacing.s16,
            child: BlocSelector<CaptainBloc, CaptainState, bool>(
              selector: (state) => widget.isOnline && state is! CaptainOffline,
              builder: (context, isOnlineState) {
                final bool currentOnlineState = isOnlineState && hasInternet;
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: _buildTopStatusGlassPanel(
                      context, isDark, currentOnlineState, hasInternet),
                );
              },
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

          // Bottom Guidance Cards (Offline / Online Status Sync)
          if (_selectedPinTitle == null)
            Positioned(
              bottom: 92,
              left: 20,
              right: 20,
              child: BlocBuilder<CaptainBloc, CaptainState>(
                builder: (context, state) {
                  final bool currentOnlineState = widget.isOnline &&
                      state is! CaptainOffline &&
                      hasInternet;

                  if (!currentOnlineState && state is! IncomingTripRequest) {
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: _buildOfflineGuidanceCard(isDark),
                    );
                  }

                  if (currentOnlineState && state is CaptainOnline) {
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: _buildSearchingOrdersCard(isDark),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),

          // Incoming Request Overlay Dialog
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
                  return TripRequestDialog(
                    passengerName: state.passengerName,
                    passengerRating: state.passengerRating,
                    pickup: state.pickup,
                    dropoff: state.dropoff,
                    fare: state.fare,
                    distance: state.distance,
                    duration: state.duration,
                    onAccept: () {
                      HapticFeedback.heavyImpact();
                      context.read<CaptainBloc>().add(const AcceptTrip());
                    },
                    onReject: () {
                      HapticFeedback.mediumImpact();
                      context.read<CaptainBloc>().add(const RejectTrip());
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
        margin: const EdgeInsets.symmetric(horizontal: 40),
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
            const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.capt_no_internet,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'IBM Plex Sans Arabic',
              ),
            ),
          ],

        ),
      );
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        widget.onOnlineChanged(!isOnline);
        context.read<CaptainBloc>().add(ToggleOnlineStatus(!isOnline));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isOnline
              ? const Color(0xFF00C853)
                  .withValues(alpha: 0.95) // Vibrant Green when online
              : (isDark
                  ? const Color(0xFF1E2330).withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.95)),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: isOnline
                ? const Color(0xFF00E676).withValues(alpha: 0.5)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05)),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isOnline
                  ? const Color(0xFF00C853).withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: isOnline ? 20 : 12,
              spreadRadius: isOnline ? 4 : 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isOnline ? Icons.power_rounded : Icons.power_off_rounded,
                key: ValueKey(isOnline),
                color: isOnline
                    ? Colors.white
                    : (isDark ? Colors.white : AppColors.gray900),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                isOnline ? AppLocalizations.of(context)!.capt_online_searching : AppLocalizations.of(context)!.capt_tap_to_go_online,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: isOnline
                      ? Colors.white
                      : (isDark ? Colors.white : AppColors.gray900),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineGuidanceCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E2330).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
                child: const Icon(
                  Icons.power_settings_new_rounded,
                  color: AppColors.gray700,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.capt_you_are_offline,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: isDark ? Colors.white : AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.capt_tap_button_above_to_receive,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.gray500,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchingOrdersCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E2330).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF00C853).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            AppLocalizations.of(context)!.capt_searching_orders,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              fontFamily: 'IBM Plex Sans Arabic',
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
        ],
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
          color: const Color(0xFFFF6B00).withValues(alpha: 0.4),
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
              color: const Color(0xFFFF6B00).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xFFFF6B00),
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
