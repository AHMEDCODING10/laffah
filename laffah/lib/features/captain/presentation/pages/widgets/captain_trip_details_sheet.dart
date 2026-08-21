import '../../../../../l10n/app_localizations.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

/// CaptainTripDetailsSheet — Premium Glassmorphic Bottom Sheet displaying
/// comprehensive trip analytics, passenger contacts, route maps, and financial breakdown.
class CaptainTripDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> trip;

  const CaptainTripDetailsSheet({
    super.key,
    required this.trip,
  });

  static void show(BuildContext context, Map<String, dynamic> trip) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CaptainTripDetailsSheet(trip: trip),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String tripId = trip['id'] ?? 'LF-00000';
    final String status =
        trip['status'] ?? AppLocalizations.of(context)!.capt_trip_done;
    final Color statusColor =
        (trip['statusColor'] as Color?) ?? AppColors.success;
    final String passengerName =
        trip['passengerName'] ?? AppLocalizations.of(context)!.capt_passenger;
    final String passengerPhone = trip['passengerPhone'] ?? '+967 777 000 000';
    final double passengerRating = (trip['rating'] as num?)?.toDouble() ?? 5.0;
    final String pickup =
        trip['pickup'] ?? AppLocalizations.of(context)!.capt_pickup_loc;
    final String dropoff =
        trip['dropoff'] ?? AppLocalizations.of(context)!.capt_dropoff_loc;
    final String priceStr =
        trip['price'] ?? AppLocalizations.of(context)!.capt_0_yer;
    final double grossFare = (trip['grossFare'] as num?)?.toDouble() ?? 2400.0;
    final double platformFee = grossFare * 0.10;
    final double netEarnings = grossFare - platformFee;
    final String dateStr =
        trip['date'] ?? AppLocalizations.of(context)!.capt_today;
    final String distanceStr =
        trip['distance'] ?? AppLocalizations.of(context)!.capt_4_5_km;
    final String durationStr = trip['duration'] ?? AppLocalizations.of(context)!.capt_12_min;
    final String paymentMethod =
        trip['paymentMethod'] ?? AppLocalizations.of(context)!.capt_cash;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141822).withValues(alpha: 0.94)
                    : Colors.white.withValues(alpha: 0.96),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Drag Handle Bar
                    Center(
                      child: Container(
                        width: 44,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    AppSpacing.h16,

                    // Header Row: Trip ID & Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.capt_trip_details_id(tripId),
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color:
                                    isDark ? Colors.white : AppColors.gray900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 11.5,
                                color: AppColors.gray500,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.h20,

                    // Passenger Contact Tile
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : AppColors.gray50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : AppColors.gray200,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                AppColors.primary500.withValues(alpha: 0.18),
                            child: Text(
                              passengerName.isNotEmpty ? passengerName[0] : 'ع',
                              style: const TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: AppColors.primary500,
                              ),
                            ),
                          ),
                          AppSpacing.w12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  passengerName,
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.gray900,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        size: 15, color: Colors.amber),
                                    AppSpacing.w4,
                                    Text(
                                      '$passengerRating âک…',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: AppColors.gray500,
                                      ),
                                    ),
                                    AppSpacing.w12,
                                    Text(
                                      passengerPhone,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11.5,
                                        color: AppColors.gray500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Direct call icon button
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.phone_rounded,
                                  color: AppColors.success, size: 20),
                              onPressed: () => _makePhoneCall(passengerPhone),
                            ),
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.h16,

                    // Route Card (Pickup & Dropoff)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : AppColors.gray50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : AppColors.gray200,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              AppSpacing.w12,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .capt_point_a,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontFamily: 'IBM Plex Sans Arabic',
                                      ),
                                    ),
                                    Text(
                                      pickup,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.gray900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                width: 2,
                                height: 16,
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              AppSpacing.w12,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .capt_point_b,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                        fontFamily: 'IBM Plex Sans Arabic',
                                      ),
                                    ),
                                    Text(
                                      dropoff,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.gray900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.h16,

                    // Specs Row (Distance, Duration, Vehicle)
                    Row(
                      children: [
                        Expanded(
                          child: _buildSpecTile(
                              isDark,
                              Icons.map_rounded,
                              AppLocalizations.of(context)!.capt_distance,
                              distanceStr),
                        ),
                        AppSpacing.w10,
                        Expanded(
                          child: _buildSpecTile(
                              isDark,
                              Icons.schedule_rounded,
                              AppLocalizations.of(context)!.capt_duration,
                              durationStr),
                        ),
                        AppSpacing.w10,
                        Expanded(
                          child: _buildSpecTile(
                              isDark,
                              Icons.two_wheeler_rounded,
                              AppLocalizations.of(context)!.capt_transport_mode,
                              AppLocalizations.of(context)!.capt_motorcycle),
                        ),
                      ],
                    ),

                    AppSpacing.h20,

                    // Financial Earnings Breakdown Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              AppColors.primary500.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .capt_financial_calc,
                                style: const TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary500
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  paymentMethod,
                                  style: const TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildFinanceRow(
                              AppLocalizations.of(context)!
                                  .capt_total_actual_fare,
                              priceStr,
                              isDark,
                              false),
                          const SizedBox(height: 6),
                          _buildFinanceRow(
                              AppLocalizations.of(context)!
                                  .capt_laffah_commission,
                              '-${platformFee.toStringAsFixed(0)} ${AppLocalizations.of(context)!.pass_yer.replaceAll(RegExp(r" \(YER\)"), "")}',
                              isDark,
                              false),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1),
                          ),
                          _buildFinanceRow(
                            AppLocalizations.of(context)!.capt_net_earnings,
                            '${netEarnings.toStringAsFixed(0)} ${AppLocalizations.of(context)!.pass_yer.replaceAll(RegExp(r" \(YER\)"), "")}',
                            isDark,
                            true,
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.h24,

                    // Action Buttons (Print/Share Invoice & Report Issue)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!
                                          .capt_extracting_invoice,
                                      style: const TextStyle(
                                          fontFamily: 'IBM Plex Sans Arabic'),
                                    ),
                                    backgroundColor: AppColors.info,
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white24
                                      : AppColors.gray300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.receipt_rounded, size: 18),
                              label: Text(
                                AppLocalizations.of(context)!.capt_invoice,
                                style: const TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        AppSpacing.w12,
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary500,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.check_circle_rounded,
                                  size: 18),
                              label: Text(
                                AppLocalizations.of(context)!
                                    .capt_close_details,
                                style: const TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.h16,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecTile(
      bool isDark, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color:
            isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.primary500),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              color: AppColors.gray500,
              fontWeight: FontWeight.bold,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              fontFamily: 'IBM Plex Sans Arabic',
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceRow(
      String label, String value, bool isDark, bool isHighlight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: isHighlight ? 13.5 : 12,
            fontWeight: isHighlight ? FontWeight.w900 : FontWeight.bold,
            color: isHighlight
                ? (isDark ? Colors.white : AppColors.gray900)
                : AppColors.gray500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: isHighlight ? 16 : 13,
            fontWeight: FontWeight.w900,
            color: isHighlight
                ? AppColors.primary500
                : (isDark ? Colors.white : AppColors.gray900),
          ),
        ),
      ],
    );
  }
}
