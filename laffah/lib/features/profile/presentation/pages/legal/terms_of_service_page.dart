import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_localizations.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.terms_of_service_title,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(AppLocalizations.of(context)!.terms_accept_title, isDark),
              _buildSectionText(
                AppLocalizations.of(context)!.terms_accept_text,
                isDark,
              ),
              AppSpacing.h24,
              _buildSectionTitle(AppLocalizations.of(context)!.terms_user_obligations_title, isDark),
              _buildSectionText(
                AppLocalizations.of(context)!.terms_user_obligations_text,
                isDark,
              ),
              AppSpacing.h24,
              _buildSectionTitle(AppLocalizations.of(context)!.terms_payment_title, isDark),
              _buildSectionText(
                AppLocalizations.of(context)!.terms_payment_text,
                isDark,
              ),
              AppSpacing.h24,
              _buildSectionTitle(AppLocalizations.of(context)!.terms_disclaimer_title, isDark),
              _buildSectionText(
                AppLocalizations.of(context)!.terms_disclaimer_text,
                isDark,
              ),
              AppSpacing.h32,
              Center(
                child: Text(
                  AppLocalizations.of(context)!.privacy_policy_last_updated,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: AppColors.gray500,
                    fontSize: 12,
                  ),
                ),
              ),
              AppSpacing.h32,
            ],
          ),
        ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.w900,
          fontSize: 16,
          color: isDark ? AppColors.primary400 : AppColors.primary600,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'IBM Plex Sans Arabic',
        fontSize: 14,
        height: 1.6,
        color: isDark ? AppColors.gray400 : AppColors.gray700,
      ),
    );
  }
}
