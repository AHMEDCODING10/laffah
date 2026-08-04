import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
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
  int _currentIndex = 0; // 0: Home, 1: Trips, 2: Earnings, 3: Notifications, 4: Account
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? const Color(0xFF0E1116) : Colors.white,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
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
                    final captainPos = state is CaptainLocationUpdated ? state.position : null;
                    final polylines = (state is TripAccepted && state.routePoints.isNotEmpty)
                        ? [
                            Polyline(
                              points: state.routePoints,
                              color: const Color(0xFFFF6B00),
                              strokeWidth: 5.0,
                            ),
                          ]
                        : null;

                    return LaffahMapView(
                      isDark: isDark,
                      captainLocation: captainPos,
                      polylines: polylines,
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
                      child: _buildTopStatusGlassPanel(context, isDark, currentOnlineState, hasInternet),
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
                      final bool currentOnlineState = widget.isOnline && state is! CaptainOffline && hasInternet;

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
                  buildWhen: (previous, current) => previous is IncomingTripRequest || current is IncomingTripRequest,
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

  Widget _buildTopStatusGlassPanel(BuildContext context, bool isDark, bool isOnline, bool hasInternet) {
    if (!hasInternet) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'لا يوجد اتصال بالإنترنت - يتم إعادة المحاولة...',
              style: TextStyle(
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF141822).withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.success : AppColors.gray500,
                  shape: BoxShape.circle,
                  boxShadow: isOnline
                      ? [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.6),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isOnline ? 'متصل الآن (جاهز لاستقبال الطلبات)' : 'أنت منقطع حالياً',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: isDark ? Colors.white : AppColors.gray900,
                ),
              ),
            ],
          ),

          // Online Switch
          SizedBox(
            height: 44,
            child: Switch(
              value: isOnline,
              activeThumbColor: const Color(0xFFFF6B00),
              onChanged: (val) {
                HapticFeedback.mediumImpact();
                widget.onOnlineChanged(val);
                context.read<CaptainBloc>().add(ToggleOnlineStatus(val));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineGuidanceCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF141822).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B00).withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.power_settings_new_rounded,
                  color: Color(0xFFFF6B00),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ابدأ استقبال الطلبات الآن',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: isDark ? Colors.white : AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'قم بتفعيل زر الاتصال في الأعلى للبدء بربح المشاوير في صنعاء',
                      style: TextStyle(
                        fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF141822).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.8,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'جاري البحث عن طلبات قريبة في صنعاء...',
            style: TextStyle(
              fontSize: 13,
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
                  _selectedPinTitle ?? 'الموقع المختار',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: isDark ? Colors.white : AppColors.gray900,
                  ),
                ),
                if (_selectedPinSnippet != null && _selectedPinSnippet!.isNotEmpty)
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
            icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.gray500),
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
