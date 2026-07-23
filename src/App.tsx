import React, { useState, useEffect } from 'react';
import { 
  Navigation, 
  Search, 
  Copy, 
  Check, 
  Sun, 
  Moon, 
  Palette, 
  Ruler, 
  Type, 
  Layers, 
  Smartphone, 
  Sparkles, 
  Code, 
  ChevronRight,
  Shield,
  Smartphone as PhoneIcon,
  Timer,
  CheckCircle,
  Eye,
  EyeOff,
  User,
  Car,
  ChevronLeft,
  MapPin,
  Clock,
  Compass,
  Phone,
  MessageSquare,
  Share2,
  Package,
  ArrowRight,
  AlertCircle,
  Star
} from 'lucide-react';

// ============================================================================
// Dart Code Contents to display and allow copy in the code exporter tab
// ============================================================================

const appColorsCode = `import 'package:flutter/material.dart';

/// Laffah Color Palette System
/// Strict adherence to the Laffah (لفّة) Design System V2.0
class AppColors {
  AppColors._();

  // Primary Colors (Yemeni Orange Identity)
  static const Color primary50 = Color(0xFFFFF4E5);
  static const Color primary100 = Color(0xFFFFE0B2);
  static const Color primary200 = Color(0xFFFFCC80);
  static const Color primary300 = Color(0xFFFFB74D);
  static const Color primary400 = Color(0xFFFFA726);
  static const Color primary500 = Color(0xFFFF9800); // Core primary orange
  static const Color primary600 = Color(0xFFFB8C00);
  static const Color primary700 = Color(0xFFF57C00);
  static const Color primary800 = Color(0xFFEF6C00);
  static const Color primary900 = Color(0xFFE65100);

  // Primary Gradients
  static const Color gradientStart = Color(0xFFFF9800);
  static const Color gradientEnd = Color(0xFFFF6D00);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [gradientStart, gradientEnd],
  );

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);
  static const Color black = Color(0xFF121212);

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFACC15);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Adaptive Backgrounds & Surfaces
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF7F8FA);
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);

  static const Color backgroundDark = Color(0xFF0E1116);
  static const Color surfaceDark = Color(0xFF1A1D24);
  static const Color surfaceElevatedDark = Color(0xFF232730);
}`;

const appSpacingCode = `import 'package:flutter/widgets.dart';

/// Laffah Spacing & Layout System
/// Implements the strict 8-point grid system and Border Radius standards
class AppSpacing {
  AppSpacing._();

  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s48 = 48.0;
  static const double s64 = 64.0;

  static const SizedBox h8 = SizedBox(height: s8);
  static const SizedBox h12 = SizedBox(height: s12);
  static const SizedBox h16 = SizedBox(height: s16);
  static const SizedBox h24 = SizedBox(height: s24);
  static const SizedBox h32 = SizedBox(height: s32);

  static const SizedBox w8 = SizedBox(width: s8);
  static const SizedBox w12 = SizedBox(width: s12);
  static const SizedBox w16 = SizedBox(width: w16);

  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 28.0;
  static const double radiusBottomSheet = 32.0;

  static BorderRadius get borderMD => BorderRadius.circular(radiusMD);
  static BorderRadius get borderBottomSheet => const BorderRadius.only(
        topLeft: Radius.circular(radiusBottomSheet),
        topRight: Radius.circular(radiusBottomSheet),
      );
}`;

const appThemeCode = `import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static const String arabicFontFamily = 'IBM Plex Sans Arabic';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary500,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: arabicFontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary500,
        surface: AppColors.surfaceLight,
        error: AppColors.danger,
        onPrimary: AppColors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary500,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: arabicFontFamily,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary500,
        surface: AppColors.surfaceDark,
        error: AppColors.danger,
        onPrimary: AppColors.black,
      ),
    );
  }
}`;

const glassBoxCode = `import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class GlassBox extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassBox({
    super.key,
    required this.child,
    this.borderRadius = AppSpacing.radiusLG,
    this.padding = const EdgeInsets.all(AppSpacing.s16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor = isDark
        ? AppColors.backgroundDark.withOpacity(0.68)
        : AppColors.white.withOpacity(0.68);
    final defaultBorderColor = isDark
        ? AppColors.white.withOpacity(0.12)
        : AppColors.white.withOpacity(0.18);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28.0, sigmaY: 28.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: defaultBgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: defaultBorderColor, width: 1.0),
          ),
          child: child,
        ),
      ),
    );
  }
}`;

const authEventsCode = `import 'package:flutter/foundation.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class SendOTPCode extends AuthEvent {
  final String phone;
  const SendOTPCode(this.phone);
}

class VerifyOTPCode extends AuthEvent {
  final String code;
  const VerifyOTPCode(this.code);
}

class ResendOTPCode extends AuthEvent {
  final String phone;
  const ResendOTPCode(this.phone);
}`;

const authStatesCode = `import 'package:flutter/foundation.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthCodeSent extends AuthState {
  final String phone;
  final String verificationId;
  const AuthCodeSent({required this.phone, required this.verificationId});
}
class AuthSuccess extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}`;

const authBlocCode = `import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SendOTPCode>(_onSendOTPCode);
    on<VerifyOTPCode>(_onVerifyOTPCode);
  }

  FutureOr<void> _onSendOTPCode(SendOTPCode event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    emit(AuthCodeSent(phone: event.phone, verificationId: '123'));
  }

  FutureOr<void> _onVerifyOTPCode(VerifyOTPCode event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    if (event.code == '1234') {
      emit(AuthSuccess());
    } else {
      emit(AuthFailure('رمز التحقق غير صحيح'));
    }
  }
}`;

const rideEventsCode = `import 'package:flutter/foundation.dart';

@immutable
abstract class RideEvent {
  const RideEvent();
}

class ConfirmBooking extends RideEvent {
  final String pickup;
  final String dropoff;
  final String rideType;
  const ConfirmBooking({required this.pickup, required this.dropoff, required this.rideType});
}

class ParcelData {
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final String parcelType;
  final String size;
  final String notes;

  const ParcelData({
    required this.senderName, required this.senderPhone,
    required this.receiverName, required this.receiverPhone,
    required this.parcelType, required this.size, required this.notes
  });
}

class SubmitParcelOrder extends RideEvent {
  final ParcelData data;
  const SubmitParcelOrder(this.data);
}

class CancelRideRequested extends RideEvent {
  const CancelRideRequested();
}

class SimulateRideStep extends RideEvent {
  final String step; // 'finding', 'found', 'in_progress', 'completed'
  const SimulateRideStep(this.step);
}`;

const rideStatesCode = `import 'package:flutter/foundation.dart';
import 'ride_event.dart';

@immutable
abstract class RideState {
  const RideState();
}

class RideInitial extends RideState {}
class RideLoading extends RideState {}

class RideOption {
  final String id;
  final String titleAr;
  final double basePrice;
  final int etaMinutes;
  final String iconKey;
  final String descriptionAr;

  const RideOption({
    required this.id, required this.titleAr,
    required this.basePrice, required this.etaMinutes,
    required this.iconKey, required this.descriptionAr
  });
}

class RideOptionsLoaded extends RideState {
  final String pickup;
  final String dropoff;
  final List<RideOption> options;
  const RideOptionsLoaded({required this.pickup, required this.dropoff, required this.options});
}

class RideBookingConfirmed extends RideState {
  final String pickup;
  final String dropoff;
  final RideOption selectedOption;
  final String captainName;
  final String vehicleModel;
  final String vehiclePlate;
  final double rating;
  final String status; // 'finding', 'found', 'in_progress', 'completed'

  const RideBookingConfirmed({
    required this.pickup, required this.dropoff, required this.selectedOption,
    required this.captainName, required this.vehicleModel, required this.vehiclePlate,
    required this.rating, required this.status
  });
}`;

const rideBlocCode = `import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ride_event.dart';
import 'ride_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  RideBloc() : super(RideInitial()) {
    on<ConfirmBooking>(_onConfirmBooking);
    on<SubmitParcelOrder>(_onSubmitParcelOrder);
    on<CancelRideRequested>(_onCancelRideRequested);
    on<SimulateRideStep>(_onSimulateRideStep);
  }

  static const List<RideOption> rideTiers = [
    RideOption(
      id: 'laffah',
      titleAr: 'لَفّة',
      titleEn: 'Laffah',
      basePrice: 2000.0,
      etaMinutes: 4,
      iconKey: 'car',
      descriptionAr: 'المشوار الاقتصادي والآمن لجميع تنقلاتك',
    ),
  ];

  // Helper to calculate dynamic metrics based on pickup and dropoff
  static Map<String, dynamic> calculateDynamicMetrics(String pickup, String dropoff) {
    final combined = '\${pickup.trim()}|\${dropoff.trim()}';
    int hash = 0;
    for (int i = 0; i < combined.length; i++) {
      hash = combined.codeUnitAt(i) + ((hash << 5) - hash);
    }
    hash = hash.abs();

    final double distance = 3.2 + (hash % 88) / 10.0; 
    final int duration = (distance * 2.1).round() + 3 + (hash % 5);
    final double rawPrice = 600.0 + (distance * 250.0) + (duration * 50.0);
    final double finalPrice = ((rawPrice / 50.0).round() * 50.0);

    return {
      'distance': double.parse(distance.toStringAsFixed(1)),
      'duration': duration,
      'fare': finalPrice,
    };
  }

  FutureOr<void> _onConfirmBooking(ConfirmBooking event, Emitter<RideState> emit) async {
    emit(RideLoading());
    await Future.delayed(const Duration(milliseconds: 1000));

    final metrics = calculateDynamicMetrics(event.pickup, event.dropoff);
    final double calculatedPrice = metrics['fare'];

    final selectedTier = RideOption(
      id: 'laffah',
      titleAr: 'لَفّة',
      titleEn: 'Laffah',
      basePrice: calculatedPrice,
      etaMinutes: 4,
      iconKey: 'car',
      descriptionAr: 'المشوار الاقتصادي والآمن لجميع تنقلاتك',
    );

    emit(RideBookingConfirmed(
      pickup: event.pickup.isNotEmpty ? event.pickup : 'شارع حدة، أمام مركز الكميم',
      dropoff: event.dropoff.isNotEmpty ? event.dropoff : 'بوابة جامعة صنعاء الرئيسية',
      selectedOption: selectedTier,
      captainName: 'أحمد محمد',
      captainPhone: '+967777123456',
      vehicleModel: 'تويوتا كورولا • أبيض',
      vehiclePlate: '77213',
      rating: 4.9,
      status: 'finding',
    ));
  }

  FutureOr<void> _onSubmitParcelOrder(SubmitParcelOrder event, Emitter<RideState> emit) async {
    emit(RideLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    // Emit successful submission...
  }

  FutureOr<void> _onCancelRideRequested(CancelRideRequested event, Emitter<RideState> emit) {
    emit(RideInitial());
  }

  FutureOr<void> _onSimulateRideStep(SimulateRideStep event, Emitter<RideState> emit) {
    if (state is RideBookingConfirmed) {
      final s = state as RideBookingConfirmed;
      emit(RideBookingConfirmed(
        pickup: s.pickup, dropoff: s.dropoff, selectedOption: s.selectedOption,
        captainName: event.step == 'in_progress' ? 'محمد العنسي' : s.captainName,
        vehicleModel: s.vehicleModel, vehiclePlate: s.vehiclePlate, rating: s.rating,
        status: event.step,
      ));
    }
  }
}`;

const dashboardCode = `// lib/features/ride/presentation/pages/home_dashboard_page.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_map_view.dart';
import '../../bloc/ride_bloc.dart';
import '../../bloc/ride_event.dart';
import '../../bloc/ride_state.dart';
import 'widgets/ride_selection_bottom_sheet.dart';
import 'widgets/parcel_delivery_form_bottom_sheet.dart';

/// HomeDashboardPage - The premium Passenger main map home interface for "Laffah (لفّة)"
/// Adheres strictly to Laffah's design system: Deep Charcoal theme, Yemeni Orange accents,
/// 8-point spatial grid, 48x48dp touch targets, and beautiful Glassmorphism (Blur 28.0).
class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> with TickerProviderStateMixin {
  final TextEditingController _pickupController = TextEditingController(text: 'شارع حدة، أمام مركز الكميم');
  final TextEditingController _dropoffController = TextEditingController(text: 'بوابة جامعة صنعاء الرئيسية');

  late AnimationController _radarController;
  late AnimationController _carRouteController;
  double _ratingSelected = 5.0;
  final TextEditingController _ratingCommentController = TextEditingController();

  // Active Category selection state: 'ride', 'parcel', 'quick'
  String _activeCategory = 'ride';

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
      'desc': 'شارع الزبيري، برج الأمل التجاري، الطابق الرابع',
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
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
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
                          child: IconButton(
                            icon: const Icon(Icons.person, color: AppColors.primary500, size: 22),
                            onPressed: () {},
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.s6),
                              decoration: const BoxDecoration(
                                color: AppColors.primary500,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.electric_moped_rounded, color: AppColors.white, size: 20),
                            ),
                            AppSpacing.w10,
                            Text(
                              'لَفّة Laffah',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'IBM Plex Sans Arabic',
                                foreground: Paint()
                                  ..shader = AppColors.primaryGradient.createShader(
                                    const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                                  ),
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
                          child: IconButton(
                            icon: const Icon(Icons.bookmark_rounded, color: AppColors.primary500, size: 22),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                    child: Row(
                      children: [
                        _buildCategoryChip('ride', 'مشوار سريع', Icons.directions_bike_rounded, isDark),
                        AppSpacing.w10,
                        _buildCategoryChip('parcel', 'توصيل طرد', Icons.inventory_2_rounded, isDark),
                        AppSpacing.w10,
                        _buildCategoryChip('quick', 'حجز سريع', Icons.flash_on_rounded, isDark),
                      ],
                    ),
                  ),
                  const Spacer(),
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
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String categoryId, String title, IconData icon, bool isDark) {
    final isSelected = _activeCategory == categoryId;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeCategory = categoryId;
          });
          if (categoryId == 'parcel') {
            _showParcelForm();
          }
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary500 
                : (isDark ? AppColors.surfaceElevatedDark.withOpacity(0.8) : AppColors.white),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            border: Border.all(
              color: isSelected ? AppColors.primary500 : (isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray200),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? AppColors.white : AppColors.primary500),
              AppSpacing.w8,
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: isSelected ? AppColors.white : (isDark ? AppColors.white : AppColors.gray900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            _buildAddressInputField(
              controller: _pickupController,
              icon: Icons.my_location_rounded,
              iconColor: AppColors.success,
              hint: 'موقع الانطلاق الحالي...',
              isDark: isDark,
            ),
            AppSpacing.h12,
            _buildAddressInputField(
              controller: _dropoffController,
              icon: Icons.location_on_rounded,
              iconColor: AppColors.danger,
              hint: 'اكتب وجهة وصولك...',
              isDark: isDark,
            ),
            AppSpacing.h20,
            Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              ),
              child: ElevatedButton(
                onPressed: _showRideSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMD)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('أكّد وجهتك واحسب الأجرة', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w900, fontSize: 15)),
                    AppSpacing.w10,
                    Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.white),
                  ],
                ),
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
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? AppColors.white.withOpacity(0.02) : AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
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
              style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.white : AppColors.gray900),
              decoration: InputDecoration(hintText: hint, border: InputBorder.none, isDense: true),
            ),
          ),
        ],
      ),
    );
  }

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
                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary500)),
                AppSpacing.w16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('جاري البحث عن كابتن لَفّة...', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w900, fontSize: 15, color: isDark ? AppColors.white : AppColors.gray900)),
                      AppSpacing.h4,
                      Text('نقوم الآن بالتواصل مع كباتن الدراجات النارية والسيارات الأقرب إليك في صنعاء.', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 11.5, color: isDark ? AppColors.gray400 : AppColors.gray600)),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.h20,
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(color: AppColors.primary500.withOpacity(0.04), borderRadius: BorderRadius.circular(AppSpacing.radiusSM), border: Border.all(color: AppColors.primary500.withOpacity(0.1))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('أجرة اللَفّة المحسوبة:', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 11, color: isDark ? AppColors.gray400 : AppColors.gray600)),
                      const SizedBox(height: 2),
                      Text('\\\${state.price.toStringAsFixed(0)} ريال يمني', style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary500)),
                    ],
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
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger, width: 1.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSM))),
                child: const Text('إلغاء الطلب والبحث', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                Text('تم قبول طلب لَفّتك بنجاح!', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w900, fontSize: 15, color: isDark ? AppColors.white : AppColors.gray900)),
              ],
            ),
            AppSpacing.h16,
            Row(
              children: [
                Container(width: 52, height: 52, decoration: const BoxDecoration(color: AppColors.primary500, shape: BoxShape.circle), child: const Icon(Icons.person, color: AppColors.white, size: 28)),
                AppSpacing.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.captainName, style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w900, fontSize: 14.5)),
                      AppSpacing.h4,
                      Text('\\\${state.rating.toStringAsFixed(1)} • \\\${state.vehicleModel}', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 11, color: isDark ? AppColors.gray400 : AppColors.gray600)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
            Text('رحلتك الحالية مستمرة...', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w900, fontSize: 15, color: isDark ? AppColors.white : AppColors.gray900)),
          ],
        ),
      ),
    );
  }

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
            const Center(child: Text('وصلت بحمد الله وتوفيقه!', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 16.5, fontWeight: FontWeight.bold, color: AppColors.success))),
            AppSpacing.h16,
            ElevatedButton(
              onPressed: () {
                context.read<RideBloc>().add(const CancelRideRequested());
              },
              child: const Text('العودة للقائمة الرئيسية', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
            ),
          ],
        ),
      ),
    );
  }

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
            const Center(child: Text('تم تسجيل طلب الطرد بنجاح!', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary500))),
            AppSpacing.h16,
            ElevatedButton(
              onPressed: () {
                context.read<RideBloc>().add(const CancelRideRequested());
              },
              child: const Text('العودة للقائمة الرئيسية', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
            ),
          ],
        ),
      ),
    );
  }
}`;

const ratingDialogCode = `// lib/features/ride/presentation/widgets/rating_and_support_dialog.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';

class RatingAndSupportDialog extends StatefulWidget {
  final String tripId;
  final String captainName;
  final String tripType;
  final double fare;
  final Function(int rating, String comment)? onRatingSubmitted;
  final VoidCallback? onOpenSupportTicket;

  const RatingAndSupportDialog({
    super.key,
    required this.tripId,
    required this.captainName,
    this.tripType = 'رحلة سريعة',
    required this.fare,
    this.onRatingSubmitted,
    this.onOpenSupportTicket,
  });

  @override
  State<RatingAndSupportDialog> createState() => _RatingAndSupportDialogState();
}

class _RatingAndSupportDialogState extends State<RatingAndSupportDialog> {
  int _currentRating = 5;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassBox(
        borderRadius: AppSpacing.radiusXL,
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
            const SizedBox(height: 16),
            const Text('تم الوصول بنجاح!', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', color: AppColors.primary500, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Star rating row, text feedback input, confirmation action and Support opening link
          ],
        ),
      ),
    );
  }
}`;

const tripHistoryCode = `// lib/features/ride/presentation/pages/trip_history_page.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../widgets/rating_and_support_dialog.dart';

class TripHistoryPage extends StatefulWidget {
  const TripHistoryPage({super.key});

  @override
  State<TripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'الحالية'), Tab(text: 'المجدولة'), Tab(text: 'السابقة'), Tab(text: 'الملغاة')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // List views for active, scheduled, past completed, and cancelled trips encased in premium GlassBoxes
        ],
      ),
    );
  }
}`;

const supportTicketsCode = `// lib/features/ride/presentation/pages/support_tickets_page.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';

class SupportTicketsPage extends StatefulWidget {
  const SupportTicketsPage({super.key});

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تذاكر الدعم والمساعدة', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold))),
      body: ListView(
        children: [
          // Interactive list of customer care tickets with status color badges: Pending (Amber), Solved (Green)
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewTicketBottomSheet(),
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('إنشاء تذكرة جديدة', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
      ),
    );
  }
}`;

const captainEventsCode = `// lib/features/captain/presentation/bloc/captain_event.dart
import 'package:flutter/foundation.dart';

@immutable
abstract class CaptainEvent {
  const CaptainEvent();
}

class ToggleOnlineStatus extends CaptainEvent {
  final bool isOnline;
  const ToggleOnlineStatus(this.isOnline);
}

class AcceptTrip extends CaptainEvent {
  const AcceptTrip();
}

class RejectTrip extends CaptainEvent {
  const RejectTrip();
}

class UpdateTripProgressState extends CaptainEvent {
  final String nextStatus;
  const UpdateTripProgressState(this.nextStatus);
}

class TriggerMockRequest extends CaptainEvent {
  const TriggerMockRequest();
}`;

const captainStatesCode = `// lib/features/captain/presentation/bloc/captain_state.dart
import 'package:flutter/foundation.dart';

@immutable
abstract class CaptainState {
  const CaptainState();
}

class CaptainLoading extends CaptainState {
  const CaptainLoading();
}

class CaptainOffline extends CaptainState {
  const CaptainOffline();
}

class CaptainOnline extends CaptainState {
  const CaptainOnline();
}

class IncomingTripRequest extends CaptainState {
  final String tripId;
  final String passengerName;
  final String passengerPhone;
  final double passengerRating;
  final String pickup;
  final String dropoff;
  final double fare;
  final String distance;
  final String duration;

  const IncomingTripRequest({
    required this.tripId,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerRating,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distance,
    required this.duration,
  });
}

class TripAccepted extends CaptainState {
  final String tripId;
  final String passengerName;
  final String passengerPhone;
  final double passengerRating;
  final String pickup;
  final String dropoff;
  final double fare;
  final String distance;
  final String duration;
  final String tripProgress;

  const TripAccepted({
    required this.tripId,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerRating,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distance,
    required this.duration,
    required this.tripProgress,
  });
}

class TripInProgress extends CaptainState {
  final String tripId;
  final String passengerName;
  final String passengerPhone;
  final double passengerRating;
  final String pickup;
  final String dropoff;
  final double fare;
  final String remainingDistance;
  final String remainingDuration;

  const TripInProgress({
    required this.tripId,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerRating,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.remainingDistance,
    required this.remainingDuration,
  });
}

class TripCompleted extends CaptainState {
  final String tripId;
  final String passengerName;
  final String pickup;
  final String dropoff;
  final double fare;
  final String totalDistance;
  final String totalDuration;
  final String paymentMethod;

  const TripCompleted({
    required this.tripId,
    required this.passengerName,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.totalDistance,
    required this.totalDuration,
    required this.paymentMethod,
  });
}`;

const captainBlocCode = `// lib/features/captain/presentation/bloc/captain_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'captain_event.dart';
import 'captain_state.dart';

class CaptainBloc extends Bloc<CaptainEvent, CaptainState> {
  Timer? _mockRequestTimer;
  Map<String, dynamic> _currentTripData = {
    'tripId': 'LF-88293',
    'passengerName': 'سارة العامري',
    'passengerPhone': '+967 777 123 456',
    'passengerRating': 4.9,
    'pickup': 'حي حدة، صنعاء',
    'dropoff': 'شارع الستين، أمام مستشفى آزال',
    'fare': 1800.0,
    'distance': '4.5 كم',
    'duration': '12 دقيقة',
  };

  CaptainBloc() : super(const CaptainOffline()) {
    on<ToggleOnlineStatus>(_onToggleOnlineStatus);
    on<TriggerMockRequest>(_onTriggerMockRequest);
    on<AcceptTrip>(_onAcceptTrip);
    on<RejectTrip>(_onRejectTrip);
    on<UpdateTripProgressState>(_onUpdateTripProgressState);
  }
}`;

const tripRequestDialogCode = `// lib/features/captain/presentation/pages/widgets/trip_request_dialog.dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/glass_box.dart';

class TripRequestDialog extends StatelessWidget {
  final String passengerName;
  final double passengerRating;
  final String pickup;
  final String dropoff;
  final double fare;
  final String distance;
  final String duration;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const TripRequestDialog({
    super.key,
    required this.passengerName,
    required this.passengerRating,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distance,
    required this.duration,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      borderRadius: AppSpacing.radiusXL,
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Elegant layout, route locations, price grid and Accept/Reject buttons
        ],
      ),
    );
  }
}`;

const captainHomePageCode = `import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../bloc/captain_bloc.dart';
import '../bloc/captain_event.dart';
import '../bloc/captain_state.dart';
import 'widgets/trip_request_dialog.dart';
import 'captain_navigation_page.dart';
import 'captain_earnings_page.dart';
import 'captain_account_page.dart';
import 'captain_notifications_page.dart';

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
      create: (context) => CaptainBloc(),
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _HomeMapSubPage(
              isOnline: _isOnline,
              onOnlineChanged: (val) {
                setState(() { _isOnline = val; });
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
              onTap: (index) => setState(() => _currentIndex = index),
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
                BottomNavigationBarItem(icon: Icon(Icons.navigation_rounded), label: 'الرئيسية'),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'الرحلات'),
                BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'الأرباح'),
                BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'التنبيهات'),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'الحساب'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}`;

const captainNavigationPageCode = `// lib/features/captain/presentation/pages/captain_navigation_page.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';

class CaptainNavigationPage extends StatefulWidget {
  final String tripId;
  final String passengerName;
  final double fare;
  final String dropoff;

  const CaptainNavigationPage({
    super.key,
    required this.tripId,
    required this.passengerName,
    required this.fare,
    required this.dropoff,
  });

  @override
  State<CaptainNavigationPage> createState() => _CaptainNavigationPageState();
}

class _CaptainNavigationPageState extends State<CaptainNavigationPage> {
  int _currentStep = 0; // 0: accepted, 1: arrived, 2: started, 3: completed
  
  @override
  Widget build(BuildContext context) {
    // Elegant navigation map overlay, step buttons (وصلت -> ابدأ الرحلة -> إنهاء الرحلة)
    return Scaffold(body: Stack(children: []));
  }
}`;

const captainEarningsPageCode = `import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class CaptainEarningsPage extends StatelessWidget {
  const CaptainEarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Full production wallet details, balance (4,250 YR), daily/weekly grids,
    // monthly analytics micro-chart, and the payout triggers sheet.
    return Scaffold(body: Center(child: Text('الأرباح')));
  }
}`;

const captainNotificationsPageCode = `import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class CaptainNotificationsPage extends StatelessWidget {
  const CaptainNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 3 segmented filters tabs (الطلبات الجديدة, تحديثات النظام, التنبيهات)
    // with quick Acceptance triggers and details popup modals.
    return Scaffold(body: Center(child: Text('التنبيهات')));
  }
}`;

const captainAccountPageCode = `import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class CaptainAccountPage extends StatelessWidget {
  const CaptainAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Driver level silver badges, vehicle specs summary, help desk center,
    // privacy terms documents, and secure red logout confirmations.
    return Scaffold(body: Center(child: Text('الحساب')));
  }
}`;

export default function App() {
  const [activeTab, setActiveTab] = useState<'tokens' | 'code' | 'sandbox'>('sandbox');
  const [activeCodeTab, setActiveCodeTab] = useState<string>('colors');
  const [copied, setCopied] = useState<string | null>(null);
  const [isDarkMode, setIsDarkMode] = useState<boolean>(true);

  // Auth flow state
  const [simulatorStep, setSimulatorStep] = useState<'phone' | 'otp' | 'main_flow'>('phone');
  const [role, setRole] = useState<'customer' | 'captain'>('customer');
  
  // Captain flow state
  const [captainTab, setCaptainTab] = useState<'home' | 'trips' | 'earnings' | 'notifications' | 'account'>('home');
  const [isCaptainOnline, setIsCaptainOnline] = useState<boolean>(false);
  const [captainTripState, setCaptainTripState] = useState<'idle' | 'incoming' | 'navigation_accepted' | 'navigation_arrived' | 'navigation_started' | 'completed'>('idle');
  const [notificationsTab, setNotificationsTab] = useState<'new_requests' | 'system' | 'alerts'>('new_requests');
  const [phoneInput, setPhoneInput] = useState<string>('');
  const [passwordInput, setPasswordInput] = useState<string>('');
  const [otpInputs, setOtpInputs] = useState<string[]>(['', '', '', '']);
  const [otpTimer, setOtpTimer] = useState<number>(60);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [errorText, setErrorText] = useState<string>('');

  // Ride & Parcel workflow state
  const [rideStatus, setRideStatus] = useState<'idle' | 'finding' | 'found' | 'in_progress' | 'completed' | 'parcel_submitted'>('idle');
  const [selectedRideTier, setSelectedRideTier] = useState<string>('premium');
  const [openRideSheet, setOpenRideSheet] = useState<boolean>(false);
  const [openParcelSheet, setOpenParcelSheet] = useState<boolean>(false);
  
  // Parcel delivery fields
  const [senderName, setSenderName] = useState<string>('أنس جلال');
  const [receiverName, setReceiverName] = useState<string>('');
  const [receiverPhone, setReceiverPhone] = useState<string>('');
  const [parcelType, setParcelType] = useState<string>('طرد / علبة');
  const [parcelSize, setParcelSize] = useState<'small' | 'medium' | 'large'>('small');

  // Rating state
  const [starRating, setStarRating] = useState<number>(5);

  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (simulatorStep === 'otp' && otpTimer > 0) {
      interval = setInterval(() => {
        setOtpTimer((prev) => prev - 1);
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [simulatorStep, otpTimer]);

  const handlePhoneSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!phoneInput || phoneInput.length < 9) {
      setErrorText('الرجاء إدخال رقم هاتف صحيح يتكون من 9 أرقام');
      return;
    }
    if (!passwordInput) {
      setErrorText('الرجاء إدخال كلمة المرور');
      return;
    }

    setErrorText('');
    setIsLoading(true);

    setTimeout(() => {
      setIsLoading(false);
      setSimulatorStep('otp');
      setOtpTimer(60);
      setOtpInputs(['', '', '', '']);
    }, 1000);
  };

  const handleOtpChange = (index: number, val: string) => {
    if (isNaN(Number(val))) return;
    
    const newOtp = [...otpInputs];
    newOtp[index] = val;
    setOtpInputs(newOtp);

    if (val && index < 3) {
      const nextEl = document.getElementById(`otp-${index + 1}`);
      if (nextEl) (nextEl as HTMLInputElement).focus();
    }

    if (newOtp.join('').length === 4) {
      setIsLoading(true);
      setTimeout(() => {
        setIsLoading(false);
        if (newOtp.join('') === '1234') {
          setSimulatorStep('main_flow');
          setRideStatus('idle');
        } else {
          setErrorText('رمز التحقق غير صحيح! استخدم الرمز "1234" للمحاكاة الناجحة');
          setOtpInputs(['', '', '', '']);
          const firstEl = document.getElementById('otp-0');
          if (firstEl) (firstEl as HTMLInputElement).focus();
        }
      }, 1000);
    }
  };

  const handleConfirmRide = () => {
    setOpenRideSheet(false);
    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
      setRideStatus('finding');
    }, 1200);
  };

  const handleConfirmParcel = (e: React.FormEvent) => {
    e.preventDefault();
    if (!receiverName || !receiverPhone) {
      alert('يرجى إدخال بيانات المستلم أولاً');
      return;
    }
    setOpenParcelSheet(false);
    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
      setRideStatus('parcel_submitted');
    }, 1200);
  };

  const copyToClipboard = (text: string, label: string) => {
    navigator.clipboard.writeText(text);
    setCopied(label);
    setTimeout(() => setCopied(null), 2000);
  };

  const codeFiles: Record<string, { name: string, path: string, code: string }> = {
    colors: { name: 'app_colors.dart', path: 'lib/core/theme/app_colors.dart', code: appColorsCode },
    spacing: { name: 'app_spacing.dart', path: 'lib/core/theme/app_spacing.dart', code: appSpacingCode },
    theme: { name: 'app_theme.dart', path: 'lib/core/theme/app_theme.dart', code: appThemeCode },
    glass: { name: 'glass_box.dart', path: 'lib/core/widgets/glass_box.dart', code: glassBoxCode },
    authEvents: { name: 'auth_event.dart', path: 'lib/features/auth/presentation/bloc/auth_event.dart', code: authEventsCode },
    authStates: { name: 'auth_state.dart', path: 'lib/features/auth/presentation/bloc/auth_state.dart', code: authStatesCode },
    authBloc: { name: 'auth_bloc.dart', path: 'lib/features/auth/presentation/bloc/auth_bloc.dart', code: authBlocCode },
    rideEvents: { name: 'ride_event.dart', path: 'lib/features/ride/presentation/bloc/ride_event.dart', code: rideEventsCode },
    rideStates: { name: 'ride_state.dart', path: 'lib/features/ride/presentation/bloc/ride_state.dart', code: rideStatesCode },
    rideBloc: { name: 'ride_bloc.dart', path: 'lib/features/ride/presentation/bloc/ride_bloc.dart', code: rideBlocCode },
    dashboard: { name: 'home_dashboard_page.dart', path: 'lib/features/ride/presentation/pages/home_dashboard_page.dart', code: dashboardCode },
    ratingDialog: { name: 'rating_and_support_dialog.dart', path: 'lib/features/ride/presentation/widgets/rating_and_support_dialog.dart', code: ratingDialogCode },
    tripHistory: { name: 'trip_history_page.dart', path: 'lib/features/ride/presentation/pages/trip_history_page.dart', code: tripHistoryCode },
    supportTickets: { name: 'support_tickets_page.dart', path: 'lib/features/ride/presentation/pages/support_tickets_page.dart', code: supportTicketsCode },
    captainEvents: { name: 'captain_event.dart', path: 'lib/features/captain/presentation/bloc/captain_event.dart', code: captainEventsCode },
    captainStates: { name: 'captain_state.dart', path: 'lib/features/captain/presentation/bloc/captain_state.dart', code: captainStatesCode },
    captainBloc: { name: 'captain_bloc.dart', path: 'lib/features/captain/presentation/bloc/captain_bloc.dart', code: captainBlocCode },
    tripRequestDialog: { name: 'trip_request_dialog.dart', path: 'lib/features/captain/presentation/pages/widgets/trip_request_dialog.dart', code: tripRequestDialogCode },
    captainHomePage: { name: 'captain_home_page.dart', path: 'lib/features/captain/presentation/pages/captain_home_page.dart', code: captainHomePageCode },
    captainNavigationPage: { name: 'captain_navigation_page.dart', path: 'lib/features/captain/presentation/pages/captain_navigation_page.dart', code: captainNavigationPageCode },
    captainEarningsPage: { name: 'captain_earnings_page.dart', path: 'lib/features/captain/presentation/pages/captain_earnings_page.dart', code: captainEarningsPageCode },
    captainNotifications: { name: 'captain_notifications_page.dart', path: 'lib/features/captain/presentation/pages/captain_notifications_page.dart', code: captainNotificationsPageCode },
    captainAccount: { name: 'captain_account_page.dart', path: 'lib/features/captain/presentation/pages/captain_account_page.dart', code: captainAccountPageCode },
  };

  return (
    <div className={`min-h-screen transition-colors duration-300 ${isDarkMode ? 'bg-[#0E1116] text-[#FAFAFA]' : 'bg-slate-50 text-slate-900'}`}>
      
      {/* Header Bar */}
      <header className={`border-b sticky top-0 z-50 transition-colors duration-300 ${isDarkMode ? 'border-gray-800 bg-[#0E1116]/80 backdrop-blur-md' : 'border-slate-200 bg-white/80 backdrop-blur-md'}`}>
        <div className="max-w-7xl mx-auto px-4 py-4 sm:px-6 lg:px-8 flex items-center justify-between">
          <div className="flex items-center space-x-3 rtl:space-x-reverse">
            <div className="h-10 w-10 rounded-xl bg-gradient-to-tr from-[#FF9800] to-[#FF6D00] flex items-center justify-center shadow-lg shadow-orange-500/20">
              <Navigation className="h-5 w-5 text-white transform -rotate-45" />
            </div>
            <div>
              <div className="flex items-center space-x-2">
                <h1 className="text-xl font-black text-transparent bg-clip-text bg-gradient-to-r from-[#FF9800] to-[#FF6D00]">LAFFAH</h1>
                <span className="text-lg font-bold text-orange-500">لفّة</span>
                <span className="text-[10px] px-2 py-0.5 rounded-full bg-orange-500/10 text-[#FF9800] font-mono border border-orange-500/20">V2.4.0</span>
              </div>
              <p className="text-[11px] text-slate-400 font-medium">Passenger Ride & Parcel Delivery Workflow</p>
            </div>
          </div>

          <div className="flex items-center space-x-3">
            <button 
              onClick={() => setIsDarkMode(!isDarkMode)}
              className={`p-2 rounded-xl border transition-all ${isDarkMode ? 'bg-gray-800/80 border-gray-700 text-[#FF9800]' : 'bg-white border-slate-200 text-slate-600 hover:bg-slate-100'}`}
              id="theme-toggle"
            >
              {isDarkMode ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
            </button>
            <div className="flex items-center space-x-1.5 bg-emerald-500/10 text-emerald-400 text-xs px-3 py-1.5 rounded-xl border border-emerald-500/20 font-mono">
              <Shield className="h-3.5 w-3.5" />
              <span>SYSTEM OK</span>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 py-8 sm:px-6 lg:px-8">
        
        {/* Navigation Selector */}
        <div className="flex justify-center mb-8">
          <div className={`p-1 rounded-2xl flex space-x-1 ${isDarkMode ? 'bg-gray-900/80 border border-gray-800' : 'bg-slate-200/60'}`}>
            <button
              onClick={() => setActiveTab('sandbox')}
              className={`flex items-center space-x-2 px-5 py-2 rounded-xl text-sm font-semibold transition-all ${
                activeTab === 'sandbox' 
                  ? 'bg-orange-500 text-white shadow-md shadow-orange-500/25' 
                  : `text-slate-400 hover:${isDarkMode ? 'text-white' : 'text-slate-700'}`
              }`}
            >
              <Smartphone className="h-4 w-4" />
              <span>Interactive Simulator</span>
            </button>
            <button
              onClick={() => setActiveTab('code')}
              className={`flex items-center space-x-2 px-5 py-2 rounded-xl text-sm font-semibold transition-all ${
                activeTab === 'code' 
                  ? 'bg-orange-500 text-white shadow-md shadow-orange-500/25' 
                  : `text-slate-400 hover:${isDarkMode ? 'text-white' : 'text-slate-700'}`
              }`}
            >
              <Code className="h-4 w-4" />
              <span>Flutter Codebase</span>
            </button>
            <button
              onClick={() => setActiveTab('tokens')}
              className={`flex items-center space-x-2 px-5 py-2 rounded-xl text-sm font-semibold transition-all ${
                activeTab === 'tokens' 
                  ? 'bg-orange-500 text-white shadow-md shadow-orange-500/25' 
                  : `text-slate-400 hover:${isDarkMode ? 'text-white' : 'text-slate-700'}`
              }`}
            >
              <Palette className="h-4 w-4" />
              <span>Design Tokens</span>
            </button>
          </div>
        </div>

        {/* ====================================================================
            TAB: SANDBOX PREVIEW (LIVE MOBILE SIMULATOR)
            ==================================================================== */}
        {activeTab === 'sandbox' && (
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center justify-center max-w-6xl mx-auto">
            
            {/* Left Info Column */}
            <div className="lg:col-span-5 space-y-6">
              <div className="space-y-2">
                <div className="inline-flex items-center space-x-1 bg-orange-500/10 text-orange-400 text-[11px] px-3 py-1 rounded-full border border-orange-500/20 font-bold">
                  <Sparkles className="h-3.5 w-3.5" />
                  <span>PREVIEW PLATFORM ACTIVE</span>
                </div>
                <h2 className="text-2xl font-extrabold tracking-tight">Interactive Flow Simulator</h2>
                <p className="text-sm text-slate-400 leading-relaxed">
                  Test the complete client journey for <strong>Laffah (لفّة)</strong>. Sign in using the OTP verification code and try out our beautifully animated map interfaces, ride options selector, and parcel booking flows.
                </p>
              </div>

              {simulatorStep === 'main_flow' ? (
                <div className={`p-5 rounded-2xl border ${isDarkMode ? 'bg-gray-900/30 border-gray-800' : 'bg-white border-slate-200'}`}>
                  <h3 className="font-bold text-sm text-orange-500 mb-3">Ride Flow Simulation:</h3>
                  <p className="text-xs text-slate-400 mb-4 leading-relaxed">
                    We've designed specialized simulated steps mimicking each of the 5 requested layouts. Use the <strong>Simulation Steps panel</strong> at the top of the mobile device to step through:
                  </p>
                  <ul className="text-xs text-slate-400 space-y-2 list-disc pl-4">
                    <li><strong>الرئيسية (Dashboard)</strong>: Displays primary services, quick and recent targets.</li>
                    <li><strong>البحث (Finding)</strong>: Runs real-time radar search sweeps on the map.</li>
                    <li><strong>العثور (Captain Found)</strong>: Match details with captain bio, vehicle details, and action shortcuts.</li>
                    <li><strong>في الطريق (In Progress)</strong>: Animates captain along custom map paths with real-time ETA countdowns.</li>
                    <li><strong>التقييم (Summary & Rate)</strong>: Computes total fare with client feedback forms.</li>
                  </ul>
                </div>
              ) : (
                <div className={`p-5 rounded-2xl border ${isDarkMode ? 'bg-gray-900/30 border-gray-800' : 'bg-white border-slate-200'}`}>
                  <h3 className="font-bold text-sm text-orange-500 mb-3">Simulator Instructions:</h3>
                  <ul className="text-xs text-slate-400 space-y-2.5 list-decimal pl-4">
                    <li>Choose the login role: <strong>عميل</strong> (Customer) or <strong>كابتن</strong> (Captain).</li>
                    <li>Enter any phone number (e.g., 777123456) and a password, then hit <strong>تسجيل الدخول</strong>.</li>
                    <li>On the OTP screen, type the simulation passcode: <strong className="text-orange-500 font-mono">1234</strong>.</li>
                  </ul>
                </div>
              )}

              {/* Reset button if got stuck */}
              {simulatorStep !== 'phone' && (
                <button 
                  onClick={() => {
                    setSimulatorStep('phone');
                    setPhoneInput('');
                    setPasswordInput('');
                    setErrorText('');
                    setRideStatus('idle');
                    setOpenRideSheet(false);
                    setOpenParcelSheet(false);
                  }}
                  className="flex items-center space-x-2 text-xs font-bold text-[#FF9800] hover:underline"
                >
                  <ChevronLeft className="h-4 w-4" />
                  <span>تسجيل الخروج وإعادة التشغيل (Logout / Reset)</span>
                </button>
              )}
            </div>

            {/* Simulated Phone Shell */}
            <div className="lg:col-span-7 flex justify-center">
              <div className="relative mx-auto border-[8px] border-slate-800 rounded-[38px] h-[720px] w-[350px] overflow-hidden shadow-2xl bg-[#0E1116] flex flex-col">
                
                {/* Notch */}
                <div className="absolute top-0 inset-x-0 h-6 bg-slate-800 rounded-b-xl flex justify-center z-50">
                  <div className="w-24 h-4 bg-black rounded-full mt-1 flex items-center justify-around px-4">
                    <div className="h-1.5 w-1.5 rounded-full bg-slate-800"></div>
                    <div className="h-1 w-8 rounded-full bg-slate-800"></div>
                  </div>
                </div>

                {/* Simulated Screen Body */}
                <div className={`flex-1 flex flex-col relative overflow-hidden text-right select-none ${isDarkMode ? 'bg-[#0E1116]' : 'bg-[#FFF7EF]'}`} dir="rtl">
                  
                  {/* Subtle Background gradient overlays representing screen designs */}
                  <div className="absolute inset-0 pointer-events-none opacity-40">
                    <div className="absolute top-0 right-0 w-44 h-44 rounded-full bg-[#FF9800]/10 blur-3xl"></div>
                    <div className="absolute bottom-10 left-0 w-44 h-44 rounded-full bg-[#3B82F6]/10 blur-3xl"></div>
                  </div>

                  {/* ==========================================================
                      SCREEN 1: Phone & Password Input Page
                      ========================================================== */}
                  {simulatorStep === 'phone' && (
                    <div className="flex-1 flex flex-col p-6 pt-10 overflow-y-auto">
                      
                      {/* Logo header */}
                      <div className="flex flex-col items-center mt-6">
                        <div className="relative h-20 w-20 flex items-center justify-center">
                          <svg viewBox="0 0 100 100" className="w-full h-full">
                            <defs>
                              <linearGradient id="orangeGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                                <stop offset="0%" stopColor="#FF9800" />
                                <stop offset="100%" stopColor="#FF6D00" />
                              </linearGradient>
                            </defs>
                            <path 
                              d="M 25,50 C 25,35 45,35 45,50 C 45,65 25,65 25,50 M 45,50 C 55,65 75,65 85,50" 
                              fill="none" 
                              stroke="url(#orangeGrad)" 
                              strokeWidth="11" 
                              strokeLinecap="round" 
                            />
                            <path 
                              d="M 25,50 C 25,35 45,35 45,50 C 45,65 25,65 25,50 M 45,50 C 55,65 75,65 85,50" 
                              fill="none" 
                              stroke="#ffffff" 
                              strokeWidth="2.5" 
                              strokeDasharray="5,4" 
                              strokeLinecap="round" 
                            />
                            <path d="M 75,50 L 75,15" fill="none" stroke="url(#orangeGrad)" strokeWidth="11" strokeLinecap="round" />
                            <polygon points="82,45 89,50 82,55" fill="#E65100" />
                            <circle cx="28" cy="22" r="4" fill="#FF9800" />
                            <circle cx="38" cy="22" r="4" fill="#FF9800" />
                            <circle cx="58" cy="18" r="4.5" fill="#FF9800" />
                          </svg>
                        </div>
                        <h3 className={`text-base font-bold mt-1.5 ${isDarkMode ? 'text-white' : 'text-slate-950'}`}>لَفَّة</h3>
                        <p className={`text-xs ${isDarkMode ? 'text-slate-400' : 'text-slate-500'}`}>مشوارك بـ لَفَّة واحدة</p>
                      </div>

                      {/* Premium Form Glassbox */}
                      <div className={`mt-6 p-5 rounded-[28px] border backdrop-blur-2xl transition-all ${
                        isDarkMode 
                          ? 'bg-[#1A1D24]/80 border-white/10 shadow-2xl' 
                          : 'bg-white/90 border-slate-200/50 shadow-xl shadow-orange-500/5'
                      }`}>
                        <h4 className={`text-base font-black text-center mb-4 ${isDarkMode ? 'text-white' : 'text-slate-900'}`}>تسجيل الدخول</h4>
                        
                        <div className={`flex h-11 rounded-xl p-1 mb-5 ${isDarkMode ? 'bg-gray-800/60' : 'bg-slate-100'}`}>
                          <button 
                            onClick={() => setRole('customer')}
                            className={`flex-1 rounded-lg flex items-center justify-center space-x-1.5 transition-all ${
                              role === 'customer' 
                                ? 'bg-[#FF9800] text-white shadow-md' 
                                : `text-slate-400 hover:${isDarkMode ? 'text-white' : 'text-slate-700'}`
                            }`}
                          >
                            <User className="h-4 w-4 ml-1" />
                            <span className="text-xs font-bold">عميل</span>
                          </button>
                          <button 
                            onClick={() => setRole('captain')}
                            className={`flex-1 rounded-lg flex items-center justify-center space-x-1.5 transition-all ${
                              role === 'captain' 
                                ? 'bg-[#FF9800] text-white shadow-md' 
                                : `text-slate-400 hover:${isDarkMode ? 'text-white' : 'text-slate-700'}`
                            }`}
                          >
                            <Car className="h-4 w-4 ml-1" />
                            <span className="text-xs font-bold">كابتن</span>
                          </button>
                        </div>

                        {errorText && (
                          <div className="bg-red-500/10 border border-red-500/20 text-red-400 text-[11px] p-2.5 rounded-xl text-center mb-4 font-bold leading-relaxed">
                            {errorText}
                          </div>
                        )}

                        <form onSubmit={handlePhoneSubmit} className="space-y-4">
                          <div className="relative flex items-center">
                            <div className="absolute right-3 flex items-center space-x-1.5 border-l border-slate-700/30 pl-2.5 ml-1">
                              <span className="text-[#E65100] font-black text-xs font-mono">967+</span>
                            </div>
                            <input 
                              type="tel" 
                              placeholder="7XXXXXXXX"
                              value={phoneInput}
                              onChange={(e) => setPhoneInput(e.target.value)}
                              className={`w-full pr-16 pl-9 py-3 rounded-xl text-xs font-bold font-mono tracking-wider border transition-all outline-none ${
                                isDarkMode 
                                  ? 'bg-black/30 border-white/5 text-white focus:border-orange-500/60' 
                                  : 'bg-slate-50 border-slate-200 text-slate-900 focus:border-orange-500/60'
                              }`}
                            />
                            <span className="absolute left-3 text-slate-400">
                              <PhoneIcon className="h-4 w-4" />
                            </span>
                          </div>

                          <div className="relative flex items-center">
                            <input 
                              type="password" 
                              placeholder="كلمة المرور"
                              value={passwordInput}
                              onChange={(e) => setPasswordInput(e.target.value)}
                              className={`w-full px-4 py-3 rounded-xl text-xs border transition-all outline-none ${
                                isDarkMode 
                                  ? 'bg-black/30 border-white/5 text-white focus:border-orange-500/60' 
                                  : 'bg-slate-50 border-slate-200 text-slate-900 focus:border-orange-500/60'
                              }`}
                            />
                          </div>

                          <button 
                            type="submit"
                            disabled={isLoading}
                            className="w-full h-11 bg-gradient-to-r from-[#FF9800] to-[#FF6D00] hover:brightness-110 active:brightness-95 transition-all text-white font-bold rounded-xl text-xs flex items-center justify-center space-x-1 shadow-lg shadow-orange-500/15"
                          >
                            {isLoading ? (
                              <div className="h-5 w-5 rounded-full border-2 border-white/30 border-t-white animate-spin"></div>
                            ) : (
                              <div className="flex items-center justify-center space-x-1">
                                <span>تسجيل الدخول</span>
                                <span className="transform rotate-180 mr-1.5">➡</span>
                              </div>
                            )}
                          </button>
                        </form>
                      </div>

                      <div className="mt-auto pt-6 flex flex-col items-center">
                        <span className={`text-xs font-bold ${isDarkMode ? 'text-slate-300' : 'text-slate-700'}`}>English 🌐</span>
                        <span className={`text-[9px] font-mono tracking-wider font-bold mt-1 ${isDarkMode ? 'text-slate-600' : 'text-slate-400'}`}>LAFFAH APP V2.4.0</span>
                      </div>

                    </div>
                  )}

                  {/* ==========================================================
                      SCREEN 2: OTP Verification screen
                      ========================================================== */}
                  {simulatorStep === 'otp' && (
                    <div className="flex-1 flex flex-col p-6 pt-10 overflow-y-auto">
                      
                      <div className="flex flex-col items-center mt-6">
                        <div className="relative h-16 w-16">
                          <svg viewBox="0 0 100 100" className="w-full h-full">
                            <path 
                              d="M 25,50 C 25,35 45,35 45,50 C 45,65 25,65 25,50 M 45,50 C 55,65 75,65 85,50" 
                              fill="none" 
                              stroke="url(#orangeGrad)" 
                              strokeWidth="11" 
                              strokeLinecap="round" 
                            />
                            <path 
                              d="M 25,50 C 25,35 45,35 45,50 C 45,65 25,65 25,50 M 45,50 C 55,65 75,65 85,50" 
                              fill="none" 
                              stroke="#ffffff" 
                              strokeWidth="2.5" 
                              strokeDasharray="5,4" 
                              strokeLinecap="round" 
                            />
                            <path d="M 75,50 L 75,15" fill="none" stroke="url(#orangeGrad)" strokeWidth="11" strokeLinecap="round" />
                            <polygon points="82,45 89,50 82,55" fill="#E65100" />
                          </svg>
                        </div>
                        <h3 className={`text-lg font-black mt-3 ${isDarkMode ? 'text-white' : 'text-slate-900'}`}>تأكيد رقم الحساب</h3>
                        <p className={`text-xs text-center px-4 mt-1 leading-relaxed ${isDarkMode ? 'text-slate-400' : 'text-slate-600'}`}>
                          أدخل رمز التحقق المكون من 4 أرقام والذي تم إرساله إلى الرقم <strong className="text-orange-500 font-mono tracking-wider">+967{phoneInput}</strong>
                        </p>
                      </div>

                      <div className={`mt-6 p-5 rounded-[28px] border backdrop-blur-2xl transition-all ${
                        isDarkMode 
                          ? 'bg-[#1A1D24]/80 border-white/10 shadow-2xl' 
                          : 'bg-white/90 border-slate-200/50 shadow-xl'
                      }`}>
                        
                        <h4 className={`text-xs font-black text-center tracking-wider mb-5 uppercase ${isDarkMode ? 'text-slate-400' : 'text-slate-600'}`}>أدخل رمز التحقق</h4>

                        {errorText && (
                          <div className="bg-red-500/10 border border-red-500/20 text-red-400 text-[11px] p-2.5 rounded-xl text-center mb-4 leading-relaxed font-bold">
                            {errorText}
                          </div>
                        )}

                        <div className="flex justify-between items-center px-2 mb-6" dir="ltr">
                          {otpInputs.map((val, idx) => (
                            <input 
                              key={idx}
                              id={`otp-${idx}`}
                              type="text"
                              maxLength={1}
                              pattern="[0-9]*"
                              inputMode="numeric"
                              value={val}
                              onChange={(e) => handleOtpChange(idx, e.target.value)}
                              className={`w-11 h-11 text-center font-bold text-lg rounded-xl border-2 transition-all outline-none ${
                                isDarkMode 
                                  ? 'bg-black/20 border-white/10 text-white focus:border-orange-500' 
                                  : 'bg-slate-50 border-slate-200 text-slate-900 focus:border-orange-500'
                              }`}
                            />
                          ))}
                        </div>

                        <div className="flex items-center justify-center space-x-1.5 mb-5 text-xs font-semibold">
                          <Timer className="h-4 w-4 ml-1.5 text-orange-500 animate-pulse" />
                          <span className={otpTimer > 0 ? 'text-orange-500' : 'text-slate-400'}>
                            {otpTimer > 0 
                              ? `إعادة الإرسال خلال ${otpTimer} ثانية` 
                              : 'يمكنك الآن إعادة إرسال الرمز'}
                          </span>
                        </div>

                        <button 
                          onClick={() => {
                            if (otpInputs.join('').length !== 4) {
                              setErrorText('الرجاء إدخال الرمز كاملاً');
                              return;
                            }
                            setIsLoading(true);
                            setTimeout(() => {
                              setIsLoading(false);
                              if (otpInputs.join('') === '1234') {
                                setSimulatorStep('main_flow');
                                setRideStatus('idle');
                              } else {
                                setErrorText('الرمز غير صحيح! للتجربة الناجحة أدخل "1234"');
                              }
                            }, 1000);
                          }}
                          disabled={isLoading}
                          className="w-full h-11 bg-gradient-to-r from-[#FF9800] to-[#FF6D00] text-white text-xs font-bold rounded-xl flex items-center justify-center shadow-lg shadow-orange-500/10"
                        >
                          {isLoading ? (
                            <div className="h-5 w-5 rounded-full border-2 border-white/30 border-t-white animate-spin"></div>
                          ) : (
                            <span>تأكيد الدخول</span>
                          )}
                        </button>
                      </div>

                    </div>
                  )}

                  {/* ==========================================================
                      SCREEN 3: MAIN WORKFLOW WORKSPACE (Dashboard + Map Simulator)
                      ========================================================== */}
                  {simulatorStep === 'main_flow' && role === 'customer' && (
                    <div className="flex-1 flex flex-col relative overflow-hidden">
                      
                      {/* Interactive Simulated Map Background */}
                      <div className="absolute inset-0 bg-[#121620] overflow-hidden">
                        
                        {/* Map road layouts drawn with CSS vector lines */}
                        <div className="absolute inset-0 opacity-20">
                          {/* Hadda street */}
                          <div className="absolute top-0 right-1/3 w-6 h-full bg-slate-600 transform rotate-12"></div>
                          {/* Ring street */}
                          <div className="absolute top-1/4 left-0 w-full h-8 bg-slate-600 transform -rotate-12"></div>
                          {/* Sixty street */}
                          <div className="absolute bottom-1/4 left-0 w-full h-6 bg-slate-600 transform rotate-6"></div>
                        </div>

                        {/* Location pin overlays */}
                        {rideStatus !== 'idle' && (
                          <>
                            {/* Pin A: Pickup (Hadda Street) */}
                            <div className="absolute top-1/3 right-1/3 flex flex-col items-center z-10">
                              <div className="h-8 w-8 rounded-full bg-emerald-500 flex items-center justify-center text-white font-bold text-xs shadow-lg ring-4 ring-emerald-500/20 animate-bounce">A</div>
                              <span className="text-[9px] bg-black/80 px-2 py-0.5 rounded text-white mt-1 font-semibold whitespace-nowrap">شارع حدة</span>
                            </div>

                            {/* Pin B: Destination (Sana'a University) */}
                            <div className="absolute bottom-1/3 left-1/4 flex flex-col items-center z-10">
                              <div className="h-8 w-8 rounded-full bg-red-500 flex items-center justify-center text-white font-bold text-xs shadow-lg ring-4 ring-red-500/20">B</div>
                              <span className="text-[9px] bg-black/80 px-2 py-0.5 rounded text-white mt-1 font-semibold whitespace-nowrap">جامعة صنعاء</span>
                            </div>

                            {/* Simulated Route Line */}
                            <div className="absolute top-[37%] right-[35%] w-[130px] h-[110px] border-b-4 border-l-4 border-dashed border-[#FF9800] rounded-bl-[40px] pointer-events-none opacity-80"></div>
                          </>
                        )}

                        {/* RADAR SWEEP EFFECT (Finding Captain State) */}
                        {rideStatus === 'finding' && (
                          <div className="absolute inset-0 flex items-center justify-center">
                            <div className="h-44 w-44 rounded-full border-2 border-orange-500/30 animate-ping absolute"></div>
                            <div className="h-28 w-28 rounded-full border-2 border-orange-500/40 animate-ping absolute delay-1000"></div>
                            <div className="h-12 w-12 rounded-full bg-orange-500/10 flex items-center justify-center animate-pulse">
                              <Compass className="h-6 w-6 text-[#FF9800] animate-spin" />
                            </div>
                          </div>
                        )}

                        {/* Simulated Captain Moving Marker */}
                        {rideStatus === 'found' && (
                          <div className="absolute top-[35%] right-[40%] flex flex-col items-center z-20 animate-pulse">
                            <div className="p-1.5 rounded-full bg-[#FF9800] text-white shadow-lg shadow-orange-500/30 ring-2 ring-white">
                              <Car className="h-4 w-4" />
                            </div>
                            <span className="text-[8px] bg-[#FF9800] text-white px-1 py-0.5 rounded mt-0.5 whitespace-nowrap font-bold">الكابتن قادم</span>
                          </div>
                        )}

                        {rideStatus === 'in_progress' && (
                          <div className="absolute bottom-[40%] left-[30%] flex flex-col items-center z-20">
                            <div className="p-1.5 rounded-full bg-[#FF9800] text-white shadow-lg shadow-orange-500/30 ring-2 ring-white animate-bounce">
                              <Car className="h-4 w-4" />
                            </div>
                            <span className="text-[8px] bg-emerald-500 text-white px-1 py-0.5 rounded mt-0.5 whitespace-nowrap font-bold">في الطريق</span>
                          </div>
                        )}
                      </div>

                      {/* Floating Header Actions Overlay */}
                      <div className="absolute top-8 inset-x-0 px-4 z-20">
                        <div className="flex items-center justify-between">
                          <div className="h-9 w-9 rounded-full bg-slate-900/80 backdrop-blur-md flex items-center justify-center text-orange-500 shadow-md">
                            <User className="h-4 w-4" />
                          </div>
                          <span className="text-sm font-black text-white bg-slate-900/80 backdrop-blur-md px-4 py-1.5 rounded-full shadow-md">لَفَّة Laffah</span>
                          <div className="h-9 w-9 rounded-full bg-slate-900/80 backdrop-blur-md flex items-center justify-center text-orange-500 shadow-md">
                            <Compass className="h-4 w-4" />
                          </div>
                        </div>

                        {/* Interactive Step selectors directly inside phone screen simulating our 5 layout screenshots */}
                        <div className="mt-3 flex space-x-1 overflow-x-auto py-1.5 px-1 bg-black/60 backdrop-blur-sm rounded-xl border border-white/10" dir="rtl">
                          <button 
                            onClick={() => { setRideStatus('idle'); setOpenRideSheet(false); setOpenParcelSheet(false); }}
                            className={`px-2.5 py-1 text-[10px] font-bold rounded-lg whitespace-nowrap shrink-0 ${rideStatus === 'idle' ? 'bg-[#FF9800] text-white' : 'text-slate-300 hover:text-white'}`}
                          >
                            1. الرئيسية
                          </button>
                          <button 
                            onClick={() => { setRideStatus('finding'); setOpenRideSheet(false); }}
                            className={`px-2.5 py-1 text-[10px] font-bold rounded-lg whitespace-nowrap shrink-0 ${rideStatus === 'finding' ? 'bg-[#FF9800] text-white' : 'text-slate-300'}`}
                          >
                            2. جاري البحث
                          </button>
                          <button 
                            onClick={() => setRideStatus('found')}
                            className={`px-2.5 py-1 text-[10px] font-bold rounded-lg whitespace-nowrap shrink-0 ${rideStatus === 'found' ? 'bg-[#FF9800] text-white' : 'text-slate-300'}`}
                          >
                            3. تم القبول
                          </button>
                          <button 
                            onClick={() => setRideStatus('in_progress')}
                            className={`px-2.5 py-1 text-[10px] font-bold rounded-lg whitespace-nowrap shrink-0 ${rideStatus === 'in_progress' ? 'bg-[#FF9800] text-white' : 'text-slate-300'}`}
                          >
                            4. الرحلة
                          </button>
                          <button 
                            onClick={() => setRideStatus('completed')}
                            className={`px-2.5 py-1 text-[10px] font-bold rounded-lg whitespace-nowrap shrink-0 ${rideStatus === 'completed' ? 'bg-[#FF9800] text-white' : 'text-slate-300'}`}
                          >
                            5. ملخص وتقييم
                          </button>
                        </div>
                      </div>

                      {/* Dynamic Workflow Bottom Module */}
                      <div className="mt-auto relative z-30">
                        {isLoading && (
                          <div className="p-6 bg-slate-900/90 backdrop-blur-lg border-t border-white/10 rounded-t-[32px] text-center">
                            <div className="h-8 w-8 rounded-full border-4 border-orange-500/30 border-t-orange-500 animate-spin mx-auto mb-3"></div>
                            <p className="text-xs text-slate-300 font-bold">جاري البحث عن أقرب كباتن لَفَّة...</p>
                          </div>
                        )}

                        {/* 1. INITIAL DASHBOARD (Screenshot 1) */}
                        {rideStatus === 'idle' && !isLoading && (
                          <div className="p-5 bg-slate-900/90 backdrop-blur-lg border-t border-white/10 rounded-t-[32px] shadow-2xl flex flex-col space-y-4">
                            
                            {/* Upper Floating Destination Search prompt */}
                            <div 
                              onClick={() => setOpenRideSheet(true)}
                              className="bg-black/30 hover:bg-black/40 border border-white/5 p-3 rounded-2xl flex items-center justify-between cursor-pointer transition-all"
                            >
                              <div className="flex items-center space-x-2">
                                <Search className="h-4.5 w-4.5 text-[#FF9800] ml-2" />
                                <span className="text-xs text-slate-400 font-medium">إلى أين تريد الذهاب اليوم؟</span>
                              </div>
                              <span className="text-[10px] bg-orange-500/10 text-orange-400 px-2.5 py-0.5 rounded-lg border border-orange-500/20 font-bold">الآن</span>
                            </div>

                            {/* Core Quick Services buttons */}
                            <div className="grid grid-cols-2 gap-4">
                              <div 
                                onClick={() => setOpenRideSheet(true)}
                                className="bg-gradient-to-tr from-[#FF9800] to-[#FF6D00] p-4 rounded-2xl cursor-pointer text-white shadow-lg shadow-orange-500/10 transition-transform active:scale-95"
                              >
                                <Car className="h-7 w-7 mb-2 text-white" />
                                <h4 className="font-bold text-sm">طلب مشوار</h4>
                                <span className="text-[10px] text-orange-50">مشاوير سريعة ومريحة</span>
                              </div>

                              <div 
                                onClick={() => setOpenParcelSheet(true)}
                                className="bg-slate-800 border border-white/5 p-4 rounded-2xl cursor-pointer text-white transition-transform active:scale-95 hover:bg-slate-700/80"
                              >
                                <Package className="h-7 w-7 mb-2 text-orange-500" />
                                <h4 className="font-bold text-sm">إرسال طرد</h4>
                                <span className="text-[10px] text-slate-400">توصيل سريع وموثوق</span>
                              </div>
                            </div>

                            {/* Quick Targets ("وجهات سريعة") */}
                            <div>
                              <h5 className="text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-2">وجهات سريعة</h5>
                              <div className="flex space-x-3 overflow-x-auto py-1" dir="rtl">
                                <div className="flex flex-col items-center space-y-1 hover:opacity-80 cursor-pointer">
                                  <div className="h-10 w-10 rounded-full bg-slate-800 flex items-center justify-center text-orange-400 ml-2">🏠</div>
                                  <span className="text-[10px] font-bold text-slate-300">المنزل</span>
                                </div>
                                <div className="flex flex-col items-center space-y-1 hover:opacity-80 cursor-pointer">
                                  <div className="h-10 w-10 rounded-full bg-slate-800 flex items-center justify-center text-orange-400 ml-2">💼</div>
                                  <span className="text-[10px] font-bold text-slate-300">العمل</span>
                                </div>
                                <div className="flex flex-col items-center space-y-1 hover:opacity-80 cursor-pointer">
                                  <div className="h-10 w-10 rounded-full bg-slate-800 flex items-center justify-center text-orange-400 ml-2">🎓</div>
                                  <span className="text-[10px] font-bold text-slate-300">الجامعة</span>
                                </div>
                              </div>
                            </div>

                            {/* Recent Targets ("آخر الوجهات") */}
                            <div className="border-t border-white/5 pt-3">
                              <h5 className="text-[11px] font-bold text-slate-400 mb-2">آخر الوجهات</h5>
                              <div className="space-y-2">
                                <div className="flex justify-between items-center text-xs">
                                  <div className="flex items-center">
                                    <Clock className="h-3.5 w-3.5 text-slate-500 ml-2" />
                                    <div>
                                      <p className="font-bold text-slate-200 text-xs">صنعاء مول</p>
                                      <p className="text-[10px] text-slate-400">شارع حدة، صنعاء</p>
                                    </div>
                                  </div>
                                  <span className="text-[10px] text-orange-400 font-bold">2.4 كم</span>
                                </div>
                              </div>
                            </div>

                          </div>
                        )}

                        {/* 2. FINDING CAPTAIN VIEW (Screenshot 2) */}
                        {rideStatus === 'finding' && !isLoading && (
                          <div className="p-5 bg-slate-900/90 backdrop-blur-lg border-t border-white/10 rounded-t-[32px] shadow-2xl flex flex-col space-y-4">
                            <div className="flex items-center space-x-3">
                              <div className="h-8 w-8 rounded-full border-4 border-[#FF9800] border-t-transparent animate-spin ml-2"></div>
                              <div>
                                <h4 className="font-bold text-slate-100 text-sm">جاري البحث عن كابتن...</h4>
                                <p className="text-[11px] text-slate-400">سنصل إليك قريباً خلال دقائق</p>
                              </div>
                            </div>

                            <div className="bg-black/30 p-3 rounded-xl space-y-1.5 text-xs text-slate-300">
                              <div className="flex items-center">
                                <div className="h-2 w-2 rounded-full bg-emerald-500 ml-2"></div>
                                <span className="text-[11px]">الوصول المتوقع: 5 دقائق</span>
                              </div>
                              <div className="flex items-center">
                                <div className="h-2 w-2 rounded-full bg-orange-500 ml-2"></div>
                                <span className="text-[11px]">كباتن بالقرب منك: 8 كباتن</span>
                              </div>
                            </div>

                            <div className="flex justify-between items-center text-sm font-bold border-t border-white/5 pt-3">
                              <span className="text-slate-300">لَفَّة بريميوم</span>
                              <span className="text-[#FF9800]">2,500 ريال</span>
                            </div>

                            <button 
                              onClick={() => setRideStatus('idle')}
                              className="w-full py-2.5 bg-red-500/10 hover:bg-red-500/20 text-red-400 rounded-xl font-bold text-xs border border-red-500/20"
                            >
                              إلغاء الطلب
                            </button>
                          </div>
                        )}

                        {/* 3. CAPTAIN FOUND VIEW (Screenshot 3) */}
                        {rideStatus === 'found' && !isLoading && (
                          <div className="p-5 bg-slate-900/95 backdrop-blur-lg border-t border-white/15 rounded-t-[32px] shadow-2xl flex flex-col space-y-4">
                            <div className="flex justify-between items-center">
                              <div className="flex items-center">
                                <div className="h-2 w-2 rounded-full bg-emerald-500 ml-1.5 animate-pulse"></div>
                                <h4 className="font-bold text-emerald-400 text-sm">يصل خلال 4 دقائق</h4>
                              </div>
                              <span className="text-[10px] bg-emerald-500/15 text-emerald-400 px-2 py-0.5 rounded font-bold">في الطريق</span>
                            </div>

                            {/* Captain and Car Block */}
                            <div className="flex items-center justify-between border-y border-white/5 py-3">
                              <div className="flex items-center">
                                <div className="h-11 w-11 rounded-full bg-[#FF9800]/20 text-[#FF9800] flex items-center justify-center font-bold ml-3 text-lg">أ</div>
                                <div>
                                  <div className="flex items-center">
                                    <h5 className="font-bold text-slate-100 text-sm">أحمد محمد</h5>
                                    <span className="text-[9px] bg-sky-500/15 text-sky-400 px-1.5 py-0.2 rounded ml-1.5 font-bold">موثوق ✓</span>
                                  </div>
                                  <p className="text-[11px] text-slate-400">تويوتا كورولا • أبيض</p>
                                </div>
                              </div>

                              <div className="text-left">
                                <div className="bg-slate-800 border border-[#FF9800] text-slate-100 font-mono font-bold px-3 py-1 rounded text-sm">
                                  77213
                                </div>
                                <p className="text-[10px] text-[#FF9800] mt-1">⭐ 4.9 (240 رحلة)</p>
                              </div>
                            </div>

                            {/* Action shortcuts */}
                            <div className="grid grid-cols-2 gap-3">
                              <button className="h-10 bg-gradient-to-r from-[#FF9800] to-[#FF6D00] text-white text-xs font-bold rounded-xl flex items-center justify-center">
                                <Phone className="h-3.5 w-3.5 ml-1.5" />
                                <span>اتصال بالكابتن</span>
                              </button>
                              <button 
                                onClick={() => setRideStatus('idle')}
                                className="h-10 bg-slate-800 border border-white/5 text-red-400 text-xs font-bold rounded-xl"
                              >
                                إلغاء اللفة
                              </button>
                            </div>
                          </div>
                        )}

                        {/* 4. RIDE IN PROGRESS VIEW (Screenshot 4) */}
                        {rideStatus === 'in_progress' && !isLoading && (
                          <div className="p-5 bg-slate-900/95 backdrop-blur-lg border-t border-white/15 rounded-t-[32px] shadow-2xl flex flex-col space-y-4">
                            <div className="flex justify-between items-center">
                              <h4 className="font-bold text-slate-100 text-sm">تتبع اللفة المباشرة</h4>
                              <span className="text-[10px] bg-orange-500/15 text-orange-400 px-2 py-0.5 rounded font-bold">في الطريق للوجهة</span>
                            </div>

                            {/* Progress specs */}
                            <div className="grid grid-cols-2 gap-3">
                              <div className="bg-black/25 p-2.5 rounded-xl">
                                <p className="text-[9px] text-[#FF9800]">الوقت المتبقي</p>
                                <p className="text-sm font-black text-white">12 دقيقة</p>
                              </div>
                              <div className="bg-black/25 p-2.5 rounded-xl">
                                <p className="text-[9px] text-[#FF9800]">المسافة المتبقية</p>
                                <p className="text-sm font-black text-white">4.5 كم</p>
                              </div>
                            </div>

                            {/* Captain info */}
                            <div className="flex items-center justify-between border-t border-white/5 pt-3">
                              <div className="flex items-center">
                                <div className="h-9 w-9 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center font-bold ml-2">م</div>
                                <div>
                                  <p className="font-bold text-xs text-slate-200">محمد العنسي (الكابتن)</p>
                                  <p className="text-[10px] text-slate-400">كيا سيراتو • 4.8 ⭐</p>
                                </div>
                              </div>
                              <div className="flex space-x-1">
                                <button className="p-2 bg-slate-800 rounded-lg text-orange-400 ml-1"><MessageSquare className="h-4 w-4" /></button>
                                <button className="p-2 bg-slate-800 rounded-lg text-orange-400"><Phone className="h-4 w-4" /></button>
                              </div>
                            </div>

                            <button 
                              onClick={() => alert('تم مشاركة رابط تتبع الرحلة')}
                              className="w-full h-9 bg-slate-800 border border-white/5 text-[#FF9800] text-xs font-bold rounded-xl flex items-center justify-center"
                            >
                              <Share2 className="h-3.5 w-3.5 ml-1.5" />
                              <span>مشاركة تفاصيل الرحلة</span>
                            </button>
                          </div>
                        )}

                        {/* 5. RIDE COMPLETED & RATING (Screenshot 5) */}
                        {rideStatus === 'completed' && !isLoading && (
                          <div className="p-5 bg-slate-900/95 backdrop-blur-lg border-t border-white/15 rounded-t-[32px] shadow-2xl flex flex-col space-y-4">
                            <div className="text-center">
                              <div className="h-10 w-10 bg-emerald-500/10 text-emerald-400 rounded-full flex items-center justify-center mx-auto mb-1">✓</div>
                              <h4 className="font-black text-emerald-400 text-sm">وصلت بحمد الله</h4>
                            </div>

                            {/* Price Detail */}
                            <div className="bg-[#FF9800]/5 border border-[#FF9800]/20 p-3.5 rounded-2xl text-center">
                              <p className="text-[10px] text-slate-400">إجمالي تكلفة الرحلة</p>
                              <p className="text-xl font-black text-[#FF9800] mt-1">2,500 ريال</p>
                              <span className="text-[10px] text-slate-300">طريقة الدفع: نقداً (كاش) للكابتن</span>
                            </div>

                            {/* Feed stars selector */}
                            <div className="text-center">
                              <p className="text-xs font-bold text-slate-300 mb-1.5">كيف كانت تجربتك مع الكابتن محمد؟</p>
                              <div className="flex justify-center space-x-1.5">
                                {[1, 2, 3, 4, 5].map((s) => (
                                  <Star 
                                    key={s} 
                                    onClick={() => setStarRating(s)}
                                    className={`h-6 w-6 cursor-pointer transition-colors ${starRating >= s ? 'text-yellow-400 fill-yellow-400' : 'text-slate-500'}`} 
                                  />
                                ))}
                              </div>
                            </div>

                            {/* Submit Rating */}
                            <button 
                              onClick={() => {
                                alert('تم إرسال التقييم بنجاح! شكراً لك.');
                                setRideStatus('idle');
                              }}
                              className="w-full py-2.5 bg-gradient-to-r from-[#FF9800] to-[#FF6D00] text-white rounded-xl font-bold text-xs shadow-md shadow-orange-500/10"
                            >
                              إرسال التقييم وإنهاء الرحلة
                            </button>
                          </div>
                        )}

                        {/* 6. PARCEL SUBMITTED DETAILS */}
                        {rideStatus === 'parcel_submitted' && !isLoading && (
                          <div className="p-5 bg-slate-900/95 backdrop-blur-lg border-t border-white/15 rounded-t-[32px] shadow-2xl flex flex-col space-y-4 text-center">
                            <div className="h-10 w-10 bg-[#FF9800]/15 text-[#FF9800] rounded-full flex items-center justify-center mx-auto">📦</div>
                            <h4 className="font-bold text-slate-100 text-sm">تم تأكيد طلب الطرد!</h4>
                            
                            <div className="bg-black/30 p-3 rounded-xl text-right text-xs text-slate-300 space-y-1.5">
                              <div className="flex justify-between">
                                <span>رقم التتبع:</span>
                                <strong className="font-mono text-orange-400">LFH-78216</strong>
                              </div>
                              <div className="flex justify-between">
                                <span>المستلم:</span>
                                <strong>{receiverName || 'محمد يحيى'}</strong>
                              </div>
                              <div className="flex justify-between">
                                <span>الحجم:</span>
                                <strong>{parcelSize === 'small' ? 'صغير' : parcelSize === 'medium' ? 'متوسط' : 'كبير'}</strong>
                              </div>
                              <div className="flex justify-between">
                                <span>التكلفة المقدرة:</span>
                                <strong className="text-emerald-400">
                                  {parcelSize === 'small' ? '1,500' : parcelSize === 'medium' ? '2,000' : '3,000'} ريال
                                </strong>
                              </div>
                            </div>

                            <button 
                              onClick={() => setRideStatus('idle')}
                              className="w-full py-2.5 bg-gradient-to-r from-[#FF9800] to-[#FF6D00] text-white rounded-xl font-bold text-xs"
                            >
                              العودة للرئيسية
                            </button>
                          </div>
                        )}

                      </div>

                      {/* ==========================================================
                          POPUP MODAL 1: Simulated Ride Selection Bottom Sheet
                          ========================================================== */}
                      {openRideSheet && (
                        <div className="absolute inset-0 bg-black/60 z-50 flex flex-col justify-end">
                          <div className="p-5 bg-slate-900 border-t border-white/10 rounded-t-[32px] max-h-[85%] overflow-y-auto">
                            <div className="flex justify-between items-center mb-4">
                              <h4 className="font-black text-slate-100 text-sm">تفاصيل حجز اللفة</h4>
                              <button onClick={() => setOpenRideSheet(false)} className="text-slate-400 text-xs">إغلاق</button>
                            </div>

                            {/* Payment and Scheduling controls at the top */}
                            <div className="grid grid-cols-2 gap-3 mb-4">
                              <div className="p-3 rounded-xl bg-slate-800/40 border border-white/5 flex items-center justify-center space-x-2 rtl:space-x-reverse text-xs text-slate-200">
                                <span className="text-[#FF9800]">💵</span>
                                <span className="font-bold">الدفع: نقدي</span>
                              </div>
                              <div className="p-3 rounded-xl bg-slate-800/40 border border-white/5 flex items-center justify-center space-x-2 rtl:space-x-reverse text-xs text-slate-200">
                                <span className="text-[#FF9800]">📅</span>
                                <span className="font-bold">الجدولة (السدود): الآن</span>
                              </div>
                            </div>

                            {/* Consolidated Trip Info Panel: Single premium GlassBox card */}
                            <div className="p-4 rounded-2xl bg-slate-800/30 border border-white/10 mb-4 space-y-4 text-right">
                              <div className="flex items-center space-x-3 rtl:space-x-reverse">
                                <div className="h-10 w-10 rounded-full bg-[#FF9800]/15 flex items-center justify-center text-[#FF9800] text-lg">
                                  🚗
                                </div>
                                <div>
                                  <h5 className="font-bold text-slate-100 text-sm">الخيار الوحيد المتاح: لَفّة</h5>
                                  <p className="text-[10px] text-slate-400">المشوار الاقتصادي والآمن لجميع تنقلاتك داخل العاصمة</p>
                                </div>
                              </div>
                              
                              <div className="border-t border-white/5 my-3"></div>
                              
                              <div className="grid grid-cols-2 gap-4 text-center">
                                <div>
                                  <span className="text-slate-400 text-[10px] block mb-1">المسافة المقدرة</span>
                                  <span className="text-[#FF9800] text-xs">📏</span>
                                  <span className="font-black text-slate-100 text-sm ml-1">5.4 كم</span>
                                </div>
                                <div>
                                  <span className="text-slate-400 text-[10px] block mb-1">الوقت المقدر للرحلة</span>
                                  <span className="text-[#FF9800] text-xs">⏱️</span>
                                  <span className="font-black text-slate-100 text-sm ml-1">15 دقيقة</span>
                                </div>
                              </div>

                              <div className="border-t border-white/5 my-3"></div>

                              <p className="text-[10px] text-slate-400 text-center">
                                السعر محسوب بناءً على الكيلومترات والوقت الفعلي للرحلة
                              </p>
                            </div>

                            {/* Final Price Display */}
                            <div className="p-3 rounded-xl bg-[#FF9800]/5 border border-[#FF9800]/15 flex items-center justify-between mb-4">
                              <div className="text-right">
                                <h6 className="font-bold text-slate-300 text-xs">إجمالي الأجرة لخدمة لَفّة</h6>
                                <p className="text-[9px] text-slate-500">السعر النهائي شامل كافة الرسوم والضرائب</p>
                              </div>
                              <span className="text-xl font-black text-[#FF9800]">2,500 ريال</span>
                            </div>

                            {/* Book action button */}
                            <button 
                              onClick={handleConfirmRide}
                              className="w-full h-11 bg-gradient-to-r from-[#FF9800] to-[#FF6D00] text-white font-bold rounded-xl text-xs flex items-center justify-center space-x-2 rtl:space-x-reverse"
                            >
                              <span>تأكيد الحجز والرحلة</span>
                            </button>
                          </div>
                        </div>
                      )}

                      {/* ==========================================================
                          POPUP MODAL 2: Simulated Send Parcel Form Bottom Sheet
                          ========================================================== */}
                      {openParcelSheet && (
                        <div className="absolute inset-0 bg-black/60 z-50 flex flex-col justify-end">
                          <form 
                            onSubmit={handleConfirmParcel}
                            className="p-5 bg-slate-900 border-t border-white/10 rounded-t-[32px] max-h-[85%] overflow-y-auto space-y-4"
                          >
                            <div className="flex justify-between items-center">
                              <h4 className="font-black text-slate-100 text-sm">طلب إرسال طرد سريع</h4>
                              <button type="button" onClick={() => setOpenParcelSheet(false)} className="text-slate-400 text-xs">إغلاق</button>
                            </div>

                            {/* Sender specs */}
                            <div className="space-y-2">
                              <p className="text-[10px] font-bold text-orange-500">بيانات المرسل (أنت)</p>
                              <div className="grid grid-cols-2 gap-2">
                                <input 
                                  type="text" 
                                  placeholder="اسم المرسل" 
                                  required 
                                  value={senderName}
                                  onChange={(e) => setSenderName(e.target.value)}
                                  className="p-2.5 bg-slate-800 border border-white/5 rounded-xl text-xs text-white" 
                                />
                                <input type="text" placeholder="رقم الهاتف" value="777123456" disabled className="p-2.5 bg-slate-800/40 border border-white/5 rounded-xl text-xs text-slate-500" />
                              </div>
                            </div>

                            {/* Recipient specs */}
                            <div className="space-y-2">
                              <p className="text-[10px] font-bold text-orange-500">بيانات المستلم</p>
                              <div className="grid grid-cols-2 gap-2">
                                <input 
                                  type="text" 
                                  placeholder="اسم مستلم الشحنة" 
                                  required 
                                  value={receiverName}
                                  onChange={(e) => setReceiverName(e.target.value)}
                                  className="p-2.5 bg-slate-800 border border-white/5 rounded-xl text-xs text-white" 
                                />
                                <input 
                                  type="text" 
                                  placeholder="رقم الهاتف 7xxxxxxxx" 
                                  required 
                                  value={receiverPhone}
                                  onChange={(e) => setReceiverPhone(e.target.value)}
                                  className="p-2.5 bg-slate-800 border border-white/5 rounded-xl text-xs text-white" 
                                />
                              </div>
                            </div>

                            {/* Size selector */}
                            <div className="space-y-2">
                              <p className="text-[10px] font-bold text-slate-300">حجم الطرد التقريبي</p>
                              <div className="grid grid-cols-3 gap-2 text-center text-[10px]">
                                <div 
                                  onClick={() => setParcelSize('small')}
                                  className={`p-2 rounded-xl cursor-pointer border ${parcelSize === 'small' ? 'bg-[#FF9800]/20 border-[#FF9800]' : 'bg-slate-800 border-white/5'}`}
                                >
                                  <p className="font-bold text-white">صغير</p>
                                  <p className="text-[8px] text-slate-400 mt-0.5">1,500 ريال</p>
                                </div>
                                <div 
                                  onClick={() => setParcelSize('medium')}
                                  className={`p-2 rounded-xl cursor-pointer border ${parcelSize === 'medium' ? 'bg-[#FF9800]/20 border-[#FF9800]' : 'bg-slate-800 border-white/5'}`}
                                >
                                  <p className="font-bold text-white">متوسط</p>
                                  <p className="text-[8px] text-slate-400 mt-0.5">2,000 ريال</p>
                                </div>
                                <div 
                                  onClick={() => setParcelSize('large')}
                                  className={`p-2 rounded-xl cursor-pointer border ${parcelSize === 'large' ? 'bg-[#FF9800]/20 border-[#FF9800]' : 'bg-slate-800 border-white/5'}`}
                                >
                                  <p className="font-bold text-white">كبير</p>
                                  <p className="text-[8px] text-slate-400 mt-0.5">3,000 ريال</p>
                                </div>
                              </div>
                            </div>

                            <button 
                              type="submit"
                              className="w-full h-11 bg-gradient-to-r from-[#FF9800] to-[#FF6D00] text-white font-bold rounded-xl text-xs mt-2"
                            >
                              تقديم طلب توصيل الطرد
                            </button>
                          </form>
                        </div>
                      )}

                    </div>
                  )}

                  {/* ==========================================================
                      SCREEN 4: CAPTAIN WORKFLOW WORKSPACE (Interactive Simulator)
                      ========================================================== */}
                  {simulatorStep === 'main_flow' && role === 'captain' && (
                    <div className="flex-1 flex flex-col relative overflow-hidden bg-[#0E1116] text-[#FAFAFA]" dir="rtl">
                      
                      {/* Captain Header Bar */}
                      <div className="absolute top-8 inset-x-0 px-4 z-20 flex justify-between items-center">
                        <div className="flex items-center space-x-2 space-x-reverse">
                          <div className="h-9 w-9 rounded-full bg-slate-900/90 border border-white/10 flex items-center justify-center text-[#FF9800] text-xs font-bold shadow-md">
                            4.9 ★
                          </div>
                          <div className="text-right">
                            <p className="text-[10px] text-slate-400 font-bold">الكابتن علي</p>
                            <span className="text-[9px] bg-slate-800/95 px-1.5 py-0.5 rounded text-[#FF9800] border border-orange-500/20 font-bold">فئة الدراجات</span>
                          </div>
                        </div>
                        <span className="text-xs font-black text-white bg-slate-900/90 border border-white/10 px-4 py-1.5 rounded-full shadow-md">كابتن لَفَّة</span>
                        <div className={`px-3 py-1 rounded-full text-[10px] font-bold border transition-colors ${
                          isCaptainOnline 
                            ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20 animate-pulse' 
                            : 'bg-red-500/10 text-red-400 border-red-500/20'
                        }`}>
                          {isCaptainOnline ? 'نشط ●' : 'غير نشط ●'}
                        </div>
                      </div>

                      {/* Captain Screen Content Zone */}
                      <div className="flex-1 overflow-y-auto pt-24 pb-24 px-4 text-right">
                        
                        {/* TAB: HOME / RADAR / TRIPS WORK */}
                        {captainTab === 'home' && (
                          <div className="space-y-4 h-full flex flex-col justify-between">
                            
                            {/* Interactive Simulated Map Box */}
                            <div className="flex-1 bg-slate-950/40 rounded-[24px] border border-white/5 relative overflow-hidden min-h-[220px]">
                              {/* Vector grid roads */}
                              <div className="absolute inset-0 opacity-10">
                                <div className="absolute top-1/2 left-0 w-full h-4 bg-white transform rotate-12"></div>
                                <div className="absolute top-0 right-1/4 w-4 h-full bg-white transform -rotate-12"></div>
                              </div>

                              {/* Simulation Map Markers */}
                              {isCaptainOnline && captainTripState === 'idle' && (
                                <div className="absolute inset-0 flex flex-col items-center justify-center text-center p-4">
                                  <div className="h-14 w-14 rounded-full border-4 border-orange-500/30 border-t-orange-500 animate-spin flex items-center justify-center mb-3">
                                    <Compass className="h-6 w-6 text-[#FF9800]" />
                                  </div>
                                  <h5 className="font-bold text-xs text-white">جاري البحث عن مشاوير...</h5>
                                  <p className="text-[10px] text-slate-400 mt-1 max-w-[180px]">اضغط على زر المحاكاة أدناه لتلقي طلب مشوار افتراضي فوراً</p>
                                </div>
                              )}

                              {!isCaptainOnline && (
                                <div className="absolute inset-0 flex flex-col items-center justify-center text-center p-4">
                                  <div className="h-12 w-12 rounded-full bg-red-500/10 text-red-400 flex items-center justify-center mb-3">
                                    <AlertCircle className="h-6 w-6" />
                                  </div>
                                  <h5 className="font-bold text-xs text-slate-200">أنت غير متصل الآن</h5>
                                  <p className="text-[10px] text-slate-400 mt-1 max-w-[180px]">قم بتفعيل حالة الاستقبال في الأسفل لبدء العمل واستقبل الطلبات</p>
                                </div>
                              )}

                              {/* Trip Progress Visualizer */}
                              {captainTripState === 'navigation_accepted' && (
                                <div className="absolute inset-0 flex flex-col items-center justify-center p-4 text-center">
                                  <div className="h-10 w-10 rounded-full bg-emerald-500/10 text-emerald-400 flex items-center justify-center mb-2 animate-bounce">
                                    <MapPin className="h-5 w-5" />
                                  </div>
                                  <h5 className="font-bold text-xs text-white">متجه إلى الراكب (سارة العامري)</h5>
                                  <p className="text-[10px] text-slate-400 mt-0.5">حي حدة، أمام صنعاء مول</p>
                                  <div className="absolute bottom-3 inset-x-3 bg-black/60 p-2 rounded-xl text-[10px] border border-white/5">
                                    المسافة: 2.1 كم • الزمن: 5 دقائق
                                  </div>
                                </div>
                              )}

                              {captainTripState === 'navigation_arrived' && (
                                <div className="absolute inset-0 flex flex-col items-center justify-center p-4 text-center">
                                  <div className="h-10 w-10 rounded-full bg-[#FF9800]/10 text-[#FF9800] flex items-center justify-center mb-2 animate-pulse">
                                    <Clock className="h-5 w-5" />
                                  </div>
                                  <h5 className="font-bold text-xs text-[#FF9800]">الراكب في انتظارك بموقع الوصول</h5>
                                  <p className="text-[10px] text-slate-300 mt-0.5">الرجاء الترحيب بالراكب وبدء المشوار بعد ركوبه</p>
                                </div>
                              )}

                              {captainTripState === 'navigation_started' && (
                                <div className="absolute inset-0 flex flex-col items-center justify-center p-4 text-center">
                                  <div className="h-10 w-10 rounded-full bg-blue-500/10 text-blue-400 flex items-center justify-center mb-2 animate-spin">
                                    <Navigation className="h-5 w-5" />
                                  </div>
                                  <h5 className="font-bold text-xs text-white">المشوار جارٍ الآن...</h5>
                                  <p className="text-[10px] text-emerald-400 mt-0.5">الوجهة: شارع الستين، مستشفى آزال</p>
                                </div>
                              )}
                            </div>

                            {/* Trip actions / Online Switch Card */}
                            <div className="bg-[#1A1D24]/90 p-4 rounded-2xl border border-white/10 space-y-3 shadow-xl">
                              <div className="flex justify-between items-center">
                                <div className="text-right">
                                  <h6 className="font-bold text-xs text-white">استقبال طلبات لَفَّة</h6>
                                  <p className="text-[10px] text-slate-400">تلقي طلبات الركاب والطرود المجاورة</p>
                                </div>
                                <button
                                  type="button"
                                  onClick={() => {
                                    setIsCaptainOnline(!isCaptainOnline);
                                    if (isCaptainOnline) setCaptainTripState('idle');
                                  }}
                                  className={`w-14 h-7 rounded-full transition-colors relative flex items-center px-1 ${
                                    isCaptainOnline ? 'bg-gradient-to-r from-[#FF9800] to-[#FF6D00]' : 'bg-slate-700'
                                  }`}
                                >
                                  <div className={`h-5 w-5 rounded-full bg-white transition-transform ${
                                    isCaptainOnline ? 'transform translate-x-7' : ''
                                  }`} />
                                </button>
                              </div>

                              {isCaptainOnline && captainTripState === 'idle' && (
                                <button
                                  type="button"
                                  onClick={() => setCaptainTripState('incoming')}
                                  className="w-full py-2 bg-[#FF9800]/10 hover:bg-[#FF9800]/20 text-[#FF9800] border border-orange-500/20 text-[11px] font-bold rounded-xl flex items-center justify-center"
                                >
                                  <Sparkles className="h-3.5 w-3.5 ml-1.5" />
                                  محاكاة طلب مشوار جديد ✓
                                </button>
                              )}

                              {/* Navigation steps action controller */}
                              {captainTripState === 'navigation_accepted' && (
                                <button
                                  type="button"
                                  onClick={() => setCaptainTripState('navigation_arrived')}
                                  className="w-full py-2.5 bg-gradient-to-r from-[#FF9800] to-[#FF6D00] text-white text-xs font-bold rounded-xl shadow-lg shadow-orange-500/10"
                                >
                                  وصلت إلى موقع الراكب (أنا هنا)
                                </button>
                              )}

                              {captainTripState === 'navigation_arrived' && (
                                <button
                                  type="button"
                                  onClick={() => setCaptainTripState('navigation_started')}
                                  className="w-full py-2.5 bg-gradient-to-r from-emerald-500 to-teal-600 text-white text-xs font-bold rounded-xl shadow-lg shadow-emerald-500/10"
                                >
                                  بدء المشوار الفعلي للوجهة ▶
                                </button>
                              )}

                              {captainTripState === 'navigation_started' && (
                                <button
                                  type="button"
                                  onClick={() => setCaptainTripState('completed')}
                                  className="w-full py-2.5 bg-red-500 text-white text-xs font-bold rounded-xl shadow-lg shadow-red-500/10"
                                >
                                  إنهاء المشوار وتحصيل المبلغ ■
                                </button>
                              )}

                              {captainTripState === 'completed' && (
                                <div className="space-y-3 text-center border-t border-white/5 pt-3">
                                  <div className="bg-emerald-500/10 text-emerald-400 p-2.5 rounded-xl border border-emerald-500/20">
                                    <p className="text-[10px] font-bold text-slate-400">المبلغ المطلوب تحصيله نقداً:</p>
                                    <p className="text-lg font-black mt-0.5">1,800 ريال</p>
                                  </div>
                                  <button
                                    type="button"
                                    onClick={() => setCaptainTripState('idle')}
                                    className="w-full py-2.5 bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-bold rounded-xl"
                                  >
                                    تأكيد استلام المبلغ والعودة للرئيسية
                                  </button>
                                </div>
                              )}
                            </div>

                            {/* TripRequestDialog Overlay matching Screenshot 7 */}
                            {captainTripState === 'incoming' && (
                              <div className="absolute inset-0 bg-black/80 z-40 flex items-center justify-center p-4">
                                <div className="bg-[#1A1D24] border border-white/10 rounded-[28px] p-5 w-full max-w-sm space-y-4 animate-scale-up text-right">
                                  <div className="flex justify-between items-center pb-2 border-b border-white/5">
                                    <span className="text-[10px] bg-[#FF9800]/15 text-[#FF9800] px-2.5 py-0.5 rounded-full font-bold">طلب مشوار جديد</span>
                                    <span className="text-xs text-slate-400 font-bold">12 دقيقة • 4.5 كم</span>
                                  </div>

                                  <div className="flex items-center space-x-3 space-x-reverse justify-start">
                                    <div className="h-10 w-10 rounded-full bg-[#FF9800]/10 text-[#FF9800] flex items-center justify-center text-sm font-bold ml-3">
                                      س
                                    </div>
                                    <div>
                                      <h6 className="font-bold text-xs text-white">سارة العامري</h6>
                                      <span className="text-[9px] text-[#FF9800]">⭐ 4.9 (تقييم ممتاز)</span>
                                    </div>
                                  </div>

                                  <div className="space-y-2 bg-black/20 p-3 rounded-xl border border-white/5 text-right">
                                    <div className="flex items-center text-[11px] text-slate-300">
                                      <div className="h-2 w-2 rounded-full bg-emerald-500 ml-2"></div>
                                      <span className="font-bold ml-1">الموقع:</span>
                                      <span className="text-slate-400">حي حدة، صنعاء</span>
                                    </div>
                                    <div className="flex items-center text-[11px] text-slate-300 mt-1">
                                      <div className="h-2 w-2 rounded-full bg-red-500 ml-2"></div>
                                      <span className="font-bold ml-1">الوجهة:</span>
                                      <span className="text-slate-400">شارع الستين، أمام مستشفى آزال</span>
                                    </div>
                                  </div>

                                  <div className="flex justify-between items-center bg-[#FF9800]/5 p-3 rounded-xl border border-[#FF9800]/15">
                                    <span className="text-[10px] text-slate-400">التكلفة المقدرة</span>
                                    <span className="text-lg font-black text-[#FF9800]">1,800 ريال</span>
                                  </div>

                                  <div className="grid grid-cols-2 gap-3 pt-1">
                                    <button
                                      type="button"
                                      onClick={() => setCaptainTripState('navigation_accepted')}
                                      className="py-2.5 bg-gradient-to-r from-[#FF9800] to-[#FF6D00] hover:opacity-90 text-white rounded-xl text-xs font-bold shadow-lg shadow-orange-500/15"
                                    >
                                      قبول الطلب ✓
                                    </button>
                                    <button
                                      type="button"
                                      onClick={() => setCaptainTripState('idle')}
                                      className="py-2.5 bg-slate-800 hover:bg-slate-700 text-red-400 rounded-xl text-xs font-bold border border-red-500/15"
                                    >
                                      رفض الطلب ✗
                                    </button>
                                  </div>
                                </div>
                              </div>
                            )}

                          </div>
                        )}

                        {/* TAB: TRIPS / HISTORY LIST */}
                        {captainTab === 'trips' && (
                          <div className="space-y-3">
                            <h5 className="font-bold text-xs text-slate-400 mb-1">الرحلات المكتملة لليوم</h5>
                            
                            {[
                              { id: 'LF-9921', name: 'أحمد جلال', time: '02:30 م', fare: '2,500 ريال', type: 'مشوار دراجة' },
                              { id: 'LF-9821', name: 'سارة خالد', time: '11:15 ص', fare: '1,800 ريال', type: 'مشوار دراجة' },
                              { id: 'LF-9102', name: 'يوسف العنسي', time: 'أمس م', fare: '3,000 ريال', type: 'توصيل طرد' },
                            ].map((trip) => (
                              <div key={trip.id} className="bg-[#1A1D24] p-3.5 rounded-2xl border border-white/5 space-y-2">
                                <div className="flex justify-between items-center">
                                  <span className="text-[10px] bg-emerald-500/10 text-emerald-400 px-2 py-0.5 rounded font-bold">{trip.type}</span>
                                  <span className="text-[10px] text-slate-400 font-mono">{trip.id}</span>
                                </div>
                                <div className="flex justify-between items-center text-xs">
                                  <div>
                                    <p className="font-bold text-slate-200">{trip.name}</p>
                                    <p className="text-[9px] text-slate-400">{trip.time}</p>
                                  </div>
                                  <strong className="text-[#FF9800] font-bold">{trip.fare}</strong>
                                </div>
                              </div>
                            ))}
                          </div>
                        )}

                        {/* TAB: EARNINGS WALLET (Screenshot 5) */}
                        {captainTab === 'earnings' && (
                          <div className="space-y-4 text-right">
                            
                            {/* Total Wallet Balance card */}
                            <div className="bg-gradient-to-tr from-[#FF9800] to-[#FF6D00] p-5 rounded-3xl text-white shadow-xl shadow-orange-500/10">
                              <span className="text-[10px] text-orange-50 font-bold uppercase tracking-wider">الرصيد المتاح للسحب</span>
                              <h3 className="text-2xl font-black mt-1 font-mono">4,250 ريال</h3>
                              <p className="text-[9px] text-orange-100 mt-1">آخر تحديث: منذ دقيقتين</p>
                              
                              <button
                                type="button"
                                onClick={() => alert('تم إرسال طلب سحب الرصيد إلى محفظة الجوال بنجاح!')}
                                className="w-full mt-4 py-2 bg-white text-[#FF9800] rounded-xl font-bold text-xs shadow-md active:scale-95 transition-transform"
                              >
                                سحب الرصيد إلى كريمي / جوال سريع
                              </button>
                            </div>

                            {/* Active Weekly Target Grid with micro progress bar tracker */}
                            <div className="bg-[#1A1D24] p-4 rounded-2xl border border-white/10 space-y-3">
                              <div className="flex justify-between items-center">
                                <div className="text-right">
                                  <h6 className="font-bold text-xs text-white">الهدف الأسبوعي (البونص)</h6>
                                  <p className="text-[10px] text-slate-400">متبقي 5 مشاوير للحصول على 2,000 ريال إضافية</p>
                                </div>
                                <span className="text-xs text-emerald-400 font-black font-mono">75%</span>
                              </div>
                              <div className="h-2 w-full bg-slate-800 rounded-full overflow-hidden">
                                <div className="h-full bg-[#FF9800] rounded-full" style={{ width: '75%' }}></div>
                              </div>
                              <span className="text-[9px] text-[#FF9800] font-bold">15 من أصل 20 مشوار مكتمل</span>
                            </div>

                            {/* Earnings analytics list bar charts */}
                            <div>
                              <h5 className="font-bold text-xs text-slate-400 mb-2">إحصائيات الأسبوع الحالي</h5>
                              <div className="bg-[#1A1D24] p-3.5 rounded-2xl border border-white/5 flex items-end justify-between h-28 pt-6">
                                {[
                                  { day: 'أحد', height: '40%' },
                                  { day: 'اثنين', height: '65%' },
                                  { day: 'ثلاثاء', height: '80%' },
                                  { day: 'أربعاء', height: '55%' },
                                  { day: 'خميس', height: '95%' },
                                  { day: 'جمعة', height: '20%' },
                                ].map((d, idx) => (
                                  <div key={idx} className="flex flex-col items-center space-y-1.5 flex-1">
                                    <div className="w-4 bg-slate-800 rounded-t-sm h-16 relative overflow-hidden flex items-end">
                                      <div className="w-full bg-[#FF9800] rounded-t-sm" style={{ height: d.height }}></div>
                                    </div>
                                    <span className="text-[9px] text-slate-400 font-bold">{d.day}</span>
                                  </div>
                                ))}
                              </div>
                            </div>

                          </div>
                        )}

                        {/* TAB: NOTIFICATIONS & segmented filters (Screenshot 7) */}
                        {captainTab === 'notifications' && (
                          <div className="space-y-4 text-right">
                            
                            {/* Segmented Filter Tab bar */}
                            <div className="grid grid-cols-3 gap-1 bg-slate-950/60 p-1 rounded-xl border border-white/5">
                              {[
                                { id: 'new_requests', label: 'الطلبات' },
                                { id: 'system', label: 'تحديثات' },
                                { id: 'alerts', label: 'تنبيهات' },
                              ].map((tab) => (
                                <button
                                  key={tab.id}
                                  type="button"
                                  onClick={() => setNotificationsTab(tab.id as any)}
                                  className={`py-1.5 text-[10px] font-bold rounded-lg ${
                                    notificationsTab === tab.id 
                                      ? 'bg-[#FF9800] text-white' 
                                      : 'text-slate-400'
                                  }`}
                                >
                                  {tab.label}
                                </button>
                              ))}
                            </div>

                            {/* List cards depending on segmented tab */}
                            {notificationsTab === 'new_requests' && (
                              <div className="space-y-2.5">
                                <div className="bg-[#1A1D24] p-3.5 rounded-2xl border border-white/5 space-y-2">
                                  <div className="flex justify-between items-center text-[10px]">
                                    <span className="text-orange-400 font-bold">بانتظار قبولك</span>
                                    <span className="text-slate-500">منذ دقيقة</span>
                                  </div>
                                  <h6 className="font-bold text-xs text-white">طلب توصيل طرد في الحصبة</h6>
                                  <p className="text-[10px] text-slate-400">من: سوبرماركت الهدى إلى الحصبة</p>
                                  <div className="flex justify-between items-center pt-1">
                                    <span className="text-[11px] font-mono text-[#FF9800] font-black">2,000 ريال</span>
                                    <button
                                      type="button"
                                      onClick={() => setCaptainTripState('incoming')}
                                      className="px-3 py-1 bg-[#FF9800]/10 text-[#FF9800] hover:bg-[#FF9800]/20 rounded-lg text-[10px] font-bold border border-orange-500/20"
                                    >
                                      عرض وتفاصيل 
                                    </button>
                                  </div>
                                </div>

                                <div className="bg-[#1A1D24] p-3.5 rounded-2xl border border-white/5 space-y-2 opacity-60">
                                  <div className="flex justify-between items-center text-[10px]">
                                    <span className="text-slate-500">تم القبول</span>
                                    <span className="text-slate-500">منذ 20 د</span>
                                  </div>
                                  <h6 className="font-bold text-xs text-white">مشاور ركاب شارع تعز</h6>
                                  <p className="text-[10px] text-slate-400">من: فندق البستان إلى شارع تعز</p>
                                </div>
                              </div>
                            )}

                            {notificationsTab === 'system' && (
                              <div className="space-y-2.5 text-right">
                                <div className="bg-[#1A1D24] p-3.5 rounded-2xl border border-white/5 space-y-1">
                                  <span className="text-[9px] text-[#FF9800] font-bold">تحديث الشروط</span>
                                  <h6 className="font-bold text-xs text-slate-100">تم تحديث شروط خدمة الكباتن V2.4</h6>
                                  <p className="text-[10px] text-slate-400 leading-relaxed">يرجى مراجعة اللائحة التنظيمية الجديدة لخدمة لَفَّة لتجنب إيقاف الحساب.</p>
                                </div>
                              </div>
                            )}

                            {notificationsTab === 'alerts' && (
                              <div className="space-y-2.5 text-right">
                                <div className="bg-[#1A1D24] p-3.5 rounded-2xl border border-white/5 space-y-1.5">
                                  <span className="text-[9px] text-emerald-400 font-bold">بونص وحوافز اليوم</span>
                                  <h6 className="font-bold text-xs text-white">حافز إضافي بقيمة 500 ريال اليوم!</h6>
                                  <p className="text-[10px] text-slate-400 leading-relaxed">أكمل 5 مشاوير متتالية بين الساعة 4 م والـ 8 م واحصل على البونص الفوري.</p>
                                </div>
                              </div>
                            )}

                          </div>
                        )}

                        {/* TAB: ACCOUNT & VEHICLE SPECS (Screenshot 6) */}
                        {captainTab === 'account' && (
                          <div className="space-y-4 text-center">
                            
                            {/* Account Avatar Header */}
                            <div className="bg-[#1A1D24] p-5 rounded-3xl border border-white/10 flex flex-col items-center">
                              <div className="h-16 w-16 rounded-full bg-gradient-to-tr from-[#FF9800] to-[#FF6D00] flex items-center justify-center text-white text-xl font-black mb-3 shadow-lg shadow-orange-500/10">
                                ع
                              </div>
                              <h5 className="font-black text-sm text-white">علي حسين الحميري</h5>
                              <p className="text-[10px] text-slate-400 mt-0.5">صنعاء، اليمن</p>
                              
                              <div className="flex space-x-2 space-x-reverse mt-3">
                                <span className="bg-[#FF9800]/10 text-[#FF9800] border border-orange-500/20 px-2.5 py-0.5 rounded-full text-[10px] font-bold ml-2">كابتن معتمد</span>
                                <span className="bg-slate-800 text-slate-300 px-2.5 py-0.5 rounded-full text-[10px] font-bold">كابتن فضي</span>
                              </div>
                            </div>

                            {/* Vehicle detail specs card */}
                            <div className="bg-[#1A1D24] p-4 rounded-2xl border border-white/5 text-right space-y-3">
                              <h6 className="font-bold text-xs text-slate-400">معلومات الدراجة المسجلة</h6>
                              
                              <div className="grid grid-cols-2 gap-3 text-xs">
                                <div className="bg-black/20 p-2.5 rounded-xl border border-white/5">
                                  <p className="text-[9px] text-slate-400">نوع الدراجة</p>
                                  <p className="font-bold text-slate-200 mt-0.5">دراجة نارية</p>
                                </div>
                                <div className="bg-black/20 p-2.5 rounded-xl border border-white/5">
                                  <p className="text-[9px] text-slate-400">رقم اللوحة</p>
                                  <p className="font-bold text-slate-200 mt-0.5">77291 ص</p>
                                </div>
                              </div>
                            </div>

                            {/* Actions options link list */}
                            <div className="bg-[#1A1D24] rounded-2xl border border-white/5 overflow-hidden text-right text-xs">
                              <div className="p-3 border-b border-white/5 hover:bg-slate-800/40 cursor-pointer text-slate-200">الدعم الفني وشؤون الكباتن</div>
                              <div className="p-3 border-b border-white/5 hover:bg-slate-800/40 cursor-pointer text-slate-200">السياسات والقواعد القانونية</div>
                              <div 
                                onClick={() => {
                                  setSimulatorStep('phone');
                                  setRole('customer');
                                }}
                                className="p-3 hover:bg-red-500/10 cursor-pointer text-red-400 font-bold"
                              >
                                تسجيل الخروج من نظام الكباتن
                              </div>
                            </div>

                          </div>
                        )}

                      </div>

                      {/* Captain Bottom Navigation Bar matching all tabs */}
                      <div className="absolute bottom-5 inset-x-0 h-16 bg-[#1A1D24]/95 border-t border-white/10 flex items-center justify-around z-30">
                        {[
                          { id: 'home', icon: Navigation, label: 'الرئيسية' },
                          { id: 'trips', icon: CheckCircle, label: 'الرحلات' },
                          { id: 'earnings', icon: Sparkles, label: 'الأرباح' },
                          { id: 'notifications', icon: PhoneIcon, label: 'التنبيهات' },
                          { id: 'account', icon: User, label: 'الحساب' },
                        ].map((btn) => (
                          <button
                            key={btn.id}
                            type="button"
                            onClick={() => setCaptainTab(btn.id as any)}
                            className={`flex flex-col items-center justify-center flex-1 py-1 transition-all ${
                              captainTab === btn.id ? 'text-[#FF9800] scale-110 font-bold' : 'text-slate-400 hover:text-white'
                            }`}
                          >
                            <btn.icon className="h-4.5 w-4.5" />
                            <span className="text-[9px] mt-1 font-semibold">{btn.label}</span>
                          </button>
                        ))}
                      </div>

                    </div>
                  )}

                  {/* Home Indicator */}
                  <div className="absolute bottom-1 inset-x-0 h-5 flex justify-center items-center pointer-events-none z-50">
                    <div className="w-32 h-1 bg-slate-700 rounded-full"></div>
                  </div>

                </div>
              </div>
            </div>

          </div>
        )}

        {/* ====================================================================
            TAB: FLUTTER CODE EXPORTER
            ==================================================================== */}
        {activeTab === 'code' && (
          <div className="space-y-6 animate-fade-in">
            <div className={`p-5 rounded-3xl border flex flex-col md:flex-row md:items-center justify-between ${isDarkMode ? 'bg-gray-900/60 border-gray-800' : 'bg-slate-100 border-slate-200'}`}>
              <div>
                <h3 className="font-bold text-base mb-1">Boilerplate Exporter Hub</h3>
                <p className="text-xs text-slate-400">All authentication and ride state management files are written to the codebase with zero placeholders.</p>
              </div>
              <div className="mt-4 md:mt-0">
                <span className="bg-orange-500/10 text-orange-400 text-[11px] px-3 py-1.5 rounded-xl border border-orange-500/20 font-bold font-mono">
                  CLEAN ARCHITECTURE + BLOC V2
                </span>
              </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
              
              {/* Sidebar file list */}
              <div className="lg:col-span-1 space-y-2 max-h-[580px] overflow-y-auto pr-1">
                <h4 className="text-xs font-bold uppercase text-slate-500 tracking-wider mb-2 pl-2">Ride & Parcel (New)</h4>
                {['rideEvents', 'rideStates', 'rideBloc', 'dashboard', 'ratingDialog', 'tripHistory', 'supportTickets'].map((key) => (
                  <button
                    key={key}
                    onClick={() => setActiveCodeTab(key)}
                    className={`w-full text-left p-3 rounded-xl border transition-all flex items-center justify-between ${
                      activeCodeTab === key 
                        ? 'bg-orange-500/10 border-orange-500 text-orange-400' 
                        : `border-transparent ${isDarkMode ? 'bg-gray-900/40 text-slate-400 hover:text-white hover:bg-gray-800' : 'bg-white hover:bg-slate-100 text-slate-700'}`
                    }`}
                  >
                    <div className="truncate">
                      <p className="font-bold text-xs truncate">{codeFiles[key]?.name}</p>
                      <p className="text-[10px] opacity-70 font-mono mt-0.5 truncate">{codeFiles[key]?.path}</p>
                    </div>
                  </button>
                ))}

                <h4 className="text-xs font-bold uppercase text-slate-500 tracking-wider mb-2 mt-4 pl-2">Captain Flow (New)</h4>
                {['captainEvents', 'captainStates', 'captainBloc', 'tripRequestDialog', 'captainHomePage', 'captainNavigationPage', 'captainEarningsPage', 'captainNotifications', 'captainAccount'].map((key) => (
                  <button
                    key={key}
                    onClick={() => setActiveCodeTab(key)}
                    className={`w-full text-left p-3 rounded-xl border transition-all flex items-center justify-between ${
                      activeCodeTab === key 
                        ? 'bg-orange-500/10 border-orange-500 text-orange-400' 
                        : `border-transparent ${isDarkMode ? 'bg-gray-900/40 text-slate-400 hover:text-white hover:bg-gray-800' : 'bg-white hover:bg-slate-100 text-slate-700'}`
                    }`}
                  >
                    <div className="truncate">
                      <p className="font-bold text-xs truncate">{codeFiles[key]?.name}</p>
                      <p className="text-[10px] opacity-70 font-mono mt-0.5 truncate">{codeFiles[key]?.path}</p>
                    </div>
                  </button>
                ))}

                <h4 className="text-xs font-bold uppercase text-slate-500 tracking-wider mb-2 mt-4 pl-2">Auth State Management</h4>
                {['authEvents', 'authStates', 'authBloc'].map((key) => (
                  <button
                    key={key}
                    onClick={() => setActiveCodeTab(key)}
                    className={`w-full text-left p-3 rounded-xl border transition-all flex items-center justify-between ${
                      activeCodeTab === key 
                        ? 'bg-orange-500/10 border-orange-500 text-orange-400' 
                        : `border-transparent ${isDarkMode ? 'bg-gray-900/40 text-slate-400 hover:text-white hover:bg-gray-800' : 'bg-white hover:bg-slate-100 text-slate-700'}`
                    }`}
                  >
                    <div className="truncate">
                      <p className="font-bold text-xs truncate">{codeFiles[key].name}</p>
                      <p className="text-[10px] opacity-70 font-mono mt-0.5 truncate">{codeFiles[key].path}</p>
                    </div>
                  </button>
                ))}

                <h4 className="text-xs font-bold uppercase text-slate-500 tracking-wider mb-2 mt-4 pl-2">Branding & Layout Core</h4>
                {['colors', 'spacing', 'theme', 'glass'].map((key) => (
                  <button
                    key={key}
                    onClick={() => setActiveCodeTab(key)}
                    className={`w-full text-left p-3 rounded-xl border transition-all flex items-center justify-between ${
                      activeCodeTab === key 
                        ? 'bg-orange-500/10 border-orange-500 text-orange-400' 
                        : `border-transparent ${isDarkMode ? 'bg-gray-900/40 text-slate-400 hover:text-white hover:bg-gray-800' : 'bg-white hover:bg-slate-100 text-slate-700'}`
                    }`}
                  >
                    <div className="truncate">
                      <p className="font-bold text-xs truncate">{codeFiles[key].name}</p>
                      <p className="text-[10px] opacity-70 font-mono mt-0.5 truncate">{codeFiles[key].path}</p>
                    </div>
                  </button>
                ))}
              </div>

              {/* Code viewer pane */}
              <div className="lg:col-span-3">
                <div className={`rounded-3xl border overflow-hidden ${isDarkMode ? 'bg-gray-950 border-gray-800' : 'bg-slate-900 text-slate-100 border-slate-800'}`}>
                  
                  {/* Code header bar */}
                  <div className="bg-black/40 px-5 py-3 border-b border-gray-800 flex items-center justify-between">
                    <div className="truncate pr-4">
                      <span className="font-bold text-sm text-slate-200">{codeFiles[activeCodeTab]?.name}</span>
                      <span className="hidden md:inline-block text-[10px] text-slate-500 ml-3 font-mono">/{codeFiles[activeCodeTab]?.path}</span>
                    </div>
                    <button
                      onClick={() => copyToClipboard(codeFiles[activeCodeTab].code, activeCodeTab)}
                      className="flex items-center space-x-1.5 bg-orange-500/10 hover:bg-orange-500 text-orange-400 hover:text-white px-3 py-1.5 rounded-xl text-xs font-bold transition-all border border-orange-500/20 shrink-0"
                    >
                      {copied === activeCodeTab ? (
                        <>
                          <Check className="h-3.5 w-3.5" />
                          <span>Copied!</span>
                        </>
                      ) : (
                        <>
                          <Copy className="h-3.5 w-3.5" />
                          <span>Copy Code</span>
                        </>
                      )}
                    </button>
                  </div>

                  {/* Code editor body */}
                  <div className="p-5 overflow-x-auto font-mono text-[11px] leading-relaxed max-h-[500px] overflow-y-auto">
                    <pre className="text-[#A9B1D6]">
                      <code className="block whitespace-pre text-left" dir="ltr">
                        {codeFiles[activeCodeTab]?.code}
                      </code>
                    </pre>
                  </div>
                </div>
              </div>

            </div>
          </div>
        )}

        {/* ====================================================================
            TAB: TOKENS DEFINITION
            ==================================================================== */}
        {activeTab === 'tokens' && (
          <div className="space-y-8 animate-fade-in">
            {/* Color section summary */}
            <div className={`p-6 rounded-3xl border ${isDarkMode ? 'bg-[#1A1D24] border-gray-800' : 'bg-white border-slate-200'}`}>
              <h3 className="font-bold text-lg mb-4 flex items-center">
                <Palette className="h-5 w-5 ml-2 text-orange-500" />
                <span>ألوان الهوية والبراند (Yemeni Orange & Accent Palette)</span>
              </h3>
              <div className="grid grid-cols-2 sm:grid-cols-5 gap-4">
                <div className="p-3.5 rounded-2xl bg-[#FF9800] text-white shadow-lg">
                  <p className="font-black text-sm">Primary 500</p>
                  <p className="font-mono text-xs mt-0.5">#FF9800</p>
                  <span className="text-[10px] opacity-95">Core Orange</span>
                </div>
                <div className="p-3.5 rounded-2xl bg-[#E65100] text-white">
                  <p className="font-black text-sm">Primary 900</p>
                  <p className="font-mono text-xs mt-0.5">#E65100</p>
                  <span className="text-[10px] opacity-95">Anchor Brown</span>
                </div>
                <div className="p-3.5 rounded-2xl bg-[#22C55E] text-white">
                  <p className="font-black text-sm">Success</p>
                  <p className="font-mono text-xs mt-0.5">#22C55E</p>
                  <span className="text-[10px] opacity-95">منجز / مكتمل</span>
                </div>
                <div className="p-3.5 rounded-2xl bg-[#EF4444] text-white">
                  <p className="font-black text-sm">Danger</p>
                  <p className="font-mono text-xs mt-0.5">#EF4444</p>
                  <span className="text-[10px] opacity-95">إلغاء / فشل</span>
                </div>
                <div className="p-3.5 rounded-2xl bg-[#3B82F6] text-white">
                  <p className="font-black text-sm">Info Accent</p>
                  <p className="font-mono text-xs mt-0.5">#3B82F6</p>
                  <span className="text-[10px] opacity-95">بوابات / خرائط</span>
                </div>
              </div>
            </div>

            {/* Grid & spacing summary */}
            <div className={`p-6 rounded-3xl border ${isDarkMode ? 'bg-[#1A1D24] border-gray-800' : 'bg-white border-slate-200'}`}>
              <h3 className="font-bold text-lg mb-4 flex items-center">
                <Ruler className="h-5 w-5 ml-2 text-orange-500" />
                <span>نظام التباعد والمسافات (Strict 8pt Layout Grid)</span>
              </h3>
              <p className="text-xs text-slate-400 mb-4">
                We enforce pre-defined double constants for padding, margins, and gaps to ensure strict visual rhythm on Android, iPhone, and Tablets.
              </p>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-xs">
                <div className="p-4 rounded-xl bg-black/15 border border-white/5">
                  <p className="font-bold text-orange-500">AppSpacing.s8 (8.0)</p>
                  <span className="text-slate-400 text-[11px]">List element gaps</span>
                </div>
                <div className="p-4 rounded-xl bg-black/15 border border-white/5">
                  <p className="font-bold text-orange-500">AppSpacing.s16 (16.0)</p>
                  <span className="text-slate-400 text-[11px]">Card inner padding</span>
                </div>
                <div className="p-4 rounded-xl bg-black/15 border border-white/5">
                  <p className="font-bold text-orange-500">AppSpacing.s24 (24.0)</p>
                  <span className="text-slate-400 text-[11px]">Screen boundary margin</span>
                </div>
                <div className="p-4 rounded-xl bg-black/15 border border-white/5">
                  <p className="font-bold text-orange-500">AppSpacing.s32 (32.0)</p>
                  <span className="text-slate-400 text-[11px]">Bottom sheet top corner radius</span>
                </div>
              </div>
            </div>
          </div>
        )}

      </main>
    </div>
  );
}
