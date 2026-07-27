import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_map_view.dart';
import '../../../ride/presentation/bloc/ride_bloc.dart';
import '../../../ride/presentation/bloc/ride_event.dart';
import '../../../ride/presentation/bloc/ride_state.dart';
import '../../../ride/presentation/pages/trip_history_page.dart';
import '../../../passenger/presentation/pages/wallet_page.dart';
import '../../../profile/presentation/pages/user_profile_page.dart';
import '../widgets/passenger_floating_bottom_bar.dart';
import '../../../ride/presentation/widgets/ride_selection_bottom_sheet.dart';
import '../../../parcel/presentation/widgets/parcel_delivery_form_bottom_sheet.dart';

/// HomeDashboardPage - The premium Passenger main map home interface for "Laffah (لفّة)"
/// Adheres strictly to Laffah's design system: Deep Charcoal theme, Yemeni Orange accents,
/// 8-point spatial grid, 48x48dp touch targets, and beautiful Glassmorphism (Blur 28.0).
/// Feature integration includes:
/// - Real-time map background
/// - Live location pin (Sana'a coordinates)
/// - Top glassmorphic header containing passenger profile and interactive notification button
/// - Custom Search Bar trigger with destination search input fields
/// - Distinctive Category Chips [مشوار, طرد, حجز سريع]
/// - Simulated map route overlays and dynamic active trip card states.
class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  int _currentIndex = 0; // 0: Home, 1: History, 2: Wallet, 3: Profile

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: const [
                _HomeMapSubPage(),
                TripHistoryPage(),
                WalletPage(),
                UserProfilePage(),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: PassengerFloatingBottomBar(
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
      ),
    );
  }
}

class _HomeMapSubPage extends StatefulWidget {
  const _HomeMapSubPage();

  @override
  State<_HomeMapSubPage> createState() => _HomeMapSubPageState();
}

class _HomeMapSubPageState extends State<_HomeMapSubPage> with TickerProviderStateMixin {
  final TextEditingController _pickupController = TextEditingController(text: 'شارع حدة، أمام مركز الكميم');
  final TextEditingController _dropoffController = TextEditingController(text: 'بوابة جامعة صنعاء الرئيسية');

  late AnimationController _radarController;
  late AnimationController _carRouteController;
  double _ratingSelected = 5.0;
  final TextEditingController _ratingCommentController = TextEditingController();


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

  // Quick destinations list populated with Sana'a landmarks
  final List<Map<String, dynamic>> _quickDestinations = [
    {
      'title': 'المنزل (بيت العائلة)',
      'desc': 'صنعاء، حي حدة، خلف بريد حدة السكني',
      'icon': Icons.home_rounded,
      'lat': 15.3585,
      'lng': 44.1872
    },
    {
      'title': 'مقر العمل الحالي',
      'desc': 'شارع الزبيري، برج الأمل التجاري',
      'icon': Icons.business_center_rounded,
      'lat': 15.3712,
      'lng': 44.1954
    },
    {
      'title': 'جامعة صنعاء الرئيسية',
      'desc': 'شارع الدائري الغربي، البوابة الغربية',
      'icon': Icons.school_rounded,
      'lat': 15.3782,
      'lng': 44.1804
    },
  ];

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
          dropoff: _dropoffController.text.trim(),
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

    return Stack(
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
              height: 200,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        isDark ? AppColors.backgroundDark.withOpacity(0.9) : AppColors.white.withOpacity(0.9),
                        isDark ? AppColors.backgroundDark.withOpacity(0.4) : AppColors.white.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ==========================================
            // LAYER 3: Interactive Dashboard Controls
            // ==========================================
            SafeArea(
              child: Column(
                children: [
                  // App Bar / Top Actions (Custom Header)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Profile Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary500.withOpacity(0.2), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.person, color: AppColors.primary500, size: 22),
                            onPressed: () {
                              Navigator.pushNamed(context, '/profile');
                            },
                          ),
                        ),
                        // Middle Empty Space
                        const Spacer(),
                        // Notifications / Saved places icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary500.withOpacity(0.1), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.bookmark_rounded, color: AppColors.primary500, size: 22),
                            onPressed: () {
                              Navigator.pushNamed(context, '/saved_places');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),



                  const Spacer(),

                  // ==========================================
                  // LAYER 4: Dynamic Bottom State Cards
                  // ==========================================
                  BlocBuilder<RideBloc, RideState>(
                    builder: (context, state) {
                      if (state is RideIdle) {
                        return _buildIdleInputCard(context, isDark);
                      } else if (state is RideSearching) {
                        return _buildSearchingCard(context, state);
                      } else if (state is RideBookingConfirmed) {
                        if (state.status == 'found') {
                          return _buildCaptainFoundCard(context, state);
                        } else if (state.status == 'in_progress') {
                          return _buildRideInProgressCard(context, state);
                        } else if (state.status == 'completed') {
                          return _buildRideCompletedCard(context, state);
                        }
                      } else if (state is ParcelSubmitted) {
                        return _buildParcelSubmittedCard(context, state);
                      }
                      return _buildIdleInputCard(context, isDark);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
  }

  // ==========================================
  // VIEW 1: Idle Address Selection Card
  // ==========================================
  Widget _buildIdleInputCard(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s20),
      child: GlassBox(
        borderRadius: AppSpacing.radiusLG,
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'أين تريد الذهاب اليوم في لَفّة؟',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),
            AppSpacing.h16,

            // Pickup location input
            _buildAddressInputField(
              controller: _pickupController,
              icon: Icons.my_location_rounded,
              iconColor: AppColors.success,
              hint: 'موقع الانطلاق الحالي...',
              isDark: isDark,
            ),
            AppSpacing.h12,

            // Destination location input
            _buildAddressInputField(
              controller: _dropoffController,
              icon: Icons.location_on_rounded,
              iconColor: AppColors.danger,
              hint: 'اكتب وجهة وصولك...',
              isDark: isDark,
            ),
            AppSpacing.h20,

            // Search Trigger Call-To-Action (CTA)
            Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppSpacing.radiusMD,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary500.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _showRideSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.white,
                  shadowColor: Colors.transparent,
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
                    Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.white),
                  ],
                ),
              ),
            ),
            
            AppSpacing.h12,
            
            // Secondary CTA: Parcel Delivery
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _showParcelForm,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary500,
                  side: BorderSide(color: AppColors.primary500.withValues(alpha: 0.5), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.radiusMD,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2_rounded, size: 18),
                    AppSpacing.w10,
                    const Text(
                      'توصيل طرد',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            AppSpacing.h16,
            const Divider(color: Colors.white10, height: 1),
            AppSpacing.h12,

            // Saved / Favorite Places Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المواقع المفضلة السريعة:',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/saved_places'),
                  child: const Text(
                    'عرض الكل ⚙',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.h10,

            // Quick locations horizontal list
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _quickDestinations.length,
                separatorBuilder: (ctx, index) => AppSpacing.w8,
                itemBuilder: (ctx, index) {
                  final dest = _quickDestinations[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _dropoffController.text = dest['title'];
                      });
                      _showRideSelection();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(dest['icon'] as IconData, size: 15, color: AppColors.primary500),
                          AppSpacing.w6,
                          Text(
                            dest['title'] as String,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.white : AppColors.gray800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressInputField({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String hint,
    required bool isDark,
  }) {
    return Container(
      height: 52, // Optimal touch target
      decoration: BoxDecoration(
        color: isDark ? AppColors.white.withOpacity(0.02) : AppColors.gray50,
        borderRadius: AppSpacing.radiusSM,
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          AppSpacing.w12,
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                  color: isDark ? AppColors.gray600 : AppColors.gray400,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 2: Searching/Finding Captain Card
  // ==========================================
  Widget _buildSearchingCard(BuildContext context, RideSearching state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: GlassBox(
        borderRadius: AppSpacing.radiusLG,
        padding: const EdgeInsets.all(AppSpacing.s24),
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
            AppSpacing.h20,

            // Simulated booking status tracker
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: AppColors.primary500.withOpacity(0.04),
                borderRadius: AppSpacing.radiusSM,
                border: Border.all(color: AppColors.primary500.withOpacity(0.1)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withOpacity(0.12),
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

            // Cancel trigger button
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
  Widget _buildCaptainFoundCard(BuildContext context, RideBookingConfirmed state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s20),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: AppSpacing.radiusXS,
                  ),
                  child: const Text(
                    'الكابتن قادم إليك',
                    style: TextStyle(color: AppColors.success, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            AppSpacing.h16,

            // Captain info section
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: AppColors.primary500, size: 28),
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
                          const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '${state.rating.toStringAsFixed(1)} • ${state.vehicleModel}',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11,
                              color: isDark ? AppColors.gray400 : AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray100,
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

            // Actions row: Chat & Call
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primary500,
                          content: Text('جاري فتح شات المحادثة مع الكابتن ${state.captainName}...', textDirection: TextDirection.rtl),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                    label: const Text('مراسلة الكابتن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusSM),
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
                          content: Text('جاري الاتصال بهاتف الكابتن ${state.captainName}...', textDirection: TextDirection.rtl),
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                    label: const Text('اتصال مباشر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                      shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusSM),
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
  Widget _buildRideInProgressCard(BuildContext context, RideBookingConfirmed state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s20),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withOpacity(0.15),
                    borderRadius: AppSpacing.radiusXS,
                  ),
                  child: const Text(
                    'في الطريق للوجهة',
                    style: TextStyle(color: AppColors.primary500, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            AppSpacing.h16,

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceElevatedDark.withOpacity(0.5) : AppColors.gray100,
                      borderRadius: AppSpacing.radiusSM,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الوقت المتبقي للوصول', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 10, color: AppColors.primary500)),
                        SizedBox(height: 2),
                        Text('12 دقيقة', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceElevatedDark.withOpacity(0.5) : AppColors.gray100,
                      borderRadius: AppSpacing.radiusSM,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المسافة المتبقية', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 10, color: AppColors.primary500)),
                        SizedBox(height: 2),
                        Text('4.5 كم', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.h16,

            // Captain info with Call options
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary500.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.motorcycle_rounded, color: AppColors.primary500, size: 22),
              ),
              title: Text(state.captainName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              subtitle: Text(
                'تويوتا كورولا • 4.9 ⭐',
                style: TextStyle(fontSize: 10.5, color: isDark ? AppColors.gray400 : AppColors.gray600),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary500, size: 20),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.success, size: 20),
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
  // VIEW 5: Ride Completed / Rating Screen
  // ==========================================
  Widget _buildRideCompletedCard(BuildContext context, RideBookingConfirmed state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s20),
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
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
                  SizedBox(height: 6),
                  Text(
                    'وصلت بحمد الله وتوفيقه!',
                    style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 16.5, fontWeight: FontWeight.bold, color: AppColors.success),
                  ),
                ],
              ),
            ),
            AppSpacing.h16,

            // Final receipts
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: AppColors.primary500.withOpacity(0.04),
                borderRadius: AppSpacing.radiusSM,
                border: Border.all(color: AppColors.primary500.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Text(
                    'إجمالي تكلفة لَفّتك النهائية:',
                    style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 11, color: isDark ? AppColors.gray400 : AppColors.gray600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.selectedOption.basePrice.toStringAsFixed(0)} ريال يمني',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment_rounded, color: AppColors.success, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'طريقة السداد: دفع نقداً للكابتن',
                        style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 10.5, color: isDark ? AppColors.gray300 : AppColors.gray800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.h16,

            Center(
              child: Text(
                'كيف كانت رحلتك مع الكابتن ${state.captainName}؟',
                style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12.5, fontWeight: FontWeight.bold, color: isDark ? AppColors.white : AppColors.gray900),
              ),
            ),
            AppSpacing.h8,

            // 5 Star widget rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starVal = index + 1.0;
                return IconButton(
                  icon: Icon(
                    _ratingSelected >= starVal ? Icons.star_rounded : Icons.star_outline_rounded,
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
            AppSpacing.h12,

            TextField(
              controller: _ratingCommentController,
              maxLines: 1,
              style: TextStyle(color: isDark ? AppColors.white : AppColors.gray900, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'اكتب ملاحظاتك كتقييم إضافي للكابتن...',
                hintStyle: TextStyle(color: isDark ? AppColors.gray500 : AppColors.gray400, fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: isDark ? AppColors.surfaceElevatedDark.withOpacity(0.5) : AppColors.gray100,
                border: OutlineInputBorder(borderRadius: AppSpacing.radiusSM, borderSide: BorderSide.none),
              ),
            ),
            AppSpacing.h16,

            // Submit rating
            Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppSpacing.radiusSM,
              ),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('شكرًا لتقييمك! تم إرسال تقييم الكابتن والرحلة بنجاح.', textDirection: TextDirection.rtl),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.read<RideBloc>().add(const CancelRideRequested()); // Reset ride state to idle
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusSM),
                ),
                child: const Text('إرسال التقييم وإنهاء الرحلة', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold, fontSize: 13.5)),
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
  Widget _buildParcelSubmittedCard(BuildContext context, ParcelSubmitted state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s20),
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
                  Icon(Icons.verified_rounded, color: AppColors.primary500, size: 48),
                  SizedBox(height: 6),
                  Text(
                    'تم تسجيل طلب الطرد بنجاح!',
                    style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary500),
                  ),
                ],
              ),
            ),
            AppSpacing.h16,

            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark.withOpacity(0.5) : AppColors.gray50,
                borderRadius: AppSpacing.radiusSM,
                border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('رقم تتبع الطرد الموحد:', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12)),
                      Text(
                        state.trackingId,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary500, fontFamily: 'monospace', fontSize: 13),
                      ),
                    ],
                  ),
                  AppSpacing.h8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('اسم مستلم الشحنة:', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12)),
                      Text(state.data.receiverName, style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold)),
                    ],
                  ),
                  AppSpacing.h8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('تكلفة التوصيل المقدرة:', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12)),
                      Text('${state.price.toStringAsFixed(0)} ريال', style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold, color: AppColors.success)),
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
                shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusSM),
              ),
              child: const Text('العودة للقائمة الرئيسية', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

