import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';

import 'package:geolocator/geolocator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_map_view.dart';
import '../../../../core/services/routing_service.dart';
import 'package:latlong2/latlong.dart';
import '../../../ride/presentation/bloc/ride_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../ride/presentation/widgets/passenger/searching_captain_overlay.dart';
import '../../../ride/presentation/widgets/passenger/ride_selection_bottom_sheet.dart';
import '../../data/datasources/home_local_data_source.dart';
import '../widgets/home_action_buttons_row.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_ride_status_cards.dart';
import '../widgets/home_top_header.dart';
import '../widgets/quick_destinations_section.dart';
import '../widgets/recent_destinations_section.dart';
import 'location_search_page.dart';

/// HomeDashboardPage — Refactored Passenger Home Dashboard for Laffah (لَفّة).
/// Clean Architecture & Modular Widget Composition.
class HomeDashboardPage extends StatefulWidget {
  final String? initialDropoff;
  final LatLng? initialDropoffLatLng;

  const HomeDashboardPage({
    super.key,
    this.initialDropoff,
    this.initialDropoffLatLng,
  });

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

  late List<Map<String, dynamic>> _recentDestinations = [];
  bool _isNavigatedToTracking = false;

  @override
  void initState() {
    super.initState();
    _loadRecentDestinations();
    _fetchCurrentLocation();
    context.read<ProfileBloc>().add(GetSavedPlacesEvent());

    if (widget.initialDropoff != null && widget.initialDropoffLatLng != null) {
      _dropoffController.text = widget.initialDropoff!;
      _dropoffLatLng = widget.initialDropoffLatLng;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _calculateRouteIfNeeded();
        if (mounted) {
          _showRideSelection();
        }
      });
    }
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
      ).timeout(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          _pickupLatLng = LatLng(pos.latitude, pos.longitude);
        });
        // Refresh recent destinations with real distances now that we have location
        _loadRecentDestinations();
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
    // Calculate actual distances from current pickup location
    final List<Map<String, dynamic>> enriched = [];
    for (final item in recent) {
      final lat = (item['lat'] as num?)?.toDouble();
      final lon = (item['lon'] as num?)?.toDouble();
      String displayDistance = (item['distance'] as String?) ?? '— كم';
      if (lat != null && lon != null) {
        final meters = Geolocator.distanceBetween(
          _pickupLatLng.latitude,
          _pickupLatLng.longitude,
          lat,
          lon,
        );
        final km = meters / 1000;
        if (km < 1.0) {
          displayDistance = '${(meters).toStringAsFixed(0)} م';
        } else {
          displayDistance = '${km.toStringAsFixed(1)} كم';
        }
      }
      enriched.add({...item, 'distance': displayDistance});
    }
    if (mounted) {
      setState(() {
        _recentDestinations = enriched;
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
        'subtitle': result['address'] ?? 'وجهة تم البحث عنها',
        'lat': result['lat'],
        'lon': result['lon'],
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

  void _navigateToTracking({RideBookingConfirmed? confirmedState, RideAccepted? acceptedState}) {
    if (_isNavigatedToTracking) return;
    _isNavigatedToTracking = true;

    final String cid = (confirmedState != null)
        ? (confirmedState.captainId ?? confirmedState.rideId ?? '1')
        : (acceptedState?.captainId ?? '1');

    context.push(
      LaffahRoutes.passengerRideTracking,
      extra: {
        'captainId': cid,
        'captainName': confirmedState?.captainName ?? acceptedState?.captainName ?? 'الكابتن',
        'captainRating': confirmedState?.rating ?? acceptedState?.captainRating ?? 5.0,
        'vehicleModel': confirmedState?.vehicleModel ?? acceptedState?.vehicleModel ?? 'دراجة نارية',
        'vehiclePlate': confirmedState?.vehiclePlate ?? acceptedState?.vehiclePlate ?? '---',
        'pickupAddress': confirmedState?.pickup ?? _pickupController.text,
        'dropoffAddress': confirmedState?.dropoff ?? _dropoffController.text,
        'passengerLat': _pickupLatLng.latitude,
        'passengerLng': _pickupLatLng.longitude,
        'dropoffLat': _dropoffLatLng?.latitude,
        'dropoffLng': _dropoffLatLng?.longitude,
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          _isNavigatedToTracking = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<RideBloc, RideState>(
      listener: (context, state) {
        if (state is RideError) {
          _isNavigatedToTracking = false;
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
        } else if (state is RideInitial || state is RideSearching || (state is RideBookingConfirmed && state.status == 'pending')) {
          _isNavigatedToTracking = false;
        } else if (state is RideScheduledSuccess) {
          _isNavigatedToTracking = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'تم جدولة المشوار بنجاح سيتم إشعارك عند توفر كابتن',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else if (state is RideAccepted) {
          _navigateToTracking(acceptedState: state);
        } else if (state is RideBookingConfirmed &&
            (state.status == 'accepted' || state.status == 'arrived' || state.status == 'in_transit' || state.status == 'started')) {
          _navigateToTracking(confirmedState: state);
        } else if ((state is RideBookingConfirmed &&
                state.status.toLowerCase() == 'completed') ||
            state is RideCompleted) {
          final wasTracking = _isNavigatedToTracking;
          _isNavigatedToTracking = false;
          // If passenger is currently on the tracking screen, tracking screen pushes the invoice.
          // Prevent background HomeDashboardPage from pushing a duplicate invoice!
          if (wasTracking) {
            return;
          }

          final tripId = (state is RideBookingConfirmed)
              ? (state.rideId ?? 'TRIP')
              : 'TRIP';
          final fare = (state is RideBookingConfirmed)
              ? state.selectedOption.basePrice
              : 0.0;
          final captainName = (state is RideBookingConfirmed)
              ? state.captainName
              : 'الكابتن';
          final captainPhone =
              (state is RideBookingConfirmed) ? state.captainPhone : '';
          final vehicleModel =
              (state is RideBookingConfirmed) ? state.vehicleModel : 'دراجة نارية';
          final vehiclePlate =
              (state is RideBookingConfirmed) ? state.vehiclePlate : '';
          final pickup = (state is RideBookingConfirmed)
              ? state.pickup
              : _pickupController.text.trim();
          final dropoff = (state is RideBookingConfirmed)
              ? state.dropoff
              : (_dropoffController.text.trim().isNotEmpty
                  ? _dropoffController.text.trim()
                  : 'وجهة الوصول');
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
              'paymentMethod': (state is RideBookingConfirmed && state.paymentMethod == 'wallet') 
                  ? AppLocalizations.of(context)!.pass_ride_wallet 
                  : AppLocalizations.of(context)!.pass_ride_cash,
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
                      showDefaultMockData: false,
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
                        if (_isNavigatedToTracking) {
                          return const SizedBox.shrink();
                        }
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: _buildActiveRideMiniBanner(context, isDark, state),
                        );
                      } else if (s == 'pending' || state.captainName == 'قيد البحث') {
                        return const SizedBox.shrink();
                      }
                    } else if (state is RideAccepted) {
                      if (_isNavigatedToTracking) {
                        return const SizedBox.shrink();
                      }
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: _buildActiveRideMiniBanner(context, isDark, null, acceptedState: state),
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
              // LAYER 4: Interactive Top Header & Search Bar
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
                        nearbyCaptainsCount: (DateTime.now().minute % 6) + 3,
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
                        eta: '${state.selectedOption.etaMinutes} دقائق',
                        nearbyCaptainsCount: state.nearbyCaptainsCount,
                        onCancel: () {
                          context
                              .read<RideBloc>()
                              .add(const CancelRideRequested());
                          setState(() {
                            _dropoffController.clear();
                            _dropoffLatLng = null;
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
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, profileState) {
                    List<Map<String, dynamic>> dynamicQuickDestinations = [];
                    if (profileState is SavedPlacesLoaded && profileState.places.isNotEmpty) {
                      dynamicQuickDestinations = profileState.places.map((place) {
                        IconData icon;
                        Color color;
                        if (place.type == 'home') {
                          icon = Icons.home_rounded;
                          color = AppColors.primary500;
                        } else if (place.type == 'work') {
                          icon = Icons.work_rounded;
                          color = AppColors.info;
                        } else {
                          icon = Icons.star_rounded;
                          color = AppColors.warning;
                        }
                        return {
                          'title': place.name,
                          'location': place.address,
                          'icon': icon,
                          'color': color,
                          'lat': place.lat,
                          'lng': place.lng,
                        };
                      }).toList();
                    } else {
                      // Fallback or empty if not loaded yet
                      dynamicQuickDestinations = [
                        {
                          'title': 'أماكن محفوظة',
                          'location': 'اضغط للإضافة',
                          'icon': Icons.bookmark_add_rounded,
                          'color': AppColors.gray500,
                        }
                      ];
                    }
                    
                    return QuickDestinationsSection(
                      isDark: isDark,
                      destinations: dynamicQuickDestinations,
                      selectedIndex: _selectedQuickIndex,
                      onDestinationSelected: (index, dest) {
                        setState(() {
                          _selectedQuickIndex = index;
                          _dropoffController.text = dest['location'] as String;
                          if (dest['lat'] != null && dest['lng'] != null) {
                            _dropoffLatLng = LatLng(dest['lat'] as double, dest['lng'] as double);
                          }
                        });
                        
                        if (dest['title'] == 'أماكن محفوظة' && dest['lat'] == null) {
                          context.push(LaffahRoutes.passengerSavedPlaces);
                        } else {
                          _showRideSelection();
                        }
                      },
                    );
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

  /// Sleek floating mini-banner displayed at the bottom of the Home screen
  /// only if an active trip is ongoing and the passenger temporarily leaves the tracking screen.
  Widget _buildActiveRideMiniBanner(
    BuildContext context,
    bool isDark,
    RideBookingConfirmed? confirmedState, {
    RideAccepted? acceptedState,
  }) {
    final captainName = (confirmedState != null && confirmedState.captainName.isNotEmpty)
        ? confirmedState.captainName
        : ((acceptedState != null && acceptedState.captainName.isNotEmpty)
            ? acceptedState.captainName
            : 'الكابتن');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToTracking(
                confirmedState: confirmedState,
                acceptedState: acceptedState,
              ),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B2232) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary500.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.two_wheeler_rounded,
                          color: AppColors.primary500,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00C853),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'مشوار جارٍ مع $captainName',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.gray900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'انقر هنا للعودة إلى تفاصيل المشوار والتتبع 📍',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11,
                              color: AppColors.primary500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF263044) : AppColors.gray100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: isDark ? Colors.white70 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
