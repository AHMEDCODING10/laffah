import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/di/injection_container.dart' as di;
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/glass_box.dart';
import '../../../../../core/services/echo_service.dart';
import '../../../domain/entities/parcel_entity.dart';

/// SearchingParcelCaptainOverlay — Modal/Overlay displayed when passenger requests parcel delivery.
/// Shows animated radar waves, package info, and auto-polls status until a captain accepts.
class SearchingParcelCaptainOverlay extends StatefulWidget {
  final ParcelEntity parcel;
  final VoidCallback onCancel;
  final Function(ParcelEntity) onAccepted;

  const SearchingParcelCaptainOverlay({
    super.key,
    required this.parcel,
    required this.onCancel,
    required this.onAccepted,
  });

  @override
  State<SearchingParcelCaptainOverlay> createState() =>
      _SearchingParcelCaptainOverlayState();
}

class _SearchingParcelCaptainOverlayState
    extends State<SearchingParcelCaptainOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _statusPollingTimer;
  Timer? _countdownTimer;
  int _remainingSeconds = 180; // 3 minutes
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });

    _startStatusPolling();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _statusPollingTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startStatusPolling() {
    final identifier = widget.parcel.id.isNotEmpty
        ? widget.parcel.id
        : (widget.parcel.trackingCode ?? '');
        
    if (identifier.isEmpty) return;

    // Use WebSocket for instant real-time updates
    EchoService().listenToTripStatus(identifier, (data) {
      if (_isNavigating || !mounted) return;
      
      final status = (data['status'] ?? '').toString();
      if (status == 'accepted' || status == 'picked_up' || status == 'in_transit' || status == 'delivered') {
        _isNavigating = true;
        _statusPollingTimer?.cancel();
        HapticFeedback.heavyImpact();

        if (mounted) {
           _navigateToTracking(data);
        }
      }
    });

    // Robust fallback fetch (polls every 10 seconds)
    _statusPollingTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_isNavigating || !mounted) {
        timer.cancel();
        return;
      }

      try {
        final dioClient = di.sl<DioClient>();
        final identifier = widget.parcel.id.isNotEmpty
            ? widget.parcel.id
            : (widget.parcel.trackingCode ?? '');
        if (identifier.isEmpty) return;

        final response = await dioClient.dio.get('/parcel/$identifier/track');

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data['data'] ?? response.data;
          final status = (data['status'] ?? '').toString();

          if (status == 'accepted' ||
              status == 'picked_up' ||
              status == 'in_transit' ||
              status == 'delivered') {
            _isNavigating = true;
            timer.cancel(); // Stop polling
            HapticFeedback.heavyImpact();

            if (mounted) {
               _navigateToTracking(data);
            }
          }
        }
      } catch (_) {}
    });
  }

  void _navigateToTracking(Map<String, dynamic> data) {
    final captainData = data['captain'] ?? {};
    final captainUser = captainData is Map ? (captainData['user'] ?? {}) : {};

              final updatedParcel = ParcelEntity(
                id: (data['id'] ?? widget.parcel.id).toString(),
                trackingCode: (data['tracking_code'] ?? widget.parcel.trackingCode)
                    ?.toString(),
                captainProfileId: data['captain_profile_id']?.toString(),
                senderName:
                    (data['sender_name'] ?? widget.parcel.senderName).toString(),
                senderPhone:
                    (data['sender_phone'] ?? widget.parcel.senderPhone).toString(),
                receiverName: (data['receiver_name'] ?? widget.parcel.receiverName)
                    .toString(),
                receiverPhone:
                    (data['receiver_phone'] ?? widget.parcel.receiverPhone)
                        .toString(),
                pickupAddress: (data['pickup_address'] ?? widget.parcel.pickupAddress)
                    .toString(),
                pickupLatitude: (data['pickup_latitude'] as num?)?.toDouble() ??
                    widget.parcel.pickupLatitude,
                pickupLongitude: (data['pickup_longitude'] as num?)?.toDouble() ??
                    widget.parcel.pickupLongitude,
                dropoffAddress:
                    (data['dropoff_address'] ?? widget.parcel.dropoffAddress)
                        .toString(),
                dropoffLatitude: (data['dropoff_latitude'] as num?)?.toDouble() ??
                    widget.parcel.dropoffLatitude,
                dropoffLongitude:
                    (data['dropoff_longitude'] as num?)?.toDouble() ??
                        widget.parcel.dropoffLongitude,
                parcelType:
                    (data['parcel_type'] ?? widget.parcel.parcelType).toString(),
                size: (data['size'] ?? widget.parcel.size).toString(),
                notes: (data['notes'] ?? widget.parcel.notes)?.toString() ?? '',
                status: (data['status'] ?? '').toString(),
            price: (data['price'] as num?)?.toDouble() ?? widget.parcel.price,
            captainName: captainUser is Map ? captainUser['name']?.toString() : (data['captain_name']?.toString()),
            captainPhone: captainUser is Map ? captainUser['phone']?.toString() : (data['captain_phone']?.toString()),
          );

          widget.onAccepted(updatedParcel);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B26) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.gray700 : AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Radar Pulse Icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer expanding glow
                    Container(
                      width: 100 * _pulseAnimation.value,
                      height: 100 * _pulseAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary500
                            .withValues(alpha: 0.12 / _pulseAnimation.value),
                      ),
                    ),
                    // Middle circle
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary500.withValues(alpha: 0.15),
                      ),
                    ),
                    // Inner Core
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary500,
                      ),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Title
            const Text(
              'جاري البحث عن كابتن لتوصيل الطرد...',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // 3-Minute Timeout Timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary500.withValues(alpha: 0.2)),
              ),
              child: Text(
                '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.primary500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'يتم الآن إرسال طلبك إلى الكباتن المتواجدين بالقرب منك',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 12.5,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Details Box
            GlassBox(
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.all(14),
              customBgColor: isDark
                  ? const Color(0xFF1E2330)
                  : AppColors.gray100.withValues(alpha: 0.7),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'نوع الطرد: ${widget.parcel.parcelType}',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: isDark ? Colors.white : AppColors.gray900,
                        ),
                      ),
                      Text(
                        '${widget.parcel.price.toStringAsFixed(0)} ر.ي',
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: AppColors.primary500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.primary500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.parcel.dropoffAddress,
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 11.5,
                            color: isDark ? AppColors.gray400 : AppColors.gray600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  _statusPollingTimer?.cancel();
                  Navigator.of(context, rootNavigator: true).pop();
                  widget.onCancel();
                },
                child: const Text(
                  'إلغاء البحث',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: AppColors.danger,
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
