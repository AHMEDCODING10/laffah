import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';

/// CaptainTripsSubPage - Dedicated Sub-Page for Captain's Trip History & Active Orders
class CaptainTripsSubPage extends StatelessWidget {
  const CaptainTripsSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> trips = [
      {
        'id': 'LF-88293',
        'status': 'قيد التنفيذ',
        'statusColor': AppColors.warning,
        'pickup': 'شارع الستين - صنعاء، اليمن',
        'dropoff': 'مول العرب - شارع حدة',
        'price': '2,400 ريال',
        'date': 'اليوم، 10:30 ص',
      },
      {
        'id': 'LF-88290',
        'status': 'بانتظار التأكيد',
        'statusColor': AppColors.info,
        'pickup': 'فندق السعيد - تعز',
        'dropoff': 'شارع جمال - وسط المدينة',
        'price': '1,800 ريال',
        'date': 'اليوم، 09:15 ص',
      },
      {
        'id': 'LF-88285',
        'status': 'تم الانتهاء',
        'statusColor': AppColors.success,
        'pickup': 'خور مكسر - عدن',
        'dropoff': 'مطار عدن الدولي',
        'price': '1,800 ريال',
        'date': 'أمس، 08:00 م',
      }
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الرحلات',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: 'IBM Plex Sans Arabic',
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          children: [
            // Search input field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.white,
                borderRadius: AppSpacing.borderLG,
                border: Border.all(
                  color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray200,
                ),
              ),
              child: const TextField(
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'البحث عن رحلة...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search_rounded, color: AppColors.gray500),
                ),
              ),
            ),
            
            AppSpacing.h20,

            // Build list
            ...trips.map((trip) {
              return GlassBox(
                margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                borderRadius: AppSpacing.radiusLG,
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: ID & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'رقم الرحلة: ${trip['id']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.gray500 : AppColors.gray600,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10, vertical: AppSpacing.s4),
                          decoration: BoxDecoration(
                            color: (trip['statusColor'] as Color).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            trip['status'],
                            style: TextStyle(
                              fontSize: 10,
                              color: trip['statusColor'] as Color,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.h12,

                    // Row 2: Route details
                    Row(
                      children: [
                        const Icon(Icons.radio_button_checked_rounded, color: AppColors.primary500, size: 14),
                        AppSpacing.w10,
                        Expanded(
                          child: Text(
                            trip['pickup'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Container(
                        width: 1.5,
                        height: 12,
                        color: isDark ? AppColors.white.withOpacity(0.12) : AppColors.gray300,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.place_rounded, color: AppColors.danger, size: 14),
                        AppSpacing.w10,
                        Expanded(
                          child: Text(
                            trip['dropoff'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
                      child: Divider(height: 1),
                    ),

                    // Price & Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          trip['price'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.primary500,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                        Text(
                          trip['date'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.gray500,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
