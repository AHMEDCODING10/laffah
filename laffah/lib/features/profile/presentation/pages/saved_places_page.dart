import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../bloc/profile_event.dart';
import '../../domain/entities/saved_place_entity.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../widgets/saved_places/add_edit_place_dialog.dart';
import '../widgets/saved_places/saved_place_card.dart';
import '../../../../l10n/app_localizations.dart';

/// SavedPlacesPage — Refactored Saved Destinations & Quick Booking Interface for Laffah Passengers.
/// Reduced from 1,357 monolithic lines to modular Clean Code composition.
class SavedPlacesPage extends StatefulWidget {
  const SavedPlacesPage({super.key});

  @override
  State<SavedPlacesPage> createState() => _SavedPlacesPageState();
}

class _SavedPlacesPageState extends State<SavedPlacesPage> {
  List<SavedPlaceEntity> _savedPlaces = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(GetSavedPlacesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SavedPlaceEntity> get _filteredPlaces {
    return _savedPlaces.where((place) {
      final matchesSearch = place.name.contains(_searchQuery) ||
          place.address.contains(_searchQuery);
      final matchesCategory = _selectedCategoryFilter == null ||
          place.type == _selectedCategoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _onBookToPlace(SavedPlaceEntity place) {
    context.push(
      LaffahRoutes.passengerHome,
      extra: {
        'dropoff': place.name,
        'lat': place.lat,
        'lng': place.lng,
      },
    );
  }

  void _showAddEditDialog([SavedPlaceEntity? placeToEdit]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    AddEditPlaceDialog.show(
      context: context,
      isDark: isDark,
      placeToEdit: placeToEdit,
      onSave: (savedModel) {
        context.read<ProfileBloc>().add(AddSavedPlaceEvent(savedModel));
        setState(() {
          final index = _savedPlaces.indexWhere((p) => p.id == savedModel.id);
          if (index != -1) {
            _savedPlaces[index] = savedModel;
          } else {
            _savedPlaces.insert(0, savedModel);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              placeToEdit != null
                  ? AppLocalizations.of(context)!.pass_places_updated
                  : AppLocalizations.of(context)!.pass_places_added,
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
            ),
            backgroundColor: AppColors.primary500,
          ),
        );
      },
    );
  }

  Future<void> _deletePlace(String id) async {
    setState(() {
      _savedPlaces.removeWhere((p) => p.id == id);
    });

    try {
      final dioClient = di.sl<DioClient>();
      await dioClient.dio.delete('${ApiEndpoints.savedPlaces}/$id');
    } catch (e) {
      debugPrint('⚠️ [SavedPlacesPage] Error deleting saved place: $e');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.pass_places_deleted,
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
        ),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            AppLocalizations.of(context)!.pass_places_title,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddEditDialog(),
          backgroundColor: AppColors.primary500,
          icon: const Icon(Icons.add_location_alt_rounded,
              color: AppColors.white),
          label: Text(
            AppLocalizations.of(context)!.pass_places_add_new,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
        body: Column(
          children: [
            // Search & Filter Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.trim()),
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 13,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.pass_places_search,
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.primary500),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.white.withValues(alpha: 0.03)
                          : AppColors.gray100,
                      contentPadding: const EdgeInsets.all(AppSpacing.s12),
                      border: const OutlineInputBorder(
                        borderRadius: AppSpacing.radiusMD,
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  AppSpacing.h12,
                  _buildCategoryFilterPills(isDark, context),
                ],
              ),
            ),

            // Places List View
            Expanded(
              child: BlocConsumer<ProfileBloc, ProfileState>(
                listener: (context, state) {
                  if (state is SavedPlacesLoaded) {
                    setState(() {
                      _savedPlaces = state.places;
                    });
                  } else if (state is SavedPlaceAdded) {
                    context.read<ProfileBloc>().add(GetSavedPlacesEvent());
                  }
                },
                builder: (context, state) {
                  // Show loader while actively fetching
                  if (state is ProfileLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Show loader if we haven't received places data yet
                  // (e.g. bloc is in ProfileInitial or ProfileLoaded from a prior getProfile call)
                  if (state is! SavedPlacesLoaded && state is! ProfileError && _savedPlaces.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ProfileError && _savedPlaces.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.gray400),
                          AppSpacing.h12,
                          Text(
                            'تعذّر تحميل الأماكن المحفوظة',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 14,
                              color: isDark ? AppColors.gray400 : AppColors.gray600,
                            ),
                          ),
                          AppSpacing.h12,
                          TextButton(
                            onPressed: () => context.read<ProfileBloc>().add(GetSavedPlacesEvent()),
                            child: const Text(
                              'إعادة المحاولة',
                              style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', color: AppColors.primary500),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_filteredPlaces.isEmpty) {
                    return _buildEmptyState(isDark, context);
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ProfileBloc>().add(GetSavedPlacesEvent());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s16,
                        0,
                        AppSpacing.s16,
                        96,
                      ),
                      itemCount: _filteredPlaces.length,
                      itemBuilder: (context, index) {
                        final place = _filteredPlaces[index];
                        return SavedPlaceCard(
                          isDark: isDark,
                          place: place,
                          onBookNow: () => _onBookToPlace(place),
                          onEdit: () => _showAddEditDialog(place),
                          onDelete: () => _deletePlace(place.id),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildCategoryFilterPills(bool isDark, BuildContext context) {
    final categories = [
      {'label': AppLocalizations.of(context)!.pass_places_all, 'type': null},
      {'label': AppLocalizations.of(context)!.pass_places_home, 'type': 'home'},
      {'label': AppLocalizations.of(context)!.pass_places_work, 'type': 'work'},
      {'label': AppLocalizations.of(context)!.pass_places_uni, 'type': 'university'},
      {'label': AppLocalizations.of(context)!.pass_places_shopping, 'type': 'shopping'},
      {'label': AppLocalizations.of(context)!.pass_places_historic, 'type': 'historic'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategoryFilter == cat['type'];
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(
                cat['label'] as String,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.white
                      : (isDark ? AppColors.gray300 : AppColors.gray700),
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary500,
              backgroundColor: isDark
                  ? AppColors.white.withValues(alpha: 0.05)
                  : AppColors.gray100,
              onSelected: (val) {
                setState(() {
                  _selectedCategoryFilter = val ? cat['type'] : null;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const GlassBox(
            borderRadius: AppSpacing.radiusFull,
            padding: EdgeInsets.all(AppSpacing.s20),
            child: Icon(
              Icons.bookmark_border_rounded,
              size: 48,
              color: AppColors.gray400,
            ),
          ),
          AppSpacing.h16,
          Text(
            AppLocalizations.of(context)!.pass_places_empty,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
