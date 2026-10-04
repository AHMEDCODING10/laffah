import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/notification_item_model.dart';
import '../widgets/notification_card.dart';

/// NotificationsPage — Central hub for notifications with swipe-to-delete and live API integration.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItemModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dioClient = di.sl<DioClient>();
      final response = await dioClient.dio.get(ApiEndpoints.notifications);
      if (!mounted) return;
      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawData = response.data['data'] ?? response.data;
        final List<dynamic> list = rawData is List
            ? rawData
            : (rawData is Map && rawData['data'] is List
                ? rawData['data'] as List<dynamic>
                : []);
        setState(() {
          _notifications = list.map((item) => NotificationItemModel.fromJson(item as Map<String, dynamic>)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("⚠️ [NotificationsPage] Error fetching notifications: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'تعذر تحميل الإشعارات';
        });
      }
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      final dioClient = di.sl<DioClient>();
      await dioClient.dio.post(ApiEndpoints.notificationMarkRead(id));
      if (!mounted) return;
      // Update local state directly for instant feedback
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          final old = _notifications[index];
          _notifications[index] = NotificationItemModel(
            id: old.id,
            title: old.title,
            message: old.message,
            time: old.time,
            category: old.category,
            isUnread: false,
            captainName: old.captainName,
            tripId: old.tripId,
          );
        }
      });
    } catch (e) {
      debugPrint("⚠️ [NotificationsPage] Error marking notification as read: $e");
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      HapticFeedback.lightImpact();
      final dioClient = di.sl<DioClient>();
      await dioClient.dio.post(ApiEndpoints.notificationsReadAll);
      if (!mounted) return;
      setState(() {
        _notifications = _notifications.map((n) => NotificationItemModel(
          id: n.id,
          title: n.title,
          message: n.message,
          time: n.time,
          category: n.category,
          isUnread: false,
          captainName: n.captainName,
          tripId: n.tripId,
        )).toList();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text(
              'تم تحديد جميع الإشعارات كمقروءة ✔️',
              style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("⚠️ [NotificationsPage] Error marking all as read: $e");
    }
  }

  Future<void> _deleteNotification(NotificationItemModel item, int index) async {
    HapticFeedback.mediumImpact();
    // Optimistic delete
    setState(() {
      _notifications.removeWhere((n) => n.id == item.id);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.gray800,
          duration: const Duration(seconds: 3),
          content: Text(
            'تم حذف الإشعار "${item.title}"',
            style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
          ),
          action: SnackBarAction(
            label: 'تراجع',
            textColor: AppColors.primary500,
            onPressed: () {
              if (mounted) {
                setState(() {
                  _notifications.insert(index, item);
                });
              }
            },
          ),
        ),
      );
    }

    try {
      final dioClient = di.sl<DioClient>();
      await dioClient.dio.delete(ApiEndpoints.notificationDelete(item.id));
    } catch (e) {
      debugPrint("⚠️ [NotificationsPage] Error deleting notification from API: $e");
    }
  }

  Future<void> _clearAllNotifications() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'مسح الإشعارات',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف جميع الإشعارات؟',
          style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'مسح الكل',
              style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final backup = List<NotificationItemModel>.from(_notifications);
    setState(() {
      _notifications.clear();
    });

    try {
      final dioClient = di.sl<DioClient>();
      await dioClient.dio.delete(ApiEndpoints.notificationsClearAll);
    } catch (e) {
      debugPrint("⚠️ [NotificationsPage] Error clearing all notifications: $e");
      if (mounted) {
        setState(() {
          _notifications = backup;
        });
      }
    }
  }

  List<NotificationItemModel> get _filteredNotifications {
    if (_selectedCategoryIndex == 0) return _notifications;
    final categories = [
      null,
      'rides',
      'parcels',
      'offers',
    ];
    if (_selectedCategoryIndex >= categories.length) return _notifications;
    final selectedCat = categories[_selectedCategoryIndex];
    return _notifications.where((n) => n.category == selectedCat).toList();
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8.5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary500.withValues(alpha: 0.14)
              : (isDark
                  ? const Color(0xFF161B26)
                  : AppColors.gray100.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? AppColors.primary500.withValues(alpha: 0.6)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.gray200),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary500.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
            color: isSelected
                ? AppColors.primary500
                : (isDark ? AppColors.gray400 : AppColors.gray600),
          ),
        ),
      ),
    );
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
            AppLocalizations.of(context)?.pass_notifications ?? 'الإشعارات والتنبيهات',
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary500,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.done_all_rounded, color: AppColors.primary500),
              tooltip: 'تحديد الكل كمقروء',
              onPressed: _notifications.isNotEmpty ? _markAllAsRead : null,
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.danger),
              tooltip: 'مسح جميع الإشعارات',
              onPressed: _notifications.isNotEmpty ? _clearAllNotifications : null,
            ),
          ],
        ),
        body: Column(
          children: [
            // ─── Filter Chips (Medium-sized Oval Chips: الكل, الرحلات, الطرود, العروض) ───
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, AppSpacing.s12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: AppLocalizations.of(context)?.pass_all ?? 'الكل',
                      isSelected: _selectedCategoryIndex == 0,
                      isDark: isDark,
                      onTap: () => setState(() => _selectedCategoryIndex = 0),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: AppLocalizations.of(context)?.pass_rides ?? 'الرحلات',
                      isSelected: _selectedCategoryIndex == 1,
                      isDark: isDark,
                      onTap: () => setState(() => _selectedCategoryIndex = 1),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: AppLocalizations.of(context)?.pass_parcels ?? 'الطرود',
                      isSelected: _selectedCategoryIndex == 2,
                      isDark: isDark,
                      onTap: () => setState(() => _selectedCategoryIndex = 2),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: AppLocalizations.of(context)?.pass_offers ?? 'العروض',
                      isSelected: _selectedCategoryIndex == 3,
                      isDark: isDark,
                      onTap: () => setState(() => _selectedCategoryIndex = 3),
                    ),
                  ],
                ),
              ),
            ),

            // Notification List with comfortable spacing
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary500))
                  : RefreshIndicator(
                      color: AppColors.primary500,
                      onRefresh: _fetchNotifications,
                      child: _filteredNotifications.isEmpty
                          ? _buildEmptyState(isDark)
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.s16,
                                AppSpacing.s8,
                                AppSpacing.s16,
                                96,
                              ),
                              itemCount: _filteredNotifications.length,
                              itemBuilder: (context, index) {
                                final item = _filteredNotifications[index];
                                return Dismissible(
                                  key: Key('notif_${item.id}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'حذف',
                                          style: TextStyle(
                                            fontFamily: 'IBM Plex Sans Arabic',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                                      ],
                                    ),
                                  ),
                                  onDismissed: (_) {
                                    _deleteNotification(item, index);
                                  },
                                  child: NotificationCard(
                                    isDark: isDark,
                                    item: item,
                                    onTap: () {
                                      if (item.isUnread) {
                                        _markAsRead(item.id);
                                      }
                                      if (item.tripId != null) {
                                        debugPrint("🚕 [Notification] Navigating to trip ID: ${item.tripId}");
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
              _errorMessage ?? (AppLocalizations.of(context)?.pass_no_notifications ?? 'لا توجد إشعارات حالياً'),
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
