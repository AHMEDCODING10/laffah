import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:geolocator/geolocator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_map_view.dart';
import '../../../../core/services/routing_service.dart';
import 'package:latlong2/latlong.dart';
import '../../../ride/presentation/bloc/ride_bloc.dart';
import '../../../ride/presentation/widgets/passenger/searching_captain_overlay.dart';
import '../../../ride/presentation/widgets/passenger/ride_selection_bottom_sheet.dart';
import '../../data/datasources/home_local_data_source.dart';
import '../widgets/home_action_buttons_row.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_ride_status_cards.dart';
import '../widgets/captain_on_the_way_card.dart';
import '../widgets/home_top_header.dart';
import '../widgets/quick_destinations_section.dart';
import '../widgets/recent_destinations_section.dart';
import 'location_search_page.dart';

/// HomeDashboardPage — Refactored Passenger Home Dashboard for Laffah (لَفّة).
/// Clean Architecture & Modular Widget Composition.
class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _pickupController =
      TextEditingController(text: 'موقعك الحالي');
  final TextEditingController _dropoffController = TextEditingController();
  LatLng _pickupLatLng = const LatLng(15.3694, 44.1910);
  LatLng? _dropoffLatLng;

  final RoutingService _routingService = RoutingService();
  List<LatLng>? _activeRoutePoints;
  LatLng? _captainPos;

  int _selectedQuickIndex = -1;

  late List<Map<String, dynamic>> _quickDestinations = [];
  late List<Map<String, dynamic>> _recentDestinations = [];

  @override
  void initState() {
    super.initState();
    _loadRecentDestinations();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        if (mounted) {
          _showLocationPermissionDialog();
        }
        return;
      }
      
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        if (mounted) {
          _showLocationPermissionDialog(isServiceDisabled: true);
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (mounted) {
        setState(() {
          _pickupLatLng = LatLng(pos.latitude, pos.longitude);
        });
      }
    } catch (_) {
      // Fallback remains Sanaa Center
    }
  }

  void _showLocationPermissionDialog({bool isServiceDisabled = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.location_disabled_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              isServiceDisabled ? 'تفعيل الـ GPS' : 'صلاحية الموقع',
              style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 18),
            ),
          ],
        ),
        content: Text(
          isServiceDisabled
              ? 'يرجى تفعيل خدمة تحديد الموقع (GPS) في هاتفك لتتمكن من استخدام التطبيق.'
              : 'للحصول على أفضل تجربة وتحديد موقعك بدقة، يرجى السماح للتطبيق بالوصول إلى موقعك من إعدادات الهاتف.',
          style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (isServiceDisabled) {
                Geolocator.openLocationSettings();
              } else {
                Geolocator.openAppSettings();
              }
            },
            child: const Text('فتح الإعدادات', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadRecentDestinations() async {
    final recent = await HomeLocalDataSource.getRecentDestinations();
    if (mounted) {
      setState(() {
        _recentDestinations = recent;
      });
    }
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  Future<void> _calculateRouteIfNeeded() async {
    final dest = _dropoffLatLng ?? const LatLng(15.3524, 44.2147);
    final route = await _routingService.getRoute(_pickupLatLng, dest);
    if (route != null && mounted) {
      setState(() {
        _activeRoutePoints = route.points;
        _captainPos = LatLng(_pickupLatLng.latitude + 0.0025, _pickupLatLng.longitude + 0.0025);
      });
    }
  }

  Future<void> _openSearchAndSelectRide() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LocationSearchPage(locationType: 'dropoff'),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _dropoffController.text = result['name'] ?? '';
        _dropoffLatLng = LatLng(
          result['lat'] as double,
          result['lon'] as double,
        );
      });
      _calculateRouteIfNeeded();
      // Save it as a recent destination
      await HomeLocalDataSource.saveRecentDestination({
        'title': result['name'],
        'subtitle': 'وجهة تم البحث عنها',
        'distance': '0 كم',
      });
      _loadRecentDestinations(); // Refresh
      _showRideSelection();
    }
  }

  void _handleRequestRideTap() {
    if (_dropoffController.text.trim().isEmpty) {
      // Destination not chosen yet -> Navigate directly to search screen
      _openSearchAndSelectRide();
    } else {
      _showRideSelection();
    }
  }

  void _showRideSelection() {
    if (_dropoffController.text.trim().isEmpty) {
      _openSearchAndSelectRide();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<RideBloc>()),
        ],
        child: RideSelectionBottomSheet(
          pickup: _pickupController.text.trim().isNotEmpty
              ? _pickupController.text.trim()
              : 'موقعي الحالي',
          dropoff: _dropoffController.text.trim(),
          pickupLatLng: _pickupLatLng,
          dropoffLatLng: _dropoffLatLng,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _quickDestinations = HomeLocalDataSource.getQuickDestinations(context);

    return BlocConsumer<RideBloc, RideState>(
      listener: (context, state) {
        if (state is RideError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else if ((state is RideBookingConfirmed &&
                state.status.toLowerCase() == 'completed') ||
            state is RideCompleted) {
          final tripId = (state is RideBookingConfirmed)
              ? (state.rideId ?? 'TRIP')
              : 'TRIP';
          final fare = (state is RideBookingConfirmed)
              ? state.selectedOption.basePrice
              : 1083.0;
          final captainName = (state is RideBookingConfirmed)
              ? state.captainName
              : 'علي صالح صالح';
          final captainPhone =
              (state is RideBookingConfirmed) ? state.captainPhone : '';
          final vehicleModel =
              (state is RideBookingConfirmed) ? state.vehicleModel : 'دراجة نارية';
          final vehiclePlate =
              (state is RideBookingConfirmed) ? state.vehiclePlate : 'صنعاء';
          final pickup = (state is RideBookingConfirmed)
              ? state.pickup
              : _pickupController.text.trim();
          final dropoff = (state is RideBookingConfirmed)
              ? state.dropoff
              : (_dropoffController.text.trim().isNotEmpty
                  ? _dropoffController.text.trim()
                  : 'شارع الزبيري');
          final rating = (state is RideBookingConfirmed) ? state.rating : 5.0;

          context.push(
            LaffahRoutes.passengerRideInvoice,
            extra: {
              'tripId': tripId,
              'fare': fare,
              'captainName': captainName,
              'captainPhone': captainPhone,
              'vehicleModel': vehicleModel,
              'vehiclePlate': vehiclePlate,
              'pickup': pickup,
              'dropoff': dropoff,
              'rating': rating,
              'distance': '6.3 كم',
              'duration': '7 دقيقة',
              'paymentMethod': 'نقداً (Cash)',
            },
          );
        }
      },
      builder: (context, rideState) {
        final bool hideBottomNav = rideState is RideSearching ||
            rideState is RideBookingConfirmed ||
            rideState is RideAccepted ||
            rideState is RideInProgress;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor:
              isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          resizeToAvoidBottomInset: false,
          extendBody: true,
          bottomNavigationBar: hideBottomNav
              ? null
              : HomeBottomNavBar(isDark: isDark, currentIndex: 0),
          body: Stack(
            fit: StackFit.expand,
            children: [
              // ==========================================
              // LAYER 1: Interactive Simulated Map Component
              // ==========================================
              Positioned.fill(
                child: BlocBuilder<RideBloc, RideState>(
                  builder: (context, state) {
                    String status = 'idle';
                    if (state is RideBookingConfirmed) {
                      status = state.status;
                    }
                    final bool hasActiveRide = status == 'accepted' ||
                        status == 'arrived' ||
                        status == 'in_transit' ||
                        status == 'started';

                    return LaffahMapView(
                      isDark: isDark,
                      showDefaultMockData: status != 'idle' &&
                          (_activeRoutePoints == null || _activeRoutePoints!.isEmpty),
                      initialCenter: _dropoffLatLng ?? _pickupLatLng,
                      dropoffLocation: _dropoffLatLng,
                      passengerLocation: _pickupLatLng,
                      captainLocation: hasActiveRide ? _captainPos : null,
                      routePoints: _activeRoutePoints,
                      followCaptain: hasActiveRide,
                    );
                  },
                ),
              ),

              // ==========================================
              // LAYER 2: Safety Gradient Overlays
              // ==========================================
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 180,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          isDark
                              ? AppColors.backgroundDark.withValues(alpha: 0.9)
                              : AppColors.white.withValues(alpha: 0.9),
                          isDark
                              ? AppColors.backgroundDark.withValues(alpha: 0.4)
                              : AppColors.white.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ==========================================
              // LAYER 3: Dynamic Bottom Panel / Captain on the Way Card
              // ==========================================
              Positioned.fill(
                child: BlocBuilder<RideBloc, RideState>(
                  builder: (context, state) {
                    if (state is RideBookingConfirmed) {
                      final s = state.status.toLowerCase();
                      if (s == 'completed') {
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: RideCompletedCard(state: state),
                          ),
                        );
                      } else if (s == 'in_transit' ||
                          s == 'started' ||
                          s == 'in_progress' ||
                          s == 'accepted' ||
                          s == 'arrived' ||
                          s == 'found' ||
                          (state.captainName.isNotEmpty &&
                              state.captainName != 'قيد البحث' &&
                              s != 'pending')) {
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: CaptainOnTheWayCard(state: state),
                        );
                      } else if (s == 'pending' || state.captainName == 'قيد البحث') {
                        return const SizedBox.shrink();
                      }
                    } else if (state is RideAccepted) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: CaptainOnTheWayCard(
                          state: RideBookingConfirmed(
                            pickup: _pickupController.text.trim(),
                            dropoff: _dropoffController.text.trim(),
                            selectedOption: const RideOption(
                              id: 'laffah',
                              titleAr: 'لَفّة',
                              titleEn: 'Laffah',
                              basePrice: 1250.0,
                              etaMinutes: 5,
                              iconKey: 'car',
                              descriptionAr: 'لَفّة',
                            ),
                            captainName: state.captainName,
                            captainPhone: '',
                            vehicleModel: state.vehicleModel,
                            vehiclePlate: state.vehiclePlate,
                            rating: state.captainRating,
                            status: 'accepted',
                          ),
                        ),
                      );
                    } else if (state is ParcelSubmitted) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ParcelSubmittedCard(state: state),
                        ),
                      );
                    } else if (state is RideCompleted) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RideCompletedCard(
                            state: RideBookingConfirmed(
                              pickup: _pickupController.text.trim(),
                              dropoff: _dropoffController.text.trim().isNotEmpty
                                  ? _dropoffController.text.trim()
                                  : 'وجهتك',
                              selectedOption: const RideOption(
                                id: 'laffah',
                                titleAr: 'لَفّة',
                                titleEn: 'Laffah',
                                basePrice: 1250.0,
                                etaMinutes: 5,
                                iconKey: 'car',
                                descriptionAr: 'لَفّة',
                              ),
                              captainName: 'كابتن لَفَّة',
                              captainPhone: '',
                              vehicleModel: 'دراجة نارية',
                              vehiclePlate: '---',
                              rating: 5.0,
                              status: 'completed',
                            ),
                          ),
                        ),
                      );
                    }

                    // Default Draggable & Collapsible Home Panel
                    return _buildStitchHomePanel(context, isDark);
                  },
                ),
              ),

              // ==========================================
              // LAYER 4: Interactive Top Header & Search Bar / Captain On The Way
              // ==========================================
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: BlocBuilder<RideBloc, RideState>(
                    builder: (context, state) {
                      final bool isSearching = state is RideSearching ||
                          (state is RideBookingConfirmed &&
                              (state.status == 'pending' ||
                                  state.captainName == 'قيد البحث'));

                      if (isSearching) {
                        return const SizedBox.shrink();
                      }

                      final bool isCaptainActive = (state is RideBookingConfirmed &&
                              (state.status == 'accepted' ||
                                  state.status == 'arrived' ||
                                  state.status == 'in_transit' ||
                                  state.status == 'started' ||
                                  state.status == 'completed' ||
                                  state.status == 'found' ||
                                  (state.captainName.isNotEmpty &&
                                      state.captainName != 'قيد البحث'))) ||
                          state is RideAccepted ||
                          state is RideCompleted;

                      if (isCaptainActive) {
                        final bool isCompleted = (state is RideBookingConfirmed &&
                                state.status.toLowerCase() == 'completed') ||
                            state is RideCompleted;
                        final bool isArrived = state is RideBookingConfirmed &&
                            state.status.toLowerCase() == 'arrived';
                        final bool isInTransit = state is RideBookingConfirmed &&
                            (state.status.toLowerCase() == 'in_transit' ||
                                state.status.toLowerCase() == 'started');
                        return _buildCaptainOnTheWayTopHeader(
                          context,
                          isDark,
                          isCompleted: isCompleted,
                          isArrived: isArrived,
                          isInTransit: isInTransit,
                        );
                      }

                      return HomeTopHeader(
                        isDark: isDark,
                        dropoffController: _dropoffController,
                        onSearchTap: _openSearchAndSelectRide,
                      );
                    },
                  ),
                ),
              ),

              // ==========================================
              // LAYER 5: Full-screen Searching Captain Overlay
              // ==========================================
              Positioned.fill(
                child: BlocBuilder<RideBloc, RideState>(
                  builder: (context, state) {
                    if (state is RideSearching) {
                      return SearchingCaptainOverlay(
                        pickup: _pickupController.text.trim().isNotEmpty
                            ? _pickupController.text.trim()
                            : null,
                        dropoff: _dropoffController.text.trim().isNotEmpty
                            ? _dropoffController.text.trim()
                            : null,
                        price: state.price,
                        onCancel: () {
                          context
                              .read<RideBloc>()
                              .add(const CancelRideRequested());
                        },
                      );
                    }
                    if (state is RideBookingConfirmed &&
                        (state.status == 'pending' || state.captainName == 'قيد البحث')) {
                      return SearchingCaptainOverlay(
                        pickup: state.pickup.isNotEmpty
                            ? state.pickup
                            : _pickupController.text.trim(),
                        dropoff: state.dropoff.isNotEmpty
                            ? state.dropoff
                            : _dropoffController.text.trim(),
                        price: state.selectedOption.basePrice,
                        vehicleTier: state.selectedOption.titleAr,
                        onCancel: () {
                          context
                              .read<RideBloc>()
                              .add(const CancelRideRequested());
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
      },
    );
  }

  // Draggable Home Panel Composition
  Widget _buildStitchHomePanel(BuildContext context, bool isDark) {
    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.20,
      maxChildSize: 0.68,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16,
            0,
            AppSpacing.s16,
            90,
          ),
          child: GlassBox(
            borderRadius: AppSpacing.radiusLG,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              10,
              AppSpacing.s16,
              AppSpacing.s16,
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 12),
              physics: const BouncingScrollPhysics(),
              children: [
                // Drag Handle Indicator Pill
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.white.withValues(alpha: 0.25)
                          : AppColors.gray300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Main Action Buttons (طلب مشوار / إرسال طرد)
                HomeActionButtonsRow(
                  isDark: isDark,
                  onRequestRideTap: _handleRequestRideTap,
                  onSendParcelTap: () =>
                      context.push(LaffahRoutes.passengerParcelSend),
                ),

                AppSpacing.h16,

                // Section: "وجهات سريعة"
                QuickDestinationsSection(
                  isDark: isDark,
                  destinations: _quickDestinations,
                  selectedIndex: _selectedQuickIndex,
                  onDestinationSelected: (index, dest) {
                    setState(() {
                      _selectedQuickIndex = index;
                      _dropoffController.text = dest['location'] as String;
                    });
                    _showRideSelection();
                  },
                ),

                AppSpacing.h16,

                // Section: "آخر الوجهات"
                RecentDestinationsSection(
                  isDark: isDark,
                  recentDestinations: _recentDestinations,
                  onRecentSelected: (item) {
                    setState(() {
                      _dropoffController.text = item['title'] as String;
                    });
                    _showRideSelection();
                  },
                ),

                // Search Trigger CTA (if destination selected)
                if (_dropoffController.text.isNotEmpty) ...[
                  AppSpacing.h16,
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _showRideSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: AppColors.white,
                        elevation: 4,
                        shadowColor:
                            AppColors.primary500.withValues(alpha: 0.4),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppSpacing.radiusMD,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'أكّد وجهتك واحسب الأجرة',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: AppColors.white,
                            ),
                          ),
                          AppSpacing.w10,
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Top floating header displayed when a captain accepts, arrives, starts, or completes trip
  Widget _buildCaptainOnTheWayTopHeader(
    BuildContext context,
    bool isDark, {
    bool isCompleted = false,
    bool isArrived = false,
    bool isInTransit = false,
  }) {
    Color themeColor = AppColors.primary500;
    String title = 'الكابتن في الطريق إليك';
    String iconTag = '🛵';
    IconData iconData = Icons.two_wheeler_rounded;
    String subtitle = 'يرجى التواجد في نقطة الانطلاق المحددة';

    if (isCompleted) {
      themeColor = const Color(0xFF00C853);
      title = 'اكتمل المشوار بنجاح!';
      iconTag = '🎉';
      iconData = Icons.verified_rounded;
      subtitle = 'شكراً لاختيارك لَفَّة، نتمنى لك يوماً سعيداً';
    } else if (isArrived) {
      themeColor = const Color(0xFF00C853);
      title = 'وصل الكابتن إلى موقعك!';
      iconTag = '📍';
      iconData = Icons.where_to_vote_rounded;
      subtitle = 'الكابتن ينتظرك الآن عند نقطة الانطلاق';
    } else if (isInTransit) {
      themeColor = AppColors.primary500;
      title = 'في الطريق إلى الوجهة';
      iconTag = '🚀';
      iconData = Icons.navigation_rounded;
      subtitle = 'نتمنى لك رحلة آمنة ومريحة مع لَفَّة';
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B2232) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: themeColor.withValues(alpha: isArrived ? 0.6 : 0.25),
            width: isArrived ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isArrived
                  ? const Color(0xFF00C853).withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Glowing pulsing icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: themeColor,
                  width: 1.5,
                ),
              ),
              child: Icon(
                iconData,
                color: themeColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Title & Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: themeColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(iconTag, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: themeColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Notifications Shortcut
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF263044) : AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none_rounded, size: 20),
                color: isDark ? AppColors.white : AppColors.gray700,
                onPressed: () => context.push(LaffahRoutes.passengerNotifications),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
