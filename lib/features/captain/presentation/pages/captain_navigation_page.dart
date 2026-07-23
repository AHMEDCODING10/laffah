import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';

/// CaptainNavigationPage - High-fidelity trip navigation and progress execution screen.
/// Implements state progression (وصلت -> ابدأ الرحلة -> إنهاء الرحلة) and transitions
/// to the premium Invoice Summary view matching Screenshot 4.
class CaptainNavigationPage extends StatefulWidget {
  final String tripId;
  final String passengerName;
  final String passengerPhone;
  final double passengerRating;
  final String pickup;
  final String dropoff;
  final double fare;
  final String distance;
  final String duration;

  const CaptainNavigationPage({
    super.key,
    required this.tripId,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerRating,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distance,
    required this.duration,
  });

  @override
  State<CaptainNavigationPage> createState() => _CaptainNavigationPageState();
}

class _CaptainNavigationPageState extends State<CaptainNavigationPage> {
  // Navigation states: 0: driving to pickup ('accepted'), 1: arrived at pickup ('arrived'), 2: on trip ('started'), 3: finished ('completed')
  int _currentStep = 0; 
  double _sliderValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_currentStep == 3) {
      return _buildTripCompletedInvoice(context, isDark);
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF11141B) : const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          _currentStep == 2 ? 'أثناء الرحلة' : 'الذهاب للراكب',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            fontFamily: 'IBM Plex Sans Arabic',
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.white.withOpacity(0.08) : AppColors.gray200,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.more_horiz_rounded, size: 20),
            onPressed: () {},
          ),
        ),
        actions: [
          // SOS button matching Screenshot 2
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.danger.withOpacity(0.3), width: 1.0),
            ),
            child: const Center(
              child: Text(
                'SOS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.danger,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full map representation
          Positioned.fill(
            child: _buildNavigationMap(isDark),
          ),

          // Top navigation instruction card (Screenshot 2: "انعطف يساراً")
          Positioned(
            top: AppSpacing.s12,
            left: AppSpacing.s16,
            right: AppSpacing.s16,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: GlassBox(
                borderRadius: AppSpacing.radiusMD,
                padding: const EdgeInsets.all(AppSpacing.s14),
                child: Row(
                  children: [
                    // Turn left arrow avatar
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withOpacity(0.15),
                        borderRadius: AppSpacing.borderMD,
                      ),
                      child: const Icon(
                        Icons.turn_left_rounded,
                        color: AppColors.primary500,
                        size: 26,
                      ),
                    ),
                    AppSpacing.w16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'انعطف يساراً',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                          Text(
                            _currentStep == 2 
                                ? 'شارع الستين - بعد 200 متر' 
                                : 'شارع حِدة - باتجاه نقطة التجمع',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.gray500,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Minutes floating indicator
                    _buildFloatingBubble(
                      '12',
                      'دقيقة',
                      isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating remaining distance indicator (Screenshot 2: "3.4 كم")
          Positioned(
            right: AppSpacing.s16,
            top: 115,
            child: _buildFloatingBubble(
              '3.4',
              'كم',
              isDark,
            ),
          ),

          // Bottom details sheet & interactive sliding actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: GlassBox(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.s32),
                  topRight: Radius.circular(AppSpacing.s32),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Passenger Information Card
                    Row(
                      children: [
                        // Passenger avatar
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary500, width: 2.0),
                                image: const DecorationImage(
                                  image: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=150'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${widget.passengerRating} ★',
                                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'IBM Plex Sans Arabic'),
                              ),
                            ),
                          ],
                        ),

                        AppSpacing.w16,

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.passengerName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                ),
                              ),
                              const Text(
                                'طريقة الدفع: محفظة لفة',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.gray500,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action icons (Call & Chat shortcuts)
                        Row(
                          children: [
                            _buildCircleCallAction(
                              Icons.chat_bubble_outline_rounded,
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم فتح محادثة لفة مع الراكب')),
                                );
                              },
                              isDark,
                            ),
                            AppSpacing.w10,
                            _buildCircleCallAction(
                              Icons.phone_in_talk_rounded,
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('جاري الاتصال بـ ${widget.passengerName}...')),
                                );
                              },
                              isDark,
                            ),
                          ],
                        ),
                      ],
                    ),

                    AppSpacing.h20,

                    // Key details row (Estimated fare & destination)
                    Row(
                      children: [
                        // Estimated Fare box
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.s12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray100,
                              borderRadius: AppSpacing.borderLG,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.payments_rounded, color: AppColors.primary500, size: 20),
                                AppSpacing.w12,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'الأجرة المقدرة',
                                      style: TextStyle(fontSize: 9, color: AppColors.gray500, fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic'),
                                    ),
                                    Text(
                                      '${widget.fare.toStringAsFixed(0)} ر.ي',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'IBM Plex Sans Arabic'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        AppSpacing.w12,
                        // Destination box
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.s12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray100,
                              borderRadius: AppSpacing.borderLG,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.place_rounded, color: AppColors.info, size: 20),
                                AppSpacing.w12,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'الوجهة',
                                        style: TextStyle(fontSize: 9, color: AppColors.gray500, fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic'),
                                      ),
                                      Text(
                                        widget.dropoff.split('،').first,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'IBM Plex Sans Arabic'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.h24,

                    // Interactive progress slide/tap action button
                    _buildStepActionButton(context, isDark),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Interactive slider/button state selector
  Widget _buildStepActionButton(BuildContext context, bool isDark) {
    String label = '';
    Color btnColor = AppColors.primary500;
    IconData icon = Icons.check_circle_rounded;

    if (_currentStep == 0) {
      label = 'وصلت لموقع الراكب';
      btnColor = AppColors.info;
      icon = Icons.pin_drop_rounded;
    } else if (_currentStep == 1) {
      label = 'بدء الرحلة الآن';
      btnColor = AppColors.success;
      icon = Icons.play_arrow_rounded;
    } else {
      label = 'إنهاء الرحلة وتأكيد الوصول';
      btnColor = AppColors.primary500;
      icon = Icons.verified_rounded;
    }

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: btnColor.withOpacity(0.1),
        borderRadius: AppSpacing.borderLG,
        border: Border.all(color: btnColor.withOpacity(0.2), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: AppSpacing.borderLG,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Slide indicators guide
            Positioned(
              left: 20,
              child: Icon(Icons.double_arrow_rounded, color: btnColor, size: 18),
            ),
            
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: btnColor,
                fontFamily: 'IBM Plex Sans Arabic',
              ),
            ),

            // Sliding active area
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _sliderValue += details.delta.dx / 220; // scaled
                  if (_sliderValue < 0.0) _sliderValue = 0.0;
                  if (_sliderValue > 1.0) _sliderValue = 1.0;
                });
              },
              onHorizontalDragEnd: (details) {
                if (_sliderValue > 0.75) {
                  setState(() {
                    _currentStep++;
                    _sliderValue = 0.0;
                  });
                } else {
                  setState(() {
                    _sliderValue = 0.0;
                  });
                }
              },
              child: Align(
                alignment: Alignment(1.0 - (_sliderValue * 2), 0),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: AppSpacing.borderLG,
                    boxShadow: [
                      BoxShadow(
                        color: btnColor.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(2, 2),
                      )
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Floating informational bubble indicator
  Widget _buildFloatingBubble(String val, String unit, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withOpacity(0.85) : Colors.white.withOpacity(0.9),
        borderRadius: AppSpacing.borderMD,
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray200, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            val,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.0),
          ),
          Text(
            unit,
            style: const TextStyle(fontSize: 9, color: AppColors.gray500, fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic'),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleCallAction(IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.primary500,
          size: 20,
        ),
      ),
    );
  }

  // Mock navigation vector map drawing
  Widget _buildNavigationMap(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF131822) : const Color(0xFFF4F6F8),
      child: CustomPaint(
        painter: _RouteProgressPainter(isDark: isDark, currentStep: _currentStep),
      ),
    );
  }

  // Invoice visual summary panel (Screenshot 4)
  Widget _buildTripCompletedInvoice(BuildContext context, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1116) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'ملخص الرحلة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Success circular badge
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: const BoxDecoration(
                      color: AppColors.primary500,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),

              AppSpacing.h20,

              // Succes title and subtitle
              const Text(
                'تمت الرحلة بنجاح',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              AppSpacing.h6,
              const Text(
                'شكراً لك يا كابتن! يومك حافل بالانجاز.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray500,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),

              AppSpacing.h32,

              // Invoice Details Glass Box Card
              GlassBox(
                borderRadius: AppSpacing.radiusLG,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s24),
                child: Column(
                  children: [
                    const Text(
                      'إجمالي قيمة المشوار',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray500,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                    AppSpacing.h4,
                    Text(
                      '${widget.fare.toStringAsFixed(0)} ريال',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary500,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
                      child: Divider(height: 1),
                    ),

                    // Cash indicator & specs rows
                    _buildInvoiceRow('طريقة الدفع', 'نقداً (Cash)'),
                    AppSpacing.h12,
                    _buildInvoiceRow('المسافة', '8.4 كم'),
                    AppSpacing.h12,
                    _buildInvoiceRow('وقت الرحلة', '24 دقيقة'),
                    AppSpacing.h12,
                    _buildInvoiceRow('المسار', 'من حدة إلى شارع الستين'),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Bottom Actions (تم التحصيل & العودة للرئيسية)
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppSpacing.borderLG,
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Go back home
                  },
                  icon: const Icon(Icons.payments_rounded, color: Colors.white),
                  label: const Text(
                    'تم التحصيل كاش',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic', color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                    shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderLG),
                  ),
                ),
              ),

              AppSpacing.h12,

              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                  side: BorderSide(color: isDark ? AppColors.white.withOpacity(0.08) : AppColors.gray300, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderLG),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_rounded, size: 20, color: AppColors.gray500),
                    AppSpacing.w10,
                    Text(
                      'العودة للرئيسية',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic', color: AppColors.gray500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.gray500, fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic'),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'IBM Plex Sans Arabic'),
        ),
      ],
    );
  }
}

/// Custom street route navigation lines painter
class _RouteProgressPainter extends CustomPainter {
  final bool isDark;
  final int currentStep;

  _RouteProgressPainter({required this.isDark, required this.currentStep});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)
      ..strokeWidth = 3.0;

    final primaryStreetsPaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    final activeRoutePaint = Paint()
      ..color = AppColors.primary500
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final completedRoutePaint = Paint()
      ..color = AppColors.gray500.withOpacity(0.4)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Background grid
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    for (double j = 0; j < size.height; j += 40) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), linePaint);
    }

    // Street network lines
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.5), primaryStreetsPaint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.6, size.height), primaryStreetsPaint);

    final p1 = Offset(size.width * 0.4, size.height * 0.6);
    final p2 = Offset(size.width * 0.5, size.height * 0.45);
    final p3 = Offset(size.width * 0.35, size.height * 0.3);

    // Active Route Path drawing
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.52, p2.dx, p2.dy)
      ..quadraticBezierTo(size.width * 0.42, size.height * 0.38, p3.dx, p3.dy);

    if (currentStep == 0) {
      canvas.drawPath(path, activeRoutePaint);
    } else {
      canvas.drawPath(path, completedRoutePaint);
    }

    // Node dots
    final startPinPaint = Paint()..color = AppColors.primary500;
    final endPinPaint = Paint()..color = AppColors.info;

    canvas.drawCircle(p1, 10.0, startPinPaint);
    canvas.drawCircle(p3, 10.0, endPinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
