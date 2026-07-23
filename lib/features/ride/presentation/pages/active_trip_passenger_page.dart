import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/laffah_map_view.dart';
import '../bloc/ride_bloc.dart';
import '../bloc/ride_state.dart';
import '../bloc/ride_event.dart';

import '../widgets/searching_captain_overlay.dart';
import '../widgets/captain_en_route_card.dart';

/// ActiveTripPassengerPage — Main live tracking screen for the passenger.
/// Displays the Google Map, route polyline, and dynamically switches between:
/// 1. Searching for Captain
/// 2. Captain En Route
/// 3. Trip Active (In Progress)
class ActiveTripPassengerPage extends StatefulWidget {
  const ActiveTripPassengerPage({super.key});

  @override
  State<ActiveTripPassengerPage> createState() => _ActiveTripPassengerPageState();
}

class _ActiveTripPassengerPageState extends State<ActiveTripPassengerPage> {
  void _handleCancelRide() {
    // Show a confirmation dialog before cancelling
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.radiusMD,
          ),
          title: const Text(
            'إلغاء الرحلة',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في إلغاء هذه الرحلة؟ قد يتم تطبيق رسوم إلغاء.',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'تراجع',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                context.read<RideBloc>().add(CancelRideRequested(reason: 'إلغاء من قبل الراكب'));
                context.go(LaffahRoutes.passengerHome);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.radiusSM,
                ),
              ),
              child: const Text(
                'تأكيد الإلغاء',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BlocConsumer<RideBloc, RideState>(
          listener: (context, state) {
            if (state is RideCompleted) {
              // Navigate to invoice or rating
              context.go(LaffahRoutes.passengerRideInvoice);
            } else if (state is RideInitial) {
              // Ride was cancelled or finished
              context.go(LaffahRoutes.passengerHome);
            }
          },
          builder: (context, state) {
            // Default dummy data if state doesn't have it
            String captainName = 'محمد علي';
            String motorcycleModel = 'سوزوكي 150cc • أحمر';
            String licensePlate = '10293 صنعاء';
            double rating = 4.8;
            String eta = '4 دقيقة';

            if (state is RideAccepted) {
              captainName = state.captainName;
              motorcycleModel = state.vehicleModel;
              licensePlate = state.vehiclePlate;
              rating = state.captainRating;
              eta = state.eta;
            } else if (state is RideInProgress) {
              // When ride is in progress, the captain is already with the passenger
              eta = state.etaToDestination; 
            }

            return Stack(
              children: [
                // 1. The Map Background
                // (In a real app, LaffahMapView would take markers for pickup/dropoff/captain)
                Positioned.fill(
                  child: LaffahMapView(
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
                ),

                // 2. Safe Area Top Action Bar
                Positioned(
                  top: MediaQuery.of(context).padding.top + AppSpacing.s12,
                  left: AppSpacing.s16,
                  right: AppSpacing.s16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: isDark ? AppColors.white : AppColors.gray900,
                          ),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(LaffahRoutes.passengerHome);
                            }
                          },
                        ),
                      ),
                      
                      // SOS Emergency Button
                      if (state is RideAccepted || state is RideInProgress)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: AppSpacing.radiusFull,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.danger.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => context.push(LaffahRoutes.passengerReportIncident),
                              borderRadius: AppSpacing.radiusFull,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Row(
                                  children: [
                                    Icon(Icons.shield_rounded, color: Colors.white, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'طوارئ',
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 3. Bottom Sheet Overlay Logic
                if (state is RideSearching)
                  Positioned.fill(
                    child: SearchingCaptainOverlay(
                      onCancel: () {
                        context.read<RideBloc>().add(CancelRideRequested(reason: 'إلغاء البحث'));
                        context.go(LaffahRoutes.passengerHome);
                      },
                    ),
                  )
                else if (state is RideAccepted)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CaptainEnRouteCard(
                      captainName: captainName,
                      motorcycleModel: motorcycleModel,
                      licensePlate: licensePlate,
                      rating: rating,
                      eta: eta,
                      onCall: () {},
                      onMessage: () {},
                      onCancel: _handleCancelRide,
                    ),
                  )
                else if (state is RideInProgress)
                  // Compact card for when the ride is active
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: 24,
                        left: 20,
                        right: 20,
                        bottom: MediaQuery.of(context).padding.bottom + 20,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF111827) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.motorcycle_rounded, color: Color(0xFFFF6B00), size: 28),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'الرحلة جارية الآن',
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      'يرجى الالتزام بإرشادات السلامة وارتداء الخوذة',
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontSize: 12,
                                        color: AppColors.gray500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الوقت المتبقي للوصول:',
                                    style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontSize: 12,
                                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                                    ),
                                  ),
                                  Text(
                                    eta,
                                    style: const TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFFF6B00),
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // For simulation purposes: manually trigger completion
                                  context.read<RideBloc>().add(SimulateRideStep(step: 3));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B00),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppSpacing.radiusMD,
                                  ),
                                ),
                                child: const Text(
                                  'إنهاء الرحلة (للتجربة)',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

