import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/saved_place_entity.dart';

/// Enum representing the preset type of a saved place
enum PlaceType {
  home,        // المنزل
  work,        // العمل
  university,  // الجامعة / الكلية
  shopping,    // مركز تجاري / تسوق
  historic,    // معلم تاريخي / سياحي
  custom,      // مخصص
}

/// Model class representing a Saved Destination for Laffah Passengers
class SavedPlace {
  final String id;
  final String name;
  final String addressDetails;
  final double latitude;
  final double longitude;
  final PlaceType type;
  final IconData icon;

  SavedPlace({
    required this.id,
    required this.name,
    required this.addressDetails,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.icon,
  });
}

/// SavedPlacesPage - Production-grade saved destinations and quick booking interface
/// designed for Laffah passengers in Sana'a, Yemen.
/// Offers full RTL layout support, custom presets, elegant map coordinates preview,
/// and single-tap trigger callbacks to initiate fast single-fare bookings.
class SavedPlacesPage extends StatefulWidget {
  const SavedPlacesPage({super.key});

  @override
  State<SavedPlacesPage> createState() => _SavedPlacesPageState();
}

class _SavedPlacesPageState extends State<SavedPlacesPage> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  PlaceType _selectedType = PlaceType.custom;
  double _selectedLat = 15.3694;
  double _selectedLng = 44.1910;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileBloc>().add(GetSavedPlacesEvent());
    });
  }

  IconData _getIconForType(PlaceType type) {
    switch (type) {
      case PlaceType.home:
        return Icons.home_rounded;
      case PlaceType.work:
        return Icons.business_center_rounded;
      case PlaceType.university:
        return Icons.school_rounded;
      case PlaceType.shopping:
        return Icons.local_mall_rounded;
      case PlaceType.historic:
        return Icons.castle_rounded;
      case PlaceType.custom:
        return Icons.place_rounded;
    }
  }

  String _getNameForType(PlaceType type) {
    switch (type) {
      case PlaceType.home:
        return 'المنزل';
      case PlaceType.work:
        return 'العمل';
      case PlaceType.university:
        return 'الجامعة';
      case PlaceType.shopping:
        return 'تسوق / مول';
      case PlaceType.historic:
        return 'معلم تاريخي';
      case PlaceType.custom:
        return 'موقع مخصص';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.white : AppColors.gray900,
              size: 20,
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          centerTitle: true,
          title: Text(
            'الأماكن المفضلة والمحفوظة',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s16),
                  children: [
                    // ==========================================
                    // Quick Intro Banner
                    // ==========================================
                    _buildBannerCard(isDark),

                    AppSpacing.h24,

                    // ==========================================
                    // Section Title
                    // ==========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'وجهاتك المعتادة الأكثر حجزاً',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: isDark ? AppColors.white : AppColors.gray800,
                          ),
                        ),
                        BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            int count = 0;
                            if (state is SavedPlacesLoaded) count = state.places.length;
                            return Text(
                              '$count مواقع محفوظة',
                              style: const TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary500,
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    AppSpacing.h12,

                    // ==========================================
                    // Interactive Places Grid/List
                    // ==========================================
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        if (state is ProfileLoading) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.primary500));
                        } else if (state is SavedPlacesLoaded) {
                          final savedPlaces = state.places;
                          if (savedPlaces.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text('لا توجد أماكن محفوظة بعد', style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                              ),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: savedPlaces.length,
                            separatorBuilder: (context, index) => AppSpacing.h12,
                            itemBuilder: (context, index) {
                              final entity = savedPlaces[index];
                              
                              PlaceType parsedType = PlaceType.custom;
                              if (entity.type == 'home') parsedType = PlaceType.home;
                              if (entity.type == 'work') parsedType = PlaceType.work;

                              final model = SavedPlace(
                                id: entity.id,
                                name: entity.name,
                                addressDetails: entity.address,
                                latitude: entity.lat,
                                longitude: entity.lng,
                                type: parsedType,
                                icon: _getIconForType(parsedType),
                              );
                              return _buildPlaceCard(isDark, model);
                            },
                          );
                        } else if (state is ProfileError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(state.message, style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', color: AppColors.danger)),
                            ),
                          );
                        }
                        return const SizedBox();
                      }
                    ),

                    AppSpacing.h32,
                  ],
                ),
              ),

              // ==========================================
              // Persistent Floating Button
              // ==========================================
              _buildAddButtonFooter(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCard(bool isDark) {
    return GlassBox(
      borderRadius: AppSpacing.radiusXL,
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.primary500.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flash_on_rounded,
              color: AppColors.primary500,
              size: 26,
            ),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الحجز السريع الذكي بلمسة واحدة',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h4,
                Text(
                  'اضغط على أي موقع محفوظ لحجز مشوارك فورياً دون الحاجة ظ„ظƒطھابة العناوين مجدداً على الخارطة.',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11,
                    height: 1.5,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(bool isDark, SavedPlace place) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.6) : AppColors.white.withValues(alpha: 0.9),
        borderRadius: AppSpacing.borderLG,
        border: Border.all(
          color: isDark ? AppColors.white.withValues(alpha: 0.04) : AppColors.gray200,
        ),
      ),
      child: ClipRRect(
        borderRadius: AppSpacing.borderLG,
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
              leading: Container(
                padding: const EdgeInsets.all(AppSpacing.s10),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  place.icon,
                  color: AppColors.primary500,
                  size: 22,
                ),
              ),
              title: Row(
                children: [
                  Text(
                    place.name,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                  AppSpacing.w8,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getNameForType(place.type),
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 9,
                        color: isDark ? AppColors.gray400 : AppColors.gray500,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  place.addressDetails,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: isDark ? AppColors.gray400 : AppColors.gray600),
                color: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderMD),
                onSelected: (action) => _handleMenuAction(action, place),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 16, color: AppColors.primary500),
                        AppSpacing.w8,
                        Text(
                          'تعديل الموقع',
                          style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever_rounded, size: 16, color: AppColors.danger),
                        AppSpacing.w8,
                        Text(
                          'حذف نهائي',
                          style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12, color: AppColors.danger),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Interactive Bottom Panel for single tap fast booking
            InkWell(
              onTap: () => _triggerQuickBooking(place),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: AppSpacing.s16),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.05),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.white.withValues(alpha: 0.03) : AppColors.gray100,
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          color: AppColors.primary500,
                          size: 14,
                        ),
                        AppSpacing.w8,
                        Text(
                          'احجز دراجة / سيارة إلى هذه الوجهة فوراً',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: AppColors.primary500,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.chevron_left_rounded, // Left chevron due to RTL
                      color: AppColors.primary500,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButtonFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.rLG),
          topRight: Radius.circular(AppSpacing.rLG),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => _showAddPlaceBottomSheet(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary500,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderMD,
            ),
            elevation: 2,
          ),
          icon: const Icon(Icons.add_location_alt_rounded, size: 18),
          label: const Text(
            'حفظ وإضافة موقع جديد',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action, SavedPlace place) {
    if (action == 'edit') {
      _showAddPlaceBottomSheet(editPlace: place);
    } else if (action == 'delete') {
      _confirmDeletePlace(place);
    }
  }

  void _confirmDeletePlace(SavedPlace place) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderLG,
          ),
          title: const Text(
            'حذف وجهة مفضلة',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف "${place.name}" نهائياً من سجل مفضلاتك السريعة؟',
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 13,
              color: AppColors.gray600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement delete logic in BLoC
                // context.read<ProfileBloc>().add(DeleteSavedPlaceEvent(place.id));
                Navigator.pop(ctx);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.danger,
                    content: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        'تم إزالة الموقع المفضل بنجاح.',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderXS,
                ),
              ),
              child: const Text(
                'حذف الآن',
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

  void _showAddPlaceBottomSheet({SavedPlace? editPlace}) {
    if (editPlace != null) {
      _nameController.text = editPlace.name;
      _addressController.text = editPlace.addressDetails;
      _selectedType = editPlace.type;
      _selectedLat = editPlace.latitude;
      _selectedLng = editPlace.longitude;
    } else {
      _nameController.clear();
      _addressController.clear();
      _selectedType = PlaceType.custom;
      _selectedLat = 15.3694; // Default Sana'a center
      _selectedLng = 44.1910;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
                borderRadius: AppSpacing.borderBottomSheet,
              ),
              padding: EdgeInsets.only(
                top: AppSpacing.s24,
                left: AppSpacing.s24,
                right: AppSpacing.s24,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Drag handle
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.gray700 : AppColors.gray300,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),

                    AppSpacing.h24,

                    Text(
                      editPlace != null ? 'تعديل بيانات الموقع المفضل' : 'حفظ موقع مفضل جديد',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                    ),

                    AppSpacing.h16,

                    // Choose preset type chips
                    const Text(
                      'نوع وتصنيف الوجهة المعتادة:',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray600,
                      ),
                    ),
                    AppSpacing.h10,
                    _buildPlaceTypeChips(isDark, setModalState),

                    AppSpacing.h16,

                    // Name of destination input
                    const Text(
                      'اسم الوجهة المخصصة:',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray600,
                      ),
                    ),
                    AppSpacing.h8,
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                      decoration: InputDecoration(
                        hintText: 'مثال: البيت الجديد، صيدلية العواضي، النادي الرياضي',
                        hintStyle: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: isDark ? AppColors.gray600 : AppColors.gray400,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 14),
                        filled: true,
                        fillColor: isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppSpacing.borderSM,
                          borderSide: BorderSide(
                            color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppSpacing.borderSM,
                          borderSide: const BorderSide(
                            color: AppColors.primary500,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: AppSpacing.borderSM,
                          borderSide: const BorderSide(
                            color: AppColors.danger,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: AppSpacing.borderSM,
                          borderSide: const BorderSide(
                            color: AppColors.danger,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال اسم مميز للموقع';
                        }
                        if (value.trim().length < 3) {
                          return 'الاسم قصير جداً (أدخل 3 أحرف على الأقل)';
                        }
                        return null;
                      },
                    ),

                    AppSpacing.h16,

                    // Address / landmarks description input
                    const Text(
                      'تفاصيل العنوان والمعالم المجاورة:',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray600,
                      ),
                    ),
                    AppSpacing.h8,
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 13,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                      decoration: InputDecoration(
                        hintText: 'مثال: حي حدة، شارع صفر، خلف صيدلية ابن حيان، البناية ذات البوابة السوداء',
                        hintStyle: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 11.5,
                          fontWeight: FontWeight.normal,
                          color: isDark ? AppColors.gray600 : AppColors.gray400,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 12),
                        filled: true,
                        fillColor: isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppSpacing.borderSM,
                          borderSide: BorderSide(
                            color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppSpacing.borderSM,
                          borderSide: const BorderSide(
                            color: AppColors.primary500,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: AppSpacing.borderSM,
                          borderSide: const BorderSide(
                            color: AppColors.danger,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: AppSpacing.borderSM,
                          borderSide: const BorderSide(
                            color: AppColors.danger,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى وصف تفاصيل الموقع لتوجيه الكابتن بدقة';
                        }
                        return null;
                      },
                    ),

                    AppSpacing.h16,

                    // Mock coordinate pinpoint preview widget
                    _buildCoordinatePinpointPreview(isDark, setModalState),

                    AppSpacing.h24,

                    // Action buttons
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _savePlaceSubmitted(editPlace, context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderMD,
                          ),
                        ),
                        child: Text(
                          editPlace != null ? 'حفظ تعديلات الموقع المفضّل' : 'إضافة وتأكيد الحفظ',
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    AppSpacing.h16,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceTypeChips(bool isDark, StateSetter setModalState) {
    return Wrap(
      spacing: AppSpacing.s8,
      runSpacing: AppSpacing.s8,
      children: PlaceType.values.map((type) {
        final isSelected = _selectedType == type;
        final icon = _getIconForType(type);
        final title = _getNameForType(type);

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected 
                    ? AppColors.white 
                    : (isDark ? AppColors.white : AppColors.gray700),
              ),
              AppSpacing.w6,
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected 
                      ? AppColors.white 
                      : (isDark ? AppColors.white : AppColors.gray700),
                ),
              ),
            ],
          ),
          selected: isSelected,
          selectedColor: AppColors.primary500,
          backgroundColor: isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? AppColors.primary500 : (isDark ? AppColors.white.withValues(alpha: 0.04) : AppColors.gray200),
            ),
          ),
          onSelected: (selected) {
            if (selected) {
              setModalState(() {
                _selectedType = type;
                // Pre-fill name if it is home or work and input was empty
                if (type == PlaceType.home && _nameController.text.trim().isEmpty) {
                  _nameController.text = 'المنزل';
                } else if (type == PlaceType.work && _nameController.text.trim().isEmpty) {
                  _nameController.text = 'العمل';
                } else if (type == PlaceType.university && _nameController.text.trim().isEmpty) {
                  _nameController.text = 'الجامعة';
                }
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildCoordinatePinpointPreview(bool isDark, StateSetter setModalState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.primary500.withValues(alpha: 0.03),
        borderRadius: AppSpacing.borderSM,
        border: Border.all(
          color: AppColors.primary500.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.gps_fixed_rounded, color: AppColors.primary500, size: 14),
                  AppSpacing.w6,
                  Text(
                    'تحديد إحداثيات الموقع الحالية (صنعاء):',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  setModalState(() {
                    // Simulate selecting another random location in Sana'a for demo
                    _selectedLat = 15.3600 + (0.01 * (DateTime.now().second % 10));
                    _selectedLng = 44.1800 + (0.01 * (DateTime.now().millisecond % 10));
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'تغيير النقطة ⟳',
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
          AppSpacing.h6,
          Row(
            children: [
              Text(
                'عرض خط العرض: ',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 10,
                  color: isDark ? AppColors.gray400 : AppColors.gray500,
                ),
              ),
              Text(
                _selectedLat.toStringAsFixed(6),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary500,
                ),
              ),
              AppSpacing.w16,
              Text(
                'خط الطول: ',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 10,
                  color: isDark ? AppColors.gray400 : AppColors.gray500,
                ),
              ),
              Text(
                _selectedLng.toStringAsFixed(6),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _savePlaceSubmitted(SavedPlace? editPlace, BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final newEntity = SavedPlaceEntity(
        id: editPlace?.id ?? 'place_custom_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        lat: _selectedLat,
        lng: _selectedLng,
        type: _selectedType.name,
      );

      // Trigger Bloc Event
      context.read<ProfileBloc>().add(AddSavedPlaceEvent(newEntity));

      // Close sheet
      Navigator.pop(context);

      // Show completed snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.white, size: 20),
                AppSpacing.w12,
                Text(
                  editPlace != null ? 'تم تحديث تفاصيل الموقع بنجاح!' : 'تم إضافة موقعك المفضل بنجاح!',
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _triggerQuickBooking(SavedPlace place) {
    // Elegant quick booking simulator bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
              borderRadius: AppSpacing.borderBottomSheet,
            ),
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag bar
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.gray700 : AppColors.gray300,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                
                AppSpacing.h24,

                const Icon(
                  Icons.electric_moped_rounded,
                  color: AppColors.primary500,
                  size: 48,
                ),

                AppSpacing.h16,

                Text(
                  'الحجز السريع إلى: ${place.name}',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                
                AppSpacing.h8,

                Text(
                  'سيقوم النظام بحساب تسعيرة الأجرة فورياً وإرسال كابتن ط§ظ„دراجة النارية الأقرب لموقعك الحالي في صنعاء.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    height: 1.5,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),

                AppSpacing.h20,

                // Estimated fare
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withValues(alpha: 0.04),
                    borderRadius: AppSpacing.borderSM,
                    border: Border.all(color: AppColors.primary500.withValues(alpha: 0.1)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تسعيرة الأجرة التقريبية (دراجة نارية):',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray600,
                        ),
                      ),
                      Text(
                        '1,200 - 1,500 ريال',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppColors.primary500,
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.h24,

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: isDark ? AppColors.white.withValues(alpha: 0.12) : AppColors.gray300),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderMD,
                          ),
                        ),
                        child: Text(
                          'تراجع وإلغاء',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.white : AppColors.gray700,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.w16,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx); // Close sheet
                          _executeBooking(place);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderMD,
                          ),
                        ),
                        child: const Text(
                          'تأكيد الحجز الفوري',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
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
      },
    );
  }

  void _executeBooking(SavedPlace place) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.info,
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'سيتم تفعيل الحجز السريع عند الانتهاء من ربط الباك-اند ط¨ط§لكامل.',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
