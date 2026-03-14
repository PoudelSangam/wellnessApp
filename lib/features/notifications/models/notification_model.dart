class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // API notification_type
  final String typeDisplay;
  final DateTime timestamp;
  final bool isRead;
  final DateTime? readAt;
  final Map<String, dynamic>? payload;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.typeDisplay,
    required this.timestamp,
    this.isRead = false,
    this.readAt,
    this.payload,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['created_at'] ?? json['timestamp'];
    final readAtValue = json['read_at'];

    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['notification_type'] ?? json['type'] ?? 'system',
      typeDisplay: json['notification_type_display'] ?? '',
      timestamp: _parseDateTime(createdAtValue) ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
      readAt: _parseDateTime(readAtValue),
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'notification_type': type,
      'notification_type_display': typeDisplay,
      'created_at': timestamp.toIso8601String(),
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'payload': payload,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? typeDisplay,
    DateTime? timestamp,
    bool? isRead,
    DateTime? readAt,
    Map<String, dynamic>? payload,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      typeDisplay: typeDisplay ?? this.typeDisplay,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      payload: payload ?? this.payload,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
