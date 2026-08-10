import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/notification_item_model.dart';
import '../widgets/notification_card.dart';

/// NotificationsPage — Central hub for passenger notifications matching Laffah design.
/// Refactored to Clean Architecture composition.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<NotificationItemModel> _notifications;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Notifications will be loaded from the real backend push notifications system
    _notifications = [];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<NotificationItemModel> get _filteredNotifications {
    if (_selectedCategoryIndex == 0) return _notifications;
    final categories = [
      null,
      'rides',
      'parcels',
      'messages',
      'offers',
    ];
    final selectedCat = categories[_selectedCategoryIndex];
    return _notifications.where((n) => n.category == selectedCat).toList();
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
              isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(AppSpacing.s8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary500.withValues(alpha: 0.2),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primary500,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
          ),
          title: Text(
            AppLocalizations.of(context)!.pass_notifications,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            // Filter Tabs
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s8,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (index) => setState(() => _selectedCategoryIndex = index),
                indicatorColor: AppColors.primary500,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.primary500,
                unselectedLabelColor:
                    isDark ? AppColors.gray400 : AppColors.gray600,
                labelStyle: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                ),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.apps_rounded, size: 20),
                    text: AppLocalizations.of(context)!.pass_all,
                  ),
                  Tab(
                    icon: const Icon(Icons.directions_car_rounded, size: 20),
                    text: AppLocalizations.of(context)!.pass_rides,
                  ),
                  Tab(
                    icon: const Icon(Icons.inventory_2_rounded, size: 20),
                    text: AppLocalizations.of(context)!.pass_parcels,
                  ),
                  Tab(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                    text: AppLocalizations.of(context)!.pass_messages,
                  ),
                  Tab(
                    icon: const Icon(Icons.local_offer_rounded, size: 20),
                    text: AppLocalizations.of(context)!.pass_offers,
                  ),
                ],
              ),
            ),

            // Notification List
            Expanded(
              child: _filteredNotifications.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s16,
                        0,
                        AppSpacing.s16,
                        96,
                      ),
                      itemCount: _filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final item = _filteredNotifications[index];
                        return NotificationCard(
                          isDark: isDark,
                          item: item,
                          onTap: () {
                            // Tap handler
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 48,
            color: isDark ? AppColors.gray600 : AppColors.gray400,
          ),
          AppSpacing.h16,
          Text(
            AppLocalizations.of(context)!.pass_no_notifications,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
