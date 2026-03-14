import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
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
  Future<void> fetchNotifications({bool unreadOnly = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiConstants.notifications,
        queryParams: unreadOnly ? {'unread_only': 'true'} : null,
      );

      final data = response['data'] ?? response['results'] ?? response;
      if (data is List) {
        _notifications = data
            .whereType<Map<String, dynamic>>()
            .map(NotificationModel.fromJson)
            .toList();
      } else {
        _notifications = [];
      }

      Logger.info('Fetched ${_notifications.length} notifications');
    } catch (e) {
      _error = e.toString();
      Logger.error('Error fetching notifications: $e');
      _notifications = [];
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

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
