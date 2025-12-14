import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/logger.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  
  List<NotificationModel> get readNotifications => 
      _notifications.where((n) => n.isRead).toList();

  // Fetch notifications from API
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For now, using mock data since backend might not have this endpoint yet
      // Uncomment below when backend is ready
      // final response = await _apiService.get('/api/notifications/');
      // _notifications = (response['results'] as List)
      //     .map((json) => NotificationModel.fromJson(json))
      //     .toList();
      
      // Mock notifications
      _notifications = _generateMockNotifications();
      
      Logger.info('Fetched ${_notifications.length} notifications');
    } catch (e) {
      _error = e.toString();
      Logger.error('Error fetching notifications: $e');
      
      // Use mock data on error
      _notifications = _generateMockNotifications();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      // Update locally first
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }

      // Update on backend
      // await _apiService.post('/api/notifications/$notificationId/read/');
      
      Logger.info('Marked notification $notificationId as read');
    } catch (e) {
      Logger.error('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      notifyListeners();

      // Update on backend
      // await _apiService.post('/api/notifications/read-all/');
      
      Logger.info('Marked all notifications as read');
    } catch (e) {
      Logger.error('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();

      // Delete from backend
      // await _apiService.delete('/api/notifications/$notificationId/');
      
      Logger.info('Deleted notification $notificationId');
    } catch (e) {
      Logger.error('Error deleting notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAll() async {
    try {
      _notifications.clear();
      notifyListeners();

      // Clear from backend
      // await _apiService.delete('/api/notifications/clear-all/');
      
      Logger.info('Cleared all notifications');
    } catch (e) {
      Logger.error('Error clearing notifications: $e');
    }
  }

  // Generate mock notifications for demonstration
  List<NotificationModel> _generateMockNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: '1',
        title: 'Workout Reminder',
        message: 'Time for your morning workout! Complete "Full Body Strength"',
        type: 'workout',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'Achievement Unlocked! 🎉',
        message: 'You\'ve completed 5 workouts this week!',
        type: 'achievement',
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: 'Mindfulness Session',
        message: 'Don\'t forget your evening meditation at 7 PM',
        type: 'reminder',
        timestamp: now.subtract(const Duration(hours: 8)),
        isRead: false,
      ),
      NotificationModel(
        id: '4',
        title: 'Weekly Progress Report',
        message: 'Your weekly wellness report is ready to view',
        type: 'system',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        title: 'New Workout Available',
        message: 'Check out the new "Yoga Flow" program',
        type: 'workout',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: '6',
        title: 'Hydration Reminder 💧',
        message: 'Remember to drink water! Stay hydrated',
        type: 'reminder',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      NotificationModel(
        id: '7',
        title: 'Streak Alert! 🔥',
        message: 'You\'re on a 7-day workout streak! Keep it up!',
        type: 'achievement',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ];
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
