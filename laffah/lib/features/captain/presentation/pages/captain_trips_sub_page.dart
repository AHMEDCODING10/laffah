import '../../../../l10n/app_localizations.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/trips/captain_trips_bloc.dart';
import '../bloc/trips/captain_trips_event.dart';
import '../bloc/trips/captain_trips_state.dart';
import '../../domain/entities/captain_trip_entity.dart';
import 'widgets/captain_trip_details_sheet.dart';

/// CaptainTripsSubPage - Premium Interactive Sub-Page for Captain's Trip History.
/// Features: Real-time search, animated Glassmorphism filters, Shimmer loading,
/// interactive micro-animations, animated empty state, and modern timeline trip cards.
class CaptainTripsSubPage extends StatefulWidget {
  final CaptainTripsBloc? tripsBloc;
  const CaptainTripsSubPage({super.key, this.tripsBloc});

  @override
  State<CaptainTripsSubPage> createState() => _CaptainTripsSubPageState();
}

class _CaptainTripsSubPageState extends State<CaptainTripsSubPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late CaptainTripsBloc _tripsBloc;
  bool _isLocalBloc = false;

  String _searchQuery = '';
  String _selectedStatusFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    if (widget.tripsBloc != null) {
      _tripsBloc = widget.tripsBloc!;
      _isLocalBloc = false;
    } else {
      _tripsBloc = di.sl<CaptainTripsBloc>();
      _isLocalBloc = true;
      _tripsBloc.add(const FetchCaptainTrips(isRefresh: true));
    }

    _scrollController.addListener(_onScroll);
  }

  Future<void> _handleDeleteTrip(BuildContext context, String tripId) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B26) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.gray200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'حذف السجل',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'هل أنت متأكد من رغبتك في حذف هذا السجل نهائياً؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 13,
                      height: 1.6,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 1. Delete Button (Red, Full Width)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'تأكيد الحذف',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 2. Cancel Button (Underneath)
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(false),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'إلغاء والتراجع',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        final dio = di.sl<DioClient>().dio;
        await dio.delete('/trips/$tripId');
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('تم حذف السجل بنجاح.',
                  style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
            ),
          );
          _tripsBloc.add(FetchCaptainTrips(
              isRefresh: true, statusFilter: _selectedStatusFilter));
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.danger,
              content: Text('حدث خطأ أثناء الحذف.',
                  style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
            ),
          );
        }
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_tripsBloc.state is CaptainTripsLoaded) {
        final state = _tripsBloc.state as CaptainTripsLoaded;
        if (!state.hasReachedMax) {
          _tripsBloc
              .add(FetchCaptainTrips(statusFilter: _selectedStatusFilter));
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    if (_isLocalBloc) {
      _tripsBloc.close();
    }
    super.dispose();
  }

  List<CaptainTripEntity> _getFilteredTrips(List<CaptainTripEntity> trips) {
    if (_searchQuery.trim().isEmpty) return trips;

    final query = _searchQuery.trim().toLowerCase();
    return trips.where((trip) {
      final id = trip.id.toLowerCase();
      final passenger = trip.passengerName.toLowerCase();
      final pickup = trip.pickup.toLowerCase();
      final dropoff = trip.dropoff.toLowerCase();

      return id.contains(query) ||
          passenger.contains(query) ||
          pickup.contains(query) ||
          dropoff.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.capt_trip_history_title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'IBM Plex Sans Arabic',
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // ── Premium Glassmorphism Search & Filters ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Column(
                children: [
                  // Search TextField with Glass Effect
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF141822).withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 13.5,
                            color: isDark ? Colors.white : AppColors.gray900,
                          ),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context)!.capt_trip_search_hint,
                            hintStyle: const TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 12.5,
                              color: AppColors.gray500,
                            ),
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: AppColors.primary500),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded,
                                        size: 18, color: AppColors.gray500),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.h12,

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip(
                            AppLocalizations.of(context)!.capt_all, _selectedStatusFilter == 'الكل', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip(AppLocalizations.of(context)!.capt_trip_in_progress,
                            _selectedStatusFilter == 'قيد التنفيذ', isDark,
                            color: AppColors.warning),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            AppLocalizations.of(context)!.capt_trip_done,
                            _selectedStatusFilter ==
                                AppLocalizations.of(context)!.capt_trip_done,
                            isDark,
                            color: AppColors.success),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            AppLocalizations.of(context)!.capt_trip_cancelled, _selectedStatusFilter == 'ملغاة', isDark,
                            color: AppColors.danger),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.h16,

            // ── Trips List or Shimmer or Empty View ──
            Expanded(
              child: BlocBuilder<CaptainTripsBloc, CaptainTripsState>(
                bloc: _tripsBloc,
                builder: (context, state) {
                  if (state is CaptainTripsInitial ||
                      (state is CaptainTripsLoading && state.isFirstFetch)) {
                    return _buildShimmerLoading(isDark);
                  }

                  if (state is CaptainTripsError) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)!.capt_trip_err_msg(state.message),
                        style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            color: AppColors.danger),
                      ),
                    );
                  }

                  List<CaptainTripEntity> trips = [];
                  bool isLoadingMore = false;

                  if (state is CaptainTripsLoaded) {
                    trips = state.trips;
                  } else if (state is CaptainTripsLoading) {
                    trips = state.oldTrips;
                    isLoadingMore = true;
                  }

                  final filtered = _getFilteredTrips(trips);

                  if (filtered.isEmpty) {
                    return _AnimatedEmptyState(
                      isDark: isDark,
                      onClear: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _selectedStatusFilter = 'الكل';
                        });
                        _tripsBloc.add(const FetchCaptainTrips(
                            statusFilter: 'الكل', isRefresh: true));
                      },
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary500,
                    onRefresh: () async {
                      _tripsBloc.add(FetchCaptainTrips(
                          isRefresh: true,
                          statusFilter: _selectedStatusFilter));
                      await _tripsBloc.stream
                          .firstWhere((s) => s is! CaptainTripsLoading);
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: filtered.length + (isLoadingMore ? 1 : 0),
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      itemBuilder: (context, index) {
                        if (index == filtered.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.primary500)),
                          );
                        }
                        final trip = filtered[index];
                        return _AnimatedTripCard(
                          tripEntity: trip,
                          isDark: isDark,
                          onDelete: () => _handleDeleteTrip(context, trip.id),
                        );
                      },
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

  // ── Shimmer Skeleton Loader ──
  Widget _buildShimmerLoading(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: 6,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? const Color(0xFF1E2433) : AppColors.gray200,
          highlightColor: isDark ? const Color(0xFF283044) : AppColors.gray100,
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.s12),
            height: 140,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2433) : Colors.white,
              borderRadius: AppSpacing.radiusLG,
            ),
          ),
        );
      },
    );
  }

  // ── Micro-animated Filter Chip ──
  Widget _buildFilterChip(String label, bool isSelected, bool isDark,
      {Color? color}) {
    final chipColor = color ?? AppColors.primary500;

    return _ScaleButton(
      onTap: () {
        HapticFeedback.selectionClick();
        if (_selectedStatusFilter != label) {
          setState(() => _selectedStatusFilter = label);
          _tripsBloc
              .add(FetchCaptainTrips(statusFilter: label, isRefresh: true));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutExpo,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.12)
              : (isDark
                  ? const Color(0xFF1A1F2B)
                  : AppColors.gray100.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? chipColor.withValues(alpha: 0.5)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.gray200),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
            color: isSelected
                ? chipColor
                : (isDark ? AppColors.gray400 : AppColors.gray600),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Trip Card with Timeline
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedTripCard extends StatelessWidget {
  final CaptainTripEntity tripEntity;
  final bool isDark;
  final VoidCallback? onDelete;

  const _AnimatedTripCard({
    required this.tripEntity,
    required this.isDark,
    this.onDelete,
  });

  String _getArabicStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'finished':
      case 'مكتملة':
      case 'تم الانتهاء':
        return 'مكتملة';
      case 'delivered':
      case 'تم التسليم':
        return 'تم التسليم';
      case 'cancelled':
      case 'canceled':
      case 'ملغاة':
      case 'ملغية':
        return 'ملغاة';
      case 'in_transit':
      case 'picked_up':
      case 'arrived_at_pickup':
      case 'arrived':
      case 'active':
      case 'قيد التنفيذ':
      case 'جارية':
      case 'نشطة':
        return 'قيد التنفيذ';
      default:
        return status;
    }
  }

  Color _getStatusColor(String arabicStatus) {
    switch (arabicStatus) {
      case 'مكتملة':
      case 'تم التسليم':
        return AppColors.success;
      case 'ملغاة':
        return AppColors.danger;
      case 'قيد التنفيذ':
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = tripEntity.toMap();
    final bool isParcel = tripEntity.isParcel;
    final String rawStatus = trip['status'] ?? '';
    final String arabicStatus = _getArabicStatus(rawStatus);
    final Color statusColor = _getStatusColor(arabicStatus);
    final bool canDelete = arabicStatus == 'مكتملة' ||
        arabicStatus == 'تم التسليم' ||
        arabicStatus == 'ملغاة';

    return _ScaleButton(
      onTap: () {
        HapticFeedback.lightImpact();
        CaptainTripDetailsSheet.show(context, trip);
      },
      child: GlassBox(
        margin: const EdgeInsets.only(bottom: AppSpacing.s12),
        borderRadius: AppSpacing.radiusLG,
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Type / ID & Arabic Status & Delete ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (isParcel
                                ? const Color(0xFF3B82F6)
                                : AppColors.primary500)
                            .withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isParcel
                            ? Icons.inventory_2_rounded
                            : Icons.motorcycle_rounded,
                        size: 15,
                        color: isParcel
                            ? const Color(0xFF3B82F6)
                            : AppColors.primary500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isParcel
                          ? 'توصيل طرد #${trip['id']} 📦'
                          : 'مشوار رحلة #${trip['id']} 🛵',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.gray200 : AppColors.gray900,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        arabicStatus,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ),
                    if (canDelete && onDelete != null) ...[
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.danger.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            AppSpacing.h12,

            // ── Timeline UI: Pickup to Dropoff ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Right side: Icons and Dashed Line (RTL)
                Column(
                  children: [
                    const Icon(Icons.trip_origin_rounded,
                        size: 14, color: Color(0xFF4CAF50)),
                    CustomPaint(
                      size: const Size(2, 22),
                      painter: _DashedLinePainter(
                          color: isDark ? Colors.white30 : AppColors.gray300),
                    ),
                    const Icon(Icons.location_on_rounded,
                        size: 14, color: Color(0xFFF44336)),
                  ],
                ),
                const SizedBox(width: 10),
                // Left side: Addresses
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip['pickup'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.gray900,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        trip['dropoff'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.gray900,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),

            // ── Footer: Passenger/Sender Name, Price & Date ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isParcel
                          ? const Color(0xFF3B82F6).withValues(alpha: 0.12)
                          : (isDark ? Colors.white12 : AppColors.gray200),
                      child: Icon(
                        isParcel
                            ? Icons.inventory_2_outlined
                            : Icons.person_rounded,
                        size: 14,
                        color: isParcel
                            ? const Color(0xFF3B82F6)
                            : AppColors.gray500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isParcel
                          ? 'المرسل: ${trip['passengerName']}'
                          : 'الراكب: ${trip['passengerName']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: isDark ? AppColors.gray300 : AppColors.gray700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      trip['price'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.primary500,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                    Text(
                      trip['date'] ?? '',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.gray500,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Empty State (Breathing Search Icon)
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedEmptyState extends StatefulWidget {
  final bool isDark;
  final VoidCallback onClear;
  const _AnimatedEmptyState({required this.isDark, required this.onClear});

  @override
  State<_AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<_AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary500.withValues(
                              alpha: 0.15 * (_scaleAnimation.value - 0.95)),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: const Icon(Icons.search_off_rounded,
                        size: 54, color: AppColors.primary500),
                  ),
                );
              },
            ),
            AppSpacing.h20,
            Text(
              AppLocalizations.of(context)!.capt_trip_no_results_title,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                color: widget.isDark ? Colors.white : AppColors.gray900,
              ),
            ),
            AppSpacing.h8,
            Text(
              AppLocalizations.of(context)!.capt_trip_no_results_desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12.5,
                color: AppColors.gray500,
              ),
            ),
            AppSpacing.h24,
            _ScaleButton(
              onTap: widget.onClear,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFF8C00), AppColors.primary500]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  AppLocalizations.of(context)!.capt_trip_show_all,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Scale Button for Micro-Animations
// ─────────────────────────────────────────────────────────────────────────────
class _ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ScaleButton({required this.child, required this.onTap});

  @override
  State<_ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<_ScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashed Line Painter for Timeline
// ─────────────────────────────────────────────────────────────────────────────
class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    var max = size.height;
    var dashWidth = 4.0;
    var dashSpace = 3.0;
    double startY = 0;

    while (startY < max) {
      canvas.drawLine(Offset(size.width / 2, startY),
          Offset(size.width / 2, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
