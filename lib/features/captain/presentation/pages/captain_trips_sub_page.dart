import '../../../../l10n/app_localizations.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/trips/captain_trips_bloc.dart';
import '../bloc/trips/captain_trips_event.dart';
import '../bloc/trips/captain_trips_state.dart';
import '../../domain/entities/captain_trip_entity.dart';
import 'widgets/captain_trip_details_sheet.dart';

/// CaptainTripsSubPage - Premium Interactive Sub-Page for Captain's Trip History.
/// Features: Real-time search, animated Glassmorphism filters, Shimmer loading,
/// interactive micro-animations, animated empty state, and modern timeline trip cards.
class CaptainTripsSubPage extends StatefulWidget {
  const CaptainTripsSubPage({super.key});

  @override
  State<CaptainTripsSubPage> createState() => _CaptainTripsSubPageState();
}

class _CaptainTripsSubPageState extends State<CaptainTripsSubPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late CaptainTripsBloc _tripsBloc;

  String _searchQuery = '';
  String _selectedStatusFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _tripsBloc = sl<CaptainTripsBloc>();
    _tripsBloc.add(const FetchCaptainTrips(isRefresh: true));

    _scrollController.addListener(_onScroll);
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
    _tripsBloc.close();
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
                                color: Color(0xFFFF6B00)),
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
                    color: const Color(0xFFFF6B00),
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
                                    color: Color(0xFFFF6B00))),
                          );
                        }
                        final trip = filtered[index];
                        return _AnimatedTripCard(
                            tripEntity: trip, isDark: isDark);
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
          baseColor: isDark ? Colors.grey[900]! : Colors.grey[200]!,
          highlightColor: isDark ? Colors.grey[850]! : Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.s12),
            height: 160,
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
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
    final chipColor = color ?? const Color(0xFFFF6B00);

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

  const _AnimatedTripCard({required this.tripEntity, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final trip = tripEntity.toMap();
    final String status = trip['status'];
    final Color statusColor = trip['statusColor'];

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
            // ── Row 1: ID & Status ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B00).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long_rounded,
                          size: 14, color: Color(0xFFFF6B00)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.capt_trip_number_id(trip['id']),
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? AppColors.gray300 : AppColors.gray800,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
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
                        trip['pickup'],
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
                        trip['dropoff'],
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

            // ── Footer: Passenger Name, Price & Date ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor:
                          isDark ? Colors.white12 : AppColors.gray200,
                      child: const Icon(Icons.person_rounded,
                          size: 14, color: AppColors.gray500),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      trip['passengerName'],
                      style: TextStyle(
                        fontSize: 11.5,
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
                      trip['price'],
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFFFF6B00),
                        fontWeight: FontWeight.w900,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                    Text(
                      trip['date'],
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
                      color: const Color(0xFFFF6B00).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B00).withValues(
                              alpha: 0.15 * (_scaleAnimation.value - 0.95)),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: const Icon(Icons.search_off_rounded,
                        size: 54, color: Color(0xFFFF6B00)),
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
                      colors: [Color(0xFFFF8C00), Color(0xFFFF6B00)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
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
