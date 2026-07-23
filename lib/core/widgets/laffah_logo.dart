import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// LaffahLogo - Renders the premium Laffah (لفّة) brand logo image.
class LaffahLogo extends StatelessWidget {
  final double height;
  final double width;
  final bool showSubtitle;

  const LaffahLogo({
    super.key,
    this.height = 140,
    this.width = 140,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand Logo Image from Assets
        SizedBox(
          height: height,
          width: width,
          child: Image.asset(
            'assets/images/laffah_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 12),
          // English Brand Name
          Text(
            'Laffah',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              fontFamily: 'SF Pro Display',
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.white
                  : AppColors.gray900,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 4),
          // Arabic Sub-label
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                child: Divider(color: AppColors.primary500, thickness: 1.5),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'لَفَّة',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary500,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              SizedBox(
                width: 24,
                child: Divider(color: AppColors.primary500, thickness: 1.5),
              ),
            ],
          ),
        ],
      ],
    );
  }
}