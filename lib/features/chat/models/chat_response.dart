class ChatResponse {
  final String response;
  final DateTime timestamp;

  const ChatResponse({
    required this.response,
    required this.timestamp,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    final timestampValue = json['timestamp'];
    final parsedTimestamp = timestampValue is String
        ? DateTime.tryParse(timestampValue)
        : null;

    return ChatResponse(
      response: (json['response'] ?? '').toString(),
      timestamp: parsedTimestamp ?? DateTime.now(),
    );
  }
}
