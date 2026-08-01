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
import '../../../ride/presentation/bloc/ride_event.dart';
import '../../../ride/presentation/bloc/ride_state.dart';
import '../../../ride/presentation/widgets/passenger/searching_captain_overlay.dart';
import '../../../ride/presentation/widgets/ride_selection_bottom_sheet.dart';

/// HomeDashboardPage - Passenger Home Interface for Laffah (لَفّة)
/// Modernized according to the Stitch Design layout specifications.
/// 
/// Strict Design Rules Applied:
/// 1. Map Widget (LaffahMapView) is kept 100% UNTOUCHED as Layer 1.
/// 2. Uses Laffah's Yemeni Orange primary palette (AppColors.primary500).
/// 3. Top Header: RTL Hamburger menu icon opening side drawer + bold "الرئيسية" title.
/// 4. Search bar "إلى أين؟" for destination input.
/// 5. Two prominent main action buttons: "إرسال طرد" & "طلب مشوار".
/// 6. "وجهات سريعة" section: 4 circular items (المحفوظة, الجامعة, العمل, المنزل) with selection states.
/// 7. "آخر الوجهات" section: vertical list with distances, bold titles, and instant ride trigger.
/// 8. Bottom Navigation Bar: 4 tabs (الرئيسية, رحلاتي, المحفظة, الحساب) with dynamic active Orange styling.
class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _pickupController =
      TextEditingController(text: 'شارع حدة، أمام مركز الكميم');
  final TextEditingController _dropoffController = TextEditingController();

  late AnimationController _radarController;
  late AnimationController _carRouteController;

  double _ratingSelected = 5.0;
  final TextEditingController _ratingCommentController =
      TextEditingController();

  // Currently selected quick destination index (-1 means none selected)
  int _selectedQuickIndex = -1;

  // Active Bottom Navigation index (0: الرئيسية)
  final int _currentBottomNavIndex = 0;

  // Quick destinations list
  final List<Map<String, dynamic>> _quickDestinations = [
    {
      'id': 'saved',
      'title': 'المحفوظة',
      'location': 'المواقع المحفوظة',
      'icon': Icons.bookmark_outline_rounded,
      'route': LaffahRoutes.passengerSavedPlaces,
    },
    {
      'id': 'university',
      'title': 'الجامعة',
      'location': 'جامعة صنعاء - البوابة الرئيسية',
      'icon': Icons.school_outlined,
    },
    {
      'id': 'work',
      'title': 'العمل',
      'location': 'شارع الزبيري - برج الأمل التجاري',
      'icon': Icons.work_outline_rounded,
    },
    {
      'id': 'home',
      'title': 'المنزل',
      'location': 'حي حدة - خلف بريد حدة السكني',
      'icon': Icons.home_outlined,
    },
  ];

  // Recent destinations mock data (Displaying 2 items to optimize map visibility)
  final List<Map<String, dynamic>> _recentDestinations = [
    {
      'title': 'مركز الكميم التجاري',
      'subtitle': 'شارع حدة، مقابل بنك اليمن والخليج',
      'distance': '2.4 كم',
      'icon': Icons.storefront_rounded,
    },
    {
      'title': 'بوابة جامعة صنعاء الغربية',
      'subtitle': 'شارع الدائري الغربي، صنعاء',
      'distance': '4.1 كم',
      'icon': Icons.account_balance_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _carRouteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _radarController.dispose();
    _carRouteController.dispose();
    _ratingCommentController.dispose();
    super.dispose();
  }

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

  void _showParcelForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<RideBloc>()),
        ],
        child: const ParcelDeliveryFormBottomSheet(),
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
        body: Stack(
          children: [
            // ==========================================
            // LAYER 1: Interactive Simulated Map Component
            // (CRITICAL: UNTOUCHED & PRESERVED EXACTLY AS IS)
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
                        padding: const EdgeInsets.only(bottom: 84),
                        child: _buildCaptainFoundCard(context, state),
                      ),
                    );
                  } else if (state.status == 'in_progress') {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 84),
                        child: _buildRideInProgressCard(context, state),
                      ),
                    );
                  } else if (state.status == 'completed') {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 84),
                        child: _buildRideCompletedCard(context, state),
                      ),
                    );
                  }
                } else if (state is ParcelSubmitted) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 84),
                      child: _buildParcelSubmittedCard(context, state),
                    ),
                  );
                }

                // Default Draggable & Collapsible Home Panel
                return _buildStitchHomePanel(context, isDark);
              },
            ),

            // ==========================================
            // LAYER 4: Interactive Top Header & Search Bar
            // Pinned at top to remain accessible and visible above sheet
            // ==========================================
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: _buildTopHeader(context, isDark),
              ),
            ),

            // ==========================================
            // LAYER 4: Full-screen Searching Captain Overlay
            // Rendered above all layers when the Bloc emits RideSearching
            // or RideBookingConfirmed with captainName == 'قيد البحث'.
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

  // ==========================================
  // STITCH DESIGN: TOP HEADER
  // ==========================================
  Widget _buildTopHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Hamburger Menu Button (RTL -> Right side)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceElevatedDark
                      : AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary500.withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: AppColors.primary500,
                    size: 24,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),

              AppSpacing.w12,

              // Title "الرئيسية" in Bold
              Text(
                'الرئيسية',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),

              const Spacer(),

              // Quick Notifications Link Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceElevatedDark
                      : AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.08)
                        : AppColors.gray200,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.gray700,
                    size: 22,
                  ),
                  onPressed: () {
                    context.push(LaffahRoutes.passengerNotifications);
                  },
                ),
              ),
            ],
          ),

          AppSpacing.h12,

          // Search Bar "إلى أين؟"
          GestureDetector(
            onTap: _showRideSelection,
            child: GlassBox(
              borderRadius: AppSpacing.radiusMD,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary500,
                    size: 24,
                  ),
                  AppSpacing.w12,
                  Expanded(
                    child: Text(
                      _dropoffController.text.isNotEmpty
                          ? _dropoffController.text
                          : 'إلى أين؟ اختر وجهتك...',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 14,
                        fontWeight: _dropoffController.text.isNotEmpty
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: _dropoffController.text.isNotEmpty
                            ? (isDark ? AppColors.white : AppColors.gray900)
                            : (isDark ? AppColors.gray500 : AppColors.gray600),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary500,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'الخريطة',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STITCH DESIGN: IDLE HOME PANEL (DRAGGABLE & COLLAPSIBLE)
  // ==========================================
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
            78, // Distance above floating bottom navigation bar
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

                // 2) Main Action Buttons Row (إرسال طرد / طلب مشوار)
                _buildMainActionButtonsRow(context, isDark),

                AppSpacing.h16,

                // 3) Section: "وجهات سريعة"
                _buildQuickDestinationsSection(context, isDark),

                AppSpacing.h16,

                // 4) Section: "آخر الوجهات"
                _buildRecentDestinationsSection(context, isDark),

                // Search Trigger CTA (Preserved as requested)
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
                        shadowColor: AppColors.primary500.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
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

  // ==========================================
  // STITCH DESIGN: 2 MAIN ACTION BUTTONS
  // ==========================================
  Widget _buildMainActionButtonsRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Button 1 (RTL right/start): "طلب مشوار" — Orange, Motorcycle icon
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showRideSelection,
              borderRadius: AppSpacing.radiusMD,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppSpacing.radiusMD,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.motorcycle_rounded,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                    AppSpacing.w10,
                    const Text(
                      'طلب مشوار',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        AppSpacing.w12,

        // Button 2 (RTL left/end): "إرسال طرد" — White/light, Box icon
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(LaffahRoutes.passengerParcelSend),
              borderRadius: AppSpacing.radiusMD,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceElevatedDark
                      : AppColors.white,
                  borderRadius: AppSpacing.radiusMD,
                  border: Border.all(
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.08)
                        : AppColors.gray300,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.white.withValues(alpha: 0.08)
                            : AppColors.gray100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: isDark ? AppColors.white : AppColors.gray900,
                        size: 22,
                      ),
                    ),
                    AppSpacing.w10,
                    Text(
                      'إرسال طرد',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STITCH DESIGN: SECTION "وجهات سريعة"
  // ==========================================
  Widget _buildQuickDestinationsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with single Chevron icon leading to saved places
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'وجهات سريعة',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),
            GestureDetector(
              onTap: () {
                context.push(LaffahRoutes.passengerSavedPlaces);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: AppColors.primary500,
                ),
              ),
            ),
          ],
        ),

        AppSpacing.h12,

        // Horizontal Row of 4 Circular Destination Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_quickDestinations.length, (index) {
            final dest = _quickDestinations[index];
            final isSelected = _selectedQuickIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedQuickIndex = index;
                  _dropoffController.text = dest['location'] as String;
                });

                if (dest.containsKey('route')) {
                  context.push(dest['route'] as String);
                } else {
                  _showRideSelection();
                }
              },
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary500.withValues(alpha: 0.15)
                          : (isDark
                              ? AppColors.surfaceElevatedDark
                              : AppColors.gray100),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary500
                            : (isDark
                                ? AppColors.white.withValues(alpha: 0.08)
                                : AppColors.gray300),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.primary500.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      dest['icon'] as IconData,
                      color: isSelected
                          ? AppColors.primary500
                          : (isDark ? AppColors.gray300 : AppColors.gray700),
                      size: 24,
                    ),
                  ),
                  AppSpacing.h6,
                  Text(
                    dest['title'] as String,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary500
                          : (isDark ? AppColors.gray300 : AppColors.gray800),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  // ==========================================
  // STITCH DESIGN: SECTION "آخر الوجهات"
  // ==========================================
  Widget _buildRecentDestinationsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'آخر الوجهات',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),

        AppSpacing.h10,

        // Vertical List of Recent Destinations (Mock Data)
        Column(
          children: List.generate(_recentDestinations.length, (index) {
            final item = _recentDestinations[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _dropoffController.text = item['title'] as String;
                    });
                    _showRideSelection();
                  },
                  borderRadius: AppSpacing.radiusSM,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceElevatedDark.withValues(alpha: 0.6)
                          : AppColors.gray50,
                      borderRadius: AppSpacing.radiusSM,
                      border: Border.all(
                        color: isDark
                            ? AppColors.white.withValues(alpha: 0.05)
                            : AppColors.gray200,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Right Icon (RTL)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s8),
                          decoration: BoxDecoration(
                            color: AppColors.primary500.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: AppColors.primary500,
                            size: 20,
                          ),
                        ),

                        AppSpacing.w12,

                        // Title and Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.gray900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['subtitle'] as String,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.gray400
                                      : AppColors.gray600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Left Distance Info (RTL -> Left side)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.near_me_rounded,
                              size: 13,
                              color: AppColors.gray500,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              item['distance'] as String,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.gray700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ==========================================
  // STITCH DESIGN: DYNAMIC BOTTOM NAV BAR
  // ==========================================
  Widget _buildBottomNavigationBar(BuildContext context, bool isDark) {
    // 4 Items in Order: الرئيسية, رحلاتي, المحفظة, الحساب
    final List<Map<String, dynamic>> navItems = [
      {
        'title': 'الرئيسية',
        'icon': Icons.home_rounded,
        'route': LaffahRoutes.passengerHome,
      },
      {
        'title': 'رحلاتي',
        'icon': Icons.receipt_long_rounded,
        'route': LaffahRoutes.passengerHistory,
      },
      {
        'title': 'المحفظة',
        'icon': Icons.account_balance_wallet_rounded,
        'route': LaffahRoutes.passengerWallet,
      },
      {
        'title': 'الحساب',
        'icon': Icons.person_rounded,
        'route': LaffahRoutes.passengerProfile,
      },
    ];

    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.white.withValues(alpha: 0.08)
                : AppColors.gray200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final bool isActive = index == _currentBottomNavIndex;
          final Color itemColor = isActive
              ? AppColors.primary500
              : (isDark ? AppColors.gray500 : AppColors.gray600);

          return Expanded(
            child: InkWell(
              onTap: () {
                if (!isActive) {
                  context.go(item['route'] as String);
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: itemColor,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['title'] as String,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11.5,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.w500,
                      color: itemColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ==========================================
  // STITCH DESIGN: SIDE DRAWER
  // ==========================================
  Widget _buildSideDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Drawer Header with User Profile
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              currentAccountPicture: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const CircleAvatar(
                  backgroundColor: AppColors.white,
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary500,
                    size: 36,
                  ),
                ),
              ),
              accountName: const Text(
                'الراكب - لَفّة',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
              accountEmail: const Text(
                '+967 777 000 000',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 13,
                  color: AppColors.white,
                ),
              ),
            ),

            // Drawer Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.home_rounded,
                    title: 'الرئيسية',
                    route: LaffahRoutes.passengerHome,
                    isDark: isDark,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.receipt_long_rounded,
                    title: 'رحلاتي وحجوزاتي',
                    route: LaffahRoutes.passengerHistory,
                    isDark: isDark,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'محفظة لَفّة',
                    route: LaffahRoutes.passengerWallet,
                    isDark: isDark,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.bookmark_rounded,
                    title: 'العناوين المحفوظة',
                    route: LaffahRoutes.passengerSavedPlaces,
                    isDark: isDark,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.local_offer_rounded,
                    title: 'أكواد الخصم والعروض',
                    route: LaffahRoutes.passengerPromoCode,
                    isDark: isDark,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.notifications_rounded,
                    title: 'الإشعارات',
                    route: LaffahRoutes.passengerNotifications,
                    isDark: isDark,
                  ),
                  const Divider(),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.support_agent_rounded,
                    title: 'الدعم الفني والشكاوى',
                    route: LaffahRoutes.passengerSupportTickets,
                    isDark: isDark,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    title: 'الملف الشخصي',
                    route: LaffahRoutes.passengerProfile,
                    isDark: isDark,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.published_with_changes_rounded,
                    title: 'التبديل إلى وضع الكابتن',
                    route: LaffahRoutes.roleSelection,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary500, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        context.go(route);
      },
    );
  }

  // ==========================================
  // VIEW 2: Searching/Finding Captain Card
  // ==========================================
  Widget _buildSearchingCard(BuildContext context, RideSearching state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: GlassBox(
        borderRadius: AppSpacing.radiusLG,
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary500,
                  ),
                ),
                AppSpacing.w16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'جاري البحث عن كابتن لَفّة...',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                      AppSpacing.h4,
                      Text(
                        'نقوم الآن بالتواصل مع كباتن الدراجات النارية والسيارات الأقرب إليك في صنعاء.',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 11.5,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.h16,

            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.04),
                borderRadius: AppSpacing.radiusSM,
                border: Border.all(
                  color: AppColors.primary500.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أجرة اللَفّة المحسوبة:',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 11,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${state.price.toStringAsFixed(0)} ريال يمني',
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'الدفع نقدي',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.h16,

            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  context.read<RideBloc>().add(const CancelRideRequested());
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.radiusSM,
                  ),
                ),
                child: const Text(
                  'إلغاء الطلب والبحث',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 3: Captain Found Card
  // ==========================================
  Widget _buildCaptainFoundCard(
    BuildContext context,
    RideBookingConfirmed state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: GlassBox(
        borderRadius: AppSpacing.radiusLG,
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تم قبول طلب لَفّتك بنجاح!',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: AppSpacing.radiusXS,
                  ),
                  child: const Text(
                    'الكابتن قادم إليك',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.h16,

            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primary500,
                    size: 28,
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.captainName,
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                        ),
                      ),
                      AppSpacing.h4,
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.warning,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${state.rating.toStringAsFixed(1)} • ${state.vehicleModel}',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.gray400
                                  : AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.04)
                        : AppColors.gray100,
                    borderRadius: AppSpacing.radiusSM,
                  ),
                  child: Text(
                    state.vehiclePlate,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.h16,

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primary500,
                          content: Text(
                            'جاري فتح الشات مع الكابتن ${state.captainName}...',
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                    ),
                    label: const Text(
                      'مراسلة الكابتن',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.radiusSM,
                      ),
                    ),
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text(
                            'جاري الاتصال بهاتف الكابتن ${state.captainName}...',
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                    label: const Text(
                      'اتصال مباشر',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.radiusSM,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 4: Ride In Progress Card
  // ==========================================
  Widget _buildRideInProgressCard(
    BuildContext context,
    RideBookingConfirmed state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: GlassBox(
        borderRadius: AppSpacing.radiusLG,
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'رحلتك الحالية مستمرة...',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withValues(alpha: 0.15),
                    borderRadius: AppSpacing.radiusXS,
                  ),
                  child: const Text(
                    'في الطريق للوجهة',
                    style: TextStyle(
                      color: AppColors.primary500,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.h16,

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceElevatedDark.withValues(alpha: 0.5)
                          : AppColors.gray100,
                      borderRadius: AppSpacing.radiusSM,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الوقت المتبقي للوصول',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 10,
                            color: AppColors.primary500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '12 دقيقة',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceElevatedDark.withValues(alpha: 0.5)
                          : AppColors.gray100,
                      borderRadius: AppSpacing.radiusSM,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المسافة المتبقية',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 10,
                            color: AppColors.primary500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '4.5 كم',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.h16,

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.motorcycle_rounded,
                  color: AppColors.primary500,
                  size: 22,
                ),
              ),
              title: Text(
                state.captainName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
              subtitle: Text(
                'تويوتا كورولا • 4.9 ⭐',
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.primary500,
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.phone_in_talk_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 5: Ride Completed Card
  // ==========================================
  Widget _buildRideCompletedCard(
    BuildContext context,
    RideBookingConfirmed state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: GlassBox(
        borderRadius: AppSpacing.radiusLG,
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 48,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'وصلت بحمد الله وتوفيقه!',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.h16,

            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.04),
                borderRadius: AppSpacing.radiusSM,
                border: Border.all(
                  color: AppColors.primary500.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'إجمالي تكلفة لَفّتك النهائية:',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.selectedOption.basePrice.toStringAsFixed(0)} ريال يمني',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.h16,

            Center(
              child: Text(
                'كيف كانت رحلتك مع الكابتن ${state.captainName}؟',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ),
            AppSpacing.h8,

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starVal = index + 1.0;
                return IconButton(
                  icon: Icon(
                    _ratingSelected >= starVal
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.warning,
                    size: 34,
                  ),
                  onPressed: () {
                    setState(() {
                      _ratingSelected = starVal;
                    });
                  },
                );
              }),
            ),
            AppSpacing.h16,

            Container(
              height: 48,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppSpacing.radiusSM,
              ),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'شكرًا لتقييمك! تم إرسال التقييم بنجاح.',
                        textDirection: TextDirection.rtl,
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.read<RideBloc>().add(const CancelRideRequested());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppSpacing.radiusSM,
                  ),
                ),
                child: const Text(
                  'إرسال التقييم وإنهاء الرحلة',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 6: Parcel Submitted Card
  // ==========================================
  Widget _buildParcelSubmittedCard(
    BuildContext context,
    ParcelSubmitted state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: GlassBox(
        borderRadius: AppSpacing.radiusLG,
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: AppColors.primary500,
                    size: 48,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'تم تسجيل طلب الطرد بنجاح!',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.h16,

            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark.withValues(alpha: 0.5)
                    : AppColors.gray50,
                borderRadius: AppSpacing.radiusSM,
                border: Border.all(
                  color: isDark
                      ? AppColors.white.withValues(alpha: 0.05)
                      : AppColors.gray200,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'رقم تتبع الطرد الموحد:',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        state.trackingId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary500,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.h8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'اسم مستلم الشحنة:',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        state.data.receiverName,
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.h16,

            ElevatedButton(
              onPressed: () {
                context.read<RideBloc>().add(const CancelRideRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppSpacing.radiusSM,
                ),
              ),
              child: const Text(
                'العودة للقائمة الرئيسية',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
