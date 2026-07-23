import 'package:flutter/material.dart';
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

import '../../../../core/di/injection_container.dart' as di;

/// CaptainHomePage - The primary dashboard/map dashboard screen for Laffah Captains.
/// Houses the online/offline switch, the simulated interactive map, incoming request popups,
/// and the primary driver tab bar.
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
            const _CaptainTripsSubPage(),
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
                fontSize: 10,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w600,
                fontSize: 9,
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
            // When returning, toggle offline or online
            context.read<CaptainBloc>().add(const ToggleOnlineStatus(false));
            onOnlineChanged(false);
          });
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            // Mock map background with streets
            Positioned.fill(
              child: _buildMockMap(context, isDark, state),
            ),

            // Top Status Panel (Screenshot 1: "متصل الآن" toggle)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.s12,
              left: AppSpacing.s16,
              right: AppSpacing.s16,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: GlassBox(
                  borderRadius: AppSpacing.radiusLG,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: isOnline ? AppColors.success : AppColors.gray500,
                              shape: BoxShape.circle,
                              boxShadow: isOnline
                                  ? [
                                      BoxShadow(
                                        color: AppColors.success.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                          AppSpacing.w10,
                          Text(
                            isOnline ? 'متصل الآن' : 'أنت منقطع حالياً',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ],
                      ),
                      // Custom switch
                      Switch.adaptive(
                        value: isOnline,
                        activeColor: AppColors.primary500,
                        onChanged: (val) {
                          onOnlineChanged(val);
                          context.read<CaptainBloc>().add(ToggleOnlineStatus(val));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Default Offline/Online guidance tips
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
                        width: 16,
                        height: 16,
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

            // Popup Request Dialog (Screenshot 1 Overlay)
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
                    context.read<CaptainBloc>().add(const AcceptTrip());
                  },
                  onReject: () {
                    context.read<CaptainBloc>().add(const RejectTrip());
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  // Draw interactive custom vector line mock map
  Widget _buildMockMap(BuildContext context, bool isDark, CaptainState state) {
    return LaffahMapView(
      isDark: isDark,
      showDefaultMockData: state is! CaptainOffline,
    );
  }
}

/// Custom map street grid visual painter
class _MapGridPainter extends CustomPainter {
  final bool isDark;
  final bool isOnline;

  _MapGridPainter({required this.isDark, required this.isOnline});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04)
      ..strokeWidth = 3.0;

    final primaryStreetsPaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.06)
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = AppColors.primary500.withOpacity(0.8)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw background grid lines
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    for (double j = 0; j < size.height; j += 40) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), linePaint);
    }

    // Draw major simulated streets in Sana'a
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.5), primaryStreetsPaint); // Haddah Street
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.6, size.height), primaryStreetsPaint); // Siyeen Street
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.7), primaryStreetsPaint); // Zubairy Street

    // Draw Captain marker indicator
    final captainPaint = Paint()
      ..color = AppColors.primary500
      ..style = PaintingStyle.fill;

    final ringPaint = Paint()
      ..color = AppColors.primary300.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final captainCenter = Offset(size.width * 0.45, size.height * 0.45);
    
    if (isOnline) {
      canvas.drawCircle(captainCenter, 22.0, ringPaint);
    }
    canvas.drawCircle(captainCenter, 10.0, captainPaint);

    // Draw Passenger/Pickup pulsing marker if searching/matched
    final passengerCenter = Offset(size.width * 0.65, size.height * 0.32);
    final passPaint = Paint()
      ..color = AppColors.info
      ..style = PaintingStyle.fill;

    if (isOnline) {
      canvas.drawCircle(passengerCenter, 8.0, passPaint);
      // Draw route trajectory
      final path = Path()
        ..moveTo(captainCenter.dx, captainCenter.dy)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.35, passengerCenter.dx, passengerCenter.dy);
      canvas.drawPath(path, routePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Sub-Page: Captain Trip History (Screenshot 3 layout)
class _CaptainTripsSubPage extends StatelessWidget {
  const _CaptainTripsSubPage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> trips = [
      {
        'id': 'LF-88293',
        'status': 'قيد التنفيذ',
        'statusColor': AppColors.warning,
        'pickup': 'شارع الستين - صنعاء، اليمن',
        'dropoff': 'مول العرب - شارع حدة',
        'price': '2,400 ريال',
        'date': 'اليوم، 10:30 ص',
      },
      {
        'id': 'LF-88290',
        'status': 'بانتظار التأكيد',
        'statusColor': AppColors.info,
        'pickup': 'فندق السعيد - تعز',
        'dropoff': 'شارع جمال - وسط المدينة',
        'price': '1,800 ريال',
        'date': 'اليوم، 09:15 ص',
      },
      {
        'id': 'LF-88285',
        'status': 'تم الانتهاء',
        'statusColor': AppColors.success,
        'pickup': 'خور مكسر - عدن',
        'dropoff': 'مطار عدن الدولي',
        'price': '1,800 ريال',
        'date': 'أمس، 08:00 م',
      }
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الرحلات',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: 'IBM Plex Sans Arabic',
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          children: [
            // Search input field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.white,
                borderRadius: AppSpacing.borderLG,
                border: Border.all(
                  color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray200,
                ),
              ),
              child: const TextField(
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'البحث عن رحلة...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search_rounded, color: AppColors.gray500),
                ),
              ),
            ),
            
            AppSpacing.h20,

            // Build list
            ...trips.map((trip) {
              return GlassBox(
                margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                borderRadius: AppSpacing.radiusLG,
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: ID & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'رقم الرحلة: ${trip['id']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.gray500 : AppColors.gray600,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10, vertical: AppSpacing.s4),
                          decoration: BoxDecoration(
                            color: (trip['statusColor'] as Color).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            trip['status'],
                            style: TextStyle(
                              fontSize: 10,
                              color: trip['statusColor'] as Color,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.h12,

                    // Row 2: Route details
                    Row(
                      children: [
                        const Icon(Icons.radio_button_checked_rounded, color: AppColors.primary500, size: 14),
                        AppSpacing.w10,
                        Expanded(
                          child: Text(
                            trip['pickup'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Container(
                        width: 1.5,
                        height: 12,
                        color: isDark ? AppColors.white.withOpacity(0.12) : AppColors.gray300,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.place_rounded, color: AppColors.danger, size: 14),
                        AppSpacing.w10,
                        Expanded(
                          child: Text(
                            trip['dropoff'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
                      child: Divider(height: 1),
                    ),

                    // Price & Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          trip['price'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.primary500,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                        Text(
                          trip['date'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.gray500,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
