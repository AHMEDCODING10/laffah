import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/trips/captain_trips_bloc.dart';
import '../bloc/trips/captain_trips_event.dart';
import '../bloc/trips/captain_trips_state.dart';
import '../../domain/entities/captain_trip_entity.dart';
import 'widgets/captain_trip_details_sheet.dart';

/// CaptainTripsSubPage - Interactive Sub-Page for Captain's Trip History & Active Orders.
/// Features instant real-time search filtering, status filter chips, authentic Sana'a locations,
/// and rich trip detail bottom sheets.
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_tripsBloc.state is CaptainTripsLoaded) {
        final state = _tripsBloc.state as CaptainTripsLoaded;
        if (!state.hasReachedMax) {
          _tripsBloc.add(FetchCaptainTrips(statusFilter: _selectedStatusFilter));
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
          'سجل الرحلات والمشاوير',
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
            // Search & Filter Header Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Column(
                children: [
                  // Functional Real-time Search TextField
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141822).withValues(alpha: 0.8)
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.gray200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
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
                        hintText: 'ابحث برقم الرحلة، اسم الراكب، أو الشارع...',
                        hintStyle: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12.5,
                          color: AppColors.gray500,
                        ),
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFF6B00)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.gray500),
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

                  AppSpacing.h12,

                  // Filter Chips Bar (All, In Progress, Completed, Cancelled)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('الكل', _selectedStatusFilter == 'الكل', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('قيد التنفيذ', _selectedStatusFilter == 'قيد التنفيذ', isDark, color: AppColors.warning),
                        const SizedBox(width: 8),
                        _buildFilterChip('تم الانتهاء', _selectedStatusFilter == 'تم الانتهاء', isDark, color: AppColors.success),
                        const SizedBox(width: 8),
                        _buildFilterChip('ملغاة', _selectedStatusFilter == 'ملغاة', isDark, color: AppColors.danger),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.h16,

            // Trips List or Empty Search View
            Expanded(
              child: BlocBuilder<CaptainTripsBloc, CaptainTripsState>(
                bloc: _tripsBloc,
                builder: (context, state) {
                  if (state is CaptainTripsInitial || (state is CaptainTripsLoading && state.isFirstFetch)) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)));
                  }

                  if (state is CaptainTripsError) {
                    return Center(
                      child: Text(
                        'حدث خطأ: ${state.message}',
                        style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', color: AppColors.danger),
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
                    return _buildEmptyState(isDark);
                  }

                  return RefreshIndicator(
                    color: const Color(0xFFFF6B00),
                    onRefresh: () async {
                      _tripsBloc.add(FetchCaptainTrips(isRefresh: true, statusFilter: _selectedStatusFilter));
                      // wait for state change
                      await _tripsBloc.stream.firstWhere((s) => s is! CaptainTripsLoading);
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90), // Extra space for floating bottom bar
                      itemCount: filtered.length + (isLoadingMore ? 1 : 0),
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      itemBuilder: (context, index) {
                        if (index == filtered.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00))),
                          );
                        }
                        final trip = filtered[index];
                        return _buildTripCard(context, trip, isDark);
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

  Widget _buildFilterChip(String label, bool isSelected, bool isDark, {Color? color}) {
    final chipColor = color ?? const Color(0xFFFF6B00);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (_selectedStatusFilter != label) {
          setState(() {
            _selectedStatusFilter = label;
          });
          _tripsBloc.add(FetchCaptainTrips(statusFilter: label, isRefresh: true));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.16)
              : (isDark ? const Color(0xFF141822).withValues(alpha: 0.5) : AppColors.gray100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? chipColor
                : (isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.gray200),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
            color: isSelected
                ? chipColor
                : (isDark ? AppColors.gray400 : AppColors.gray600),
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, CaptainTripEntity tripEntity, bool isDark) {
    final trip = tripEntity.toMap();
    final String status = trip['status'];
    final Color statusColor = trip['statusColor'];

    return GestureDetector(
      onTap: () => CaptainTripDetailsSheet.show(context, trip),
      child: GlassBox(
        margin: const EdgeInsets.only(bottom: AppSpacing.s12),
        borderRadius: AppSpacing.radiusLG,
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: ID & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, size: 16, color: Color(0xFFFF6B00)),
                    const SizedBox(width: 6),
                    Text(
                      'رقم الرحلة: ${trip['id']}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? AppColors.gray400 : AppColors.gray700,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withValues(alpha: 0.25)),
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

            // Passenger Name
            Row(
              children: [
                const Icon(Icons.person_rounded, size: 15, color: AppColors.gray500),
                const SizedBox(width: 6),
                Text(
                  'الراكب: ${trip['passengerName']}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: isDark ? Colors.white : AppColors.gray900,
                  ),
                ),
              ],
            ),

            AppSpacing.h8,

            // Route representation
            Row(
              children: [
                const Icon(Icons.circle_rounded, color: Colors.green, size: 12),
                AppSpacing.w10,
                Expanded(
                  child: Text(
                    trip['pickup'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Container(
                width: 1.5,
                height: 10,
                color: isDark ? Colors.white24 : AppColors.gray300,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 12),
                AppSpacing.w10,
                Expanded(
                  child: Text(
                    trip['dropoff'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),

            // Price, Date & Details Hint
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trip['price'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFF6B00),
                    fontWeight: FontWeight.w900,
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
                Row(
                  children: [
                    Text(
                      trip['date'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.gray500,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_back_ios_rounded, size: 12, color: AppColors.gray500),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Color(0xFFFF6B00),
              ),
            ),
            AppSpacing.h16,
            Text(
              'لا توجد رحلات مطابقة لبحثك',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.gray900,
              ),
            ),
            AppSpacing.h6,
            const Text(
              'جرّب البحث باسم آخر أو اختر "الكل" لإعادة عرض كافة الرحلات.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
            AppSpacing.h20,
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedStatusFilter = 'الكل';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'عرض كل الرحلات',
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
