import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// ProfileUserHeader — User Info Header Card matching Laffah Captain Card design specifications.
class ProfileUserHeader extends StatelessWidget {
  final bool isDark;
  final String userName;
  final String userPhone;
  final String? avatarUrl;
  final double rating;
  final String membershipTier;
  final bool isVerified;
  final VoidCallback? onEditPressed;

  const ProfileUserHeader({
    super.key,
    required this.isDark,
    required this.userName,
    required this.userPhone,
    this.avatarUrl,
    this.rating = 5.0,
    this.membershipTier = 'عضو مميز',
    this.isVerified = true,
    this.onEditPressed,
  });

  Widget _buildFallbackAvatar(String name) {
    String firstLetter = 'ر'; // default fallback for 'راكب'
    if (name.isNotEmpty && name != 'جاري التحميل...' && name != 'مستخدم لَفَّة') {
      firstLetter = name.trim().characters.first.toUpperCase();
    }
    return Text(
      firstLetter,
      style: const TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarChild;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatarChild = ClipOval(
        child: Image.network(
          avatarUrl!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildFallbackAvatar(userName),
        ),
      );
    } else {
      avatarChild = _buildFallbackAvatar(userName);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF141822).withValues(alpha: 0.9)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Avatar with gradient ring
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFFFF6B00),
              child: avatarChild,
            ),
          ),
          AppSpacing.w16,

          // 2. User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: isDark ? Colors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h4,
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.success,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            membershipTier,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: AppColors.success,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.w8,
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    AppSpacing.w2,
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: isDark ? AppColors.gray300 : AppColors.gray700,
                      ),
                    ),
                  ],
                ),
                AppSpacing.h6,
                Text(
                  userPhone.isNotEmpty ? userPhone : 'رقم الهاتف غير مسجل',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.gray500,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 3. Edit Action
          if (onEditPressed != null)
            IconButton(
              icon: const Icon(
                Icons.edit_note_rounded,
                color: Color(0xFFFF6B00),
                size: 28,
              ),
              onPressed: onEditPressed,
            ),
        ],
      ),
    );
  }
}
