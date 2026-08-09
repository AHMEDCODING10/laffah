import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/profile_bloc.dart';
import '../../presentation/bloc/profile_state.dart';
import '../../presentation/bloc/profile_event.dart';
import '../../domain/entities/saved_place_entity.dart';
import '../../data/models/saved_place_model.dart';
import '../widgets/saved_places/add_edit_place_dialog.dart';
import '../widgets/saved_places/saved_place_card.dart';

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
      placeToEdit: placeToEdit as SavedPlaceModel?,
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
                  ? 'تم تحديث المكان المحفوظ بنجاح'
                  : 'تمت إضافة المكان إلى المحفوظات بنجاح',
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
            ),
            backgroundColor: AppColors.primary500,
          ),
        );
      },
    );
  }

  void _deletePlace(String id) {
    setState(() {
      _savedPlaces.removeWhere((p) => p.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم حذف المكان من المحفوظات',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
        ),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'الأماكن المحفوظة',
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
          icon: const Icon(Icons.add_location_alt_rounded, color: AppColors.white),
          label: const Text(
            'إضافة مكان جديد',
            style: TextStyle(
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
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 13,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                    decoration: InputDecoration(
                      hintText: 'البحث بداخل الأماكن المحفوظة...',
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
                  _buildCategoryFilterPills(isDark),
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
                  if (state is ProfileLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (_filteredPlaces.isEmpty) {
                    return _buildEmptyState(isDark);
                  }
                  
                  return ListView.builder(
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
                        place: place as SavedPlaceModel, // Casting to model since the card might expect it
                        onBookNow: () => _onBookToPlace(place),
                        onEdit: () => _showAddEditDialog(place),
                        onDelete: () => _deletePlace(place.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterPills(bool isDark) {
    final categories = [
      {'label': 'الكل', 'type': null},
      {'label': 'المنزل', 'type': 'home'},
      {'label': 'العمل', 'type': 'work'},
      {'label': 'الجامعة', 'type': 'university'},
      {'label': 'تسوق', 'type': 'shopping'},
      {'label': 'تاريخي', 'type': 'historic'},
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

  Widget _buildEmptyState(bool isDark) {
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
            'لا توجد أماكن محفوظة تطابق البحث',
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
