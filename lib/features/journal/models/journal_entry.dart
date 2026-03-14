class JournalEntry {
  final int id;
  final String title;
  final String content;
  final String excerpt;
  final String moodLabel;
  final String entryDate;
  final bool isFavorite;
  final bool isArchived;

  const JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.moodLabel,
    required this.entryDate,
    required this.isFavorite,
    required this.isArchived,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: (json['id'] ?? 0) as int,
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      excerpt: (json['excerpt'] ?? '').toString(),
      moodLabel: (json['mood_label'] ?? '').toString(),
      entryDate: (json['entry_date'] ?? '').toString(),
      isFavorite: (json['is_favorite'] ?? false) == true,
      isArchived: (json['is_archived'] ?? false) == true,
    );
  }
}
