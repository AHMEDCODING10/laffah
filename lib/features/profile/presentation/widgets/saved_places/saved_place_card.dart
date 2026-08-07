import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/glass_box.dart';
<<<<<<< HEAD
import '../../../data/datasources/fake_profile_repository.dart';
=======
import '../../../data/models/saved_place_model.dart';
>>>>>>> origin/admin-ahmed

/// SavedPlaceCard — Card widget displaying a saved place item with single-tap booking trigger.
class SavedPlaceCard extends StatelessWidget {
  final bool isDark;
  final SavedPlaceModel place;
  final VoidCallback onBookNow;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SavedPlaceCard({
    super.key,
    required this.isDark,
    required this.place,
    required this.onBookNow,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      borderRadius: AppSpacing.radiusLG,
      margin: const EdgeInsets.only(bottom: AppSpacing.s14),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s10),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
<<<<<<< HEAD
                  place.icon,
=======
                  _getIconForType(place.type),
>>>>>>> origin/admin-ahmed
                  color: AppColors.primary500,
                  size: 20,
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                    ),
                    AppSpacing.h2,
                    Text(
<<<<<<< HEAD
                      place.addressDetails,
=======
                      place.address,
>>>>>>> origin/admin-ahmed
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11.5,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                  size: 20,
                ),
                color: isDark
                    ? AppColors.surfaceElevatedDark
                    : AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderSM,
                ),
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16, color: AppColors.primary500),
                        SizedBox(width: 8),
                        Text(
                          'تعديل المكان',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                        SizedBox(width: 8),
                        Text(
                          'حذف المكان',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 12,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.my_location_rounded,
                    size: 14,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: 4),
                  Text(
<<<<<<< HEAD
                    '${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}',
=======
                    '${place.lat.toStringAsFixed(4)}, ${place.lng.toStringAsFixed(4)}',
>>>>>>> origin/admin-ahmed
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onBookNow,
                borderRadius: AppSpacing.borderXS,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'حجز إلى هنا بسرعة',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: AppColors.primary500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.primary500,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD
=======

  IconData _getIconForType(String type) {
    switch (type) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.business_center_rounded;
      case 'university':
        return Icons.school_rounded;
      case 'shopping':
        return Icons.local_mall_rounded;
      case 'historic':
        return Icons.castle_rounded;
      default:
        return Icons.place_rounded;
    }
  }
>>>>>>> origin/admin-ahmed
}
