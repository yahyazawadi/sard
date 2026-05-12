import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../custom/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/sard_background.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    // Dummy notification data
    final notifications = [
      {
        'title': 'Order Delivered',
        'body': 'Your order #SARD-1234 has been delivered successfully. Enjoy your purchase!',
        'time': '2h ago',
        'icon': Icons.local_shipping_rounded,
        'color': Colors.green,
        'isRead': false,
      },
      {
        'title': 'Special Offer!',
        'body': 'Get 20% off on all colored boxes today! Use code BOX20 at checkout.',
        'time': '5h ago',
        'icon': Icons.local_offer_rounded,
        'color': Colors.orange,
        'isRead': false,
      },
      {
        'title': 'Wishlist Update',
        'body': 'A product in your wishlist is now back in stock!',
        'time': 'Yesterday',
        'icon': Icons.favorite_rounded,
        'color': Colors.red,
        'isRead': true,
      },
      {
        'title': 'New Collection',
        'body': 'The "Sard Icons" collection has been updated with new unique items.',
        'time': '2 days ago',
        'icon': Icons.new_releases_rounded,
        'color': AppTheme.gradientStart,
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.notificationsTitle,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SardBackground(
        child: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 80,
                    color: onSurface.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noNotifications,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isRead = notification['isRead'] as bool;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isRead 
                          ? theme.colorScheme.surface 
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isRead 
                            ? theme.dividerColor.withValues(alpha: 0.05) 
                            : AppTheme.gradientStart.withValues(alpha: 0.2),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (notification['color'] as Color).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          notification['icon'] as IconData,
                          color: notification['color'] as Color,
                          size: 24,
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] as String,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            notification['time'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          notification['body'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: onSurface.withValues(alpha: 0.7),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
