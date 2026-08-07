import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_map_view.dart';
import '../../../parcel/presentation/widgets/parcel_delivery_form_bottom_sheet.dart';
import '../../../ride/presentation/bloc/ride_bloc.dart';
<<<<<<< HEAD
import '../../../ride/presentation/bloc/ride_event.dart';
import '../../../ride/presentation/bloc/ride_state.dart';
import '../../../ride/presentation/widgets/passenger/searching_captain_overlay.dart';
import '../../../ride/presentation/widgets/ride_selection_bottom_sheet.dart';
import '../../data/datasources/fake_home_repository.dart';
=======
import '../../../ride/presentation/widgets/passenger/searching_captain_overlay.dart';
import '../../../ride/presentation/widgets/passenger/ride_selection_bottom_sheet.dart';
import '../../data/datasources/home_local_data_source.dart';
>>>>>>> origin/admin-ahmed
import '../widgets/home_action_buttons_row.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_ride_status_cards.dart';
import '../widgets/home_side_drawer.dart';
import '../widgets/home_top_header.dart';
import '../widgets/quick_destinations_section.dart';
import '../widgets/recent_destinations_section.dart';
<<<<<<< HEAD
=======
import 'location_search_page.dart';
>>>>>>> origin/admin-ahmed

/// HomeDashboardPage — Refactored Passenger Home Dashboard for Laffah (لَفّة).
/// Clean Architecture & Modular Widget Composition.
///
/// Rules Enforced:
/// 1. Map Widget (LaffahMapView) is kept 100% UNTOUCHED as Layer 1.
/// 2. Modular Widgets extracted into widgets/ directory.
/// 3. Destinations isolated in FakeHomeRepository for backend readiness.
class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _pickupController =
      TextEditingController(text: 'شارع حدة، أمام مركز الكميم');
  final TextEditingController _dropoffController = TextEditingController();

  int _selectedQuickIndex = -1;

<<<<<<< HEAD
  late final List<Map<String, dynamic>> _quickDestinations;
  late final List<Map<String, dynamic>> _recentDestinations;
=======
  late List<Map<String, dynamic>> _quickDestinations = [];
  late List<Map<String, dynamic>> _recentDestinations = [];
>>>>>>> origin/admin-ahmed

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _quickDestinations = FakeHomeRepository.getQuickDestinations();
    _recentDestinations = FakeHomeRepository.getRecentDestinations();
=======
    _quickDestinations = HomeLocalDataSource.getQuickDestinations();
    _loadRecentDestinations();
  }

  Future<void> _loadRecentDestinations() async {
    final recent = await HomeLocalDataSource.getRecentDestinations();
    if (mounted) {
      setState(() {
        _recentDestinations = recent;
      });
    }
>>>>>>> origin/admin-ahmed
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
=======
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
      });
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

>>>>>>> origin/admin-ahmed
  void _showRideSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<RideBloc>()),
        ],
        child: RideSelectionBottomSheet(
          pickup: _pickupController.text.trim(),
          dropoff: _dropoffController.text.trim().isNotEmpty
              ? _dropoffController.text.trim()
              : 'وجهة مختارة',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        resizeToAvoidBottomInset: false,
        drawer: HomeSideDrawer(isDark: isDark),
        bottomNavigationBar: HomeBottomNavBar(isDark: isDark, currentIndex: 0),
        body: Stack(
          children: [
            // ==========================================
            // LAYER 1: Interactive Simulated Map Component (100% UNTOUCHED)
            // ==========================================
            Positioned.fill(
              child: BlocBuilder<RideBloc, RideState>(
                builder: (context, state) {
                  String status = 'idle';
                  if (state is RideBookingConfirmed) {
                    status = state.status;
                  }
                  return LaffahMapView(
                    isDark: isDark,
                    showDefaultMockData: status != 'idle',
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
            // LAYER 3: Dynamic Bottom Panel (Draggable & Collapsible)
            // ==========================================
            BlocBuilder<RideBloc, RideState>(
              builder: (context, state) {
                if (state is RideBookingConfirmed) {
                  if (state.status == 'found') {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CaptainFoundCard(state: state),
                      ),
                    );
                  } else if (state.status == 'in_progress') {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: RideInProgressCard(state: state),
                      ),
                    );
                  } else if (state.status == 'completed') {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: RideCompletedCard(state: state),
                      ),
                    );
                  }
                } else if (state is ParcelSubmitted) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ParcelSubmittedCard(state: state),
                    ),
                  );
                }

                // Default Draggable & Collapsible Home Panel
                return _buildStitchHomePanel(context, isDark);
              },
            ),

            // ==========================================
            // LAYER 4: Interactive Top Header & Search Bar
            // ==========================================
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: HomeTopHeader(
                  isDark: isDark,
                  dropoffController: _dropoffController,
<<<<<<< HEAD
                  onSearchTap: _showRideSelection,
=======
                  onSearchTap: _openSearchAndSelectRide,
>>>>>>> origin/admin-ahmed
                  onOpenDrawer: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
            ),

            // ==========================================
            // LAYER 5: Full-screen Searching Captain Overlay
            // ==========================================
            BlocBuilder<RideBloc, RideState>(
              builder: (context, state) {
                if (state is RideSearching) {
                  return Positioned.fill(
                    child: SearchingCaptainOverlay(
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
                    ),
                  );
                }
                if (state is RideBookingConfirmed &&
                    state.captainName == 'قيد البحث') {
                  return Positioned.fill(
                    child: SearchingCaptainOverlay(
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
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
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
            16,
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
              padding: EdgeInsets.zero,
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
                  onRequestRideTap: _showRideSelection,
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
}
