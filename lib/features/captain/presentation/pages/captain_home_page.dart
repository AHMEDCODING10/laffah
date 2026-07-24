import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_map_view.dart';
import '../bloc/captain_bloc.dart';
import '../bloc/captain_event.dart';
import '../bloc/captain_state.dart';
import 'widgets/trip_request_dialog.dart';
import 'captain_navigation_page.dart';
import 'captain_earnings_page.dart';
import 'captain_account_page.dart';
import 'captain_notifications_page.dart';
import 'captain_trips_sub_page.dart';

import '../../../../core/di/injection_container.dart' as di;

/// CaptainHomePage - The primary dashboard/map dashboard screen for Laffah Captains.
/// Fully customized for Android Native Performance & Laffah Design System V2.0.
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

    // Apply Android System Bar overlay
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? AppColors.surfaceDark : AppColors.white,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return BlocProvider(
      create: (context) => di.sl<CaptainBloc>(),
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: IndexedStack(
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
        bottomNavigationBar: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                HapticFeedback.selectionClick();
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
              selectedItemColor: AppColors.primary500,
              unselectedItemColor: AppColors.gray500,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.navigation_rounded),
                  activeIcon: Icon(Icons.navigation_rounded, color: AppColors.primary500),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_rounded),
                  activeIcon: Icon(Icons.receipt_long_rounded, color: AppColors.primary500),
                  label: 'الرحلات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_rounded),
                  activeIcon: Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary500),
                  label: 'الأرباح',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_rounded),
                  activeIcon: Icon(Icons.notifications_rounded, color: AppColors.primary500),
                  label: 'التنبيهات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  activeIcon: Icon(Icons.person_rounded, color: AppColors.primary500),
                  label: 'الحساب',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Home Map view implementation incorporating online switch and request handling
class _HomeMapSubPage extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onOnlineChanged;

  const _HomeMapSubPage({
    required this.isOnline,
    required this.onOnlineChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<CaptainBloc, CaptainState>(
      listener: (context, state) {
        if (state is TripAccepted) {
          // Push captain navigation screen once a trip is accepted
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CaptainNavigationPage(
                tripId: state.tripId,
                passengerName: state.passengerName,
                passengerPhone: state.passengerPhone,
                passengerRating: state.passengerRating,
                pickup: state.pickup,
                dropoff: state.dropoff,
                fare: state.fare,
                distance: state.distance,
                duration: state.duration,
              ),
            ),
          ).then((_) {
            // When returning, toggle offline
            if (context.mounted) {
              context.read<CaptainBloc>().add(const ToggleOnlineStatus(false));
              onOnlineChanged(false);
            }
          });
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            // Mock map background with streets
            Positioned.fill(
              child: LaffahMapView(
                isDark: isDark,
                showDefaultMockData: state is! CaptainOffline,
              ),
            ),

            // Top Status Panel (Status bar & Online Toggle)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.s12,
              left: AppSpacing.s16,
              right: AppSpacing.s16,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: GlassBox(
                  borderRadius: AppSpacing.radiusLG,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
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
                                        color: AppColors.success.withOpacity(0.6),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                          AppSpacing.w10,
                          Text(
                            isOnline ? 'متصل الآن (جاهز لاستقبال الطلبات)' : 'أنت منقطع حالياً',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ],
                      ),
                      // Standard Android Material Switch with Haptic Feedback & Touch Padding
                      SizedBox(
                        height: 48,
                        child: Switch(
                          value: isOnline,
                          activeColor: AppColors.primary500,
                          onChanged: (val) {
                            HapticFeedback.mediumImpact();
                            onOnlineChanged(val);
                            context.read<CaptainBloc>().add(ToggleOnlineStatus(val));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Guidance cards
            if (state is CaptainOffline)
              Positioned(
                bottom: AppSpacing.s32,
                left: AppSpacing.s24,
                right: AppSpacing.s24,
                child: GlassBox(
                  borderRadius: AppSpacing.radiusLG,
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.offline_bolt_rounded,
                        size: 36,
                        color: AppColors.primary500.withOpacity(0.7),
                      ),
                      AppSpacing.h8,
                      const Text(
                        'ابدأ استقبال الطلبات الآن',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      AppSpacing.h4,
                      const Text(
                        'قم بتفعيل زر الاتصال في الأعلى للبدء بربح المشاوير في صنعاء',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.gray500,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (state is CaptainOnline)
              Positioned(
                bottom: AppSpacing.s32,
                left: AppSpacing.s24,
                right: AppSpacing.s24,
                child: GlassBox(
                  borderRadius: AppSpacing.radiusLG,
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary500),
                        ),
                      ),
                      AppSpacing.w16,
                      const Text(
                        'جاري البحث عن طلبات قريبة منك...',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Incoming Request Overlay Dialog
            if (state is IncomingTripRequest)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: TripRequestDialog(
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
                ),
              ),
          ],
        );
      },
    );
  }
}
