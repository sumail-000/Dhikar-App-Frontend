import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'services/api_client.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedFilter = 'Individual';
  final List<String> _filters = ['Individual', 'Group', 'Motivational'];
  
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String? _error;

  List<NotificationItem> get _filteredNotifications {
    return _notifications.where((notification) {
      return notification.type == _selectedFilter;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiClient.instance.getNotifications();
      if (response.ok && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final notificationsList = data['notifications'] as List?;
        
        if (notificationsList != null) {
          _notifications = notificationsList.map<NotificationItem>((notif) {
            return NotificationItem.fromMap(notif as Map<String, dynamic>);
          }).toList();
        }
      } else {
        _error = response.error ?? 'Failed to load notifications';
      }
    } catch (e) {
      _error = 'Network error: $e';
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(NotificationItem notification) async {
    try {
      final response = await ApiClient.instance.markNotificationAsRead(notification.id);
      if (response.ok) {
        // Update local state
        setState(() {
          notification.isRead = true;
        });
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> _deleteNotification(NotificationItem notification) async {
    try {
      final response = await ApiClient.instance.deleteNotification(notification.id);
      if (response.ok) {
        // Remove from local state
        setState(() {
          _notifications.remove(notification);
        });
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    final unreadNotifications = _notifications.where((n) => !n.isRead).toList();
    
    for (final notification in unreadNotifications) {
      await _markAsRead(notification);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isArabic = languageProvider.isArabic;
        final isDarkMode = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isArabic
                                ? Icons.arrow_forward_ios
                                : Icons.arrow_back_ios,
                            color: isDarkMode ? Colors.white : Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          isArabic ? 'الإشعارات' : 'Notifications',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontFamily: isArabic ? 'Amiri' : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: _markAllAsRead,
                        tooltip: isArabic ? 'تحديد الكل كمقروء' : 'Mark all read',
                        icon: Icon(
                          Icons.done_all,
                          size: 20,
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.85)
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDarkMode
                                        ? const Color(0xFF2D1B69)
                                        : const Color(0xFF2E7D32))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? (isDarkMode
                                          ? const Color(0xFF2D1B69)
                                          : const Color(0xFF2E7D32))
                                    : (isDarkMode
                                          ? Colors.white.withOpacity(0.25)
                                          : Colors.grey.shade300),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getFilterText(filter, isArabic),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                fontFamily: isArabic ? 'Amiri' : null,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Notifications content
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(
                              child: Text(
                                _error!,
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            )
                          : _filteredNotifications.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 80,
                                color: isDarkMode
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                isArabic
                                    ? 'لا توجد إشعارات متاحة'
                                    : 'No available notifications',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.grey.shade600,
                                  fontFamily: isArabic ? 'Amiri' : null,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isArabic
                                    ? 'ستظهر الإشعارات هنا عند توفرها'
                                    : 'Notifications will appear here when available',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.grey.shade500,
                                  fontFamily: isArabic ? 'Amiri' : null,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          itemCount: _filteredNotifications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final notification = _filteredNotifications[index];
                            return Dismissible(
                              key: ValueKey('notif_${notification.id}_${notification.time}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                color: Colors.redAccent,
                                child: const Icon(Icons.delete, color: Colors.white, size: 18),
                              ),
                              onDismissed: (_) => _deleteNotification(notification),
                              child: InkWell(
                                onTap: () => _markAsRead(notification),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.grey.shade800
                                        : notification.backgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDarkMode
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? notification.iconColor.withOpacity(0.18)
                                              : notification.iconColor.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          notification.icon,
                                          color: notification.iconColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notification.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: isDarkMode ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              notification.subtitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDarkMode
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!notification.isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2E7D32),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      Text(
                                        notification.time,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFilterText(String filter, bool isArabic) {
    switch (filter) {
      case 'Individual':
        return isArabic ? 'فردي' : 'Individual';
      case 'Group':
        return isArabic ? 'مجموعة' : 'Group';
      case 'Motivational':
        return isArabic ? 'تحفيزي' : 'Motivational';
      default:
        return filter;
    }
  }
}

class NotificationItem {
  final int id;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.type,
    this.isRead = false,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    final type = (map['type'] ?? 'Individual') as String;
    final color = _typeColor(type);
    return NotificationItem(
      id: (map['id'] ?? 0) as int,
      title: (map['title'] ?? '') as String,
      subtitle: (map['body'] ?? map['subtitle'] ?? '') as String,
      time: _formatTime(map['created_at'] as String?),
      icon: _typeIcon(type),
      backgroundColor: color.withOpacity(0.12),
      iconColor: color,
      type: _mapTypeToFilter(type),
      isRead: (map['read_at'] != null),
    );
  }

  static String _mapTypeToFilter(String backendType) {
    switch (backendType) {
      // Juz assignments are Group notifications
      case 'juz_assignment':
      case 'juz_assignment_auto':
      case 'juz_assignment_manual':
        return 'Group';
      // Motivational verses are Motivational notifications  
      case 'motivational_verse':
        return 'Motivational';
      // Individual member reminders are Individual notifications
      case 'group_khitma_reminder':
      case 'dhikr_group_reminder':
      case 'group_reminder':
      case 'individual_reminder':
        return 'Individual';
      default:
        return 'Individual';
    }
  }

  static Color _typeColor(String type) {
    // First check for specific type
    switch (type) {
      // Juz assignment notifications (Group category)
      case 'juz_assignment':
      case 'juz_assignment_auto':
      case 'juz_assignment_manual':
        return const Color(0xFF1565C0); // Blue color for Juz assignments
      // Motivational verse notifications (Motivational category)
      case 'motivational_verse':
        return const Color(0xFF2E7D32); // Green color for motivational verses
      // Individual reminder notifications (Individual category)
      case 'group_khitma_reminder':
      case 'dhikr_group_reminder':
      case 'group_reminder':
      case 'individual_reminder':
        return const Color(0xFF00796B); // Teal color for individual reminders
      default:
        // Fall back to general category mapping
        switch (_mapTypeToFilter(type)) {
          case 'Group':
            return const Color(0xFF1565C0);
          case 'Motivational':
            return const Color(0xFF2E7D32);
          default:
            return const Color(0xFF00796B);
        }
    }
  }

  static IconData _typeIcon(String type) {
    // First check for specific type
    switch (type) {
      // Juz assignment notifications (Group category)
      case 'juz_assignment':
      case 'juz_assignment_auto':
      case 'juz_assignment_manual':
        return Icons.menu_book; // Book icon for Juz assignments
      // Motivational verse notifications (Motivational category)
      case 'motivational_verse':
        return Icons.auto_awesome; // Star icon for motivational verses
      // Individual reminder notifications (Individual category)
      case 'group_khitma_reminder':
      case 'dhikr_group_reminder':
      case 'group_reminder':
      case 'individual_reminder':
        return Icons.person_pin; // Person pin icon for individual reminders
      default:
        // Fall back to general category mapping
        switch (_mapTypeToFilter(type)) {
          case 'Group':
            return Icons.menu_book;
          case 'Motivational':
            return Icons.auto_awesome;
          default:
            return Icons.person_pin;
        }
    }
  }

  static String _formatTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.tryParse(isoString)?.toLocal();
      if (dt == null) return '';
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}

class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final random = Random(42);

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 30 + 10;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
