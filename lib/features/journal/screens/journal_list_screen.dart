import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/logger.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/journal_entry.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  final ApiService _apiService = ApiService();
  final List<JournalEntry> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCreating = false;
  bool _isFetchingGuide = false;

  static const Map<String, String> _cognitiveDistortionOptions = {
    'all_or_nothing': 'All-or-Nothing Thinking',
    'catastrophizing': 'Catastrophizing',
    'disqualifying_positive': 'Disqualifying the Positive',
    'emotional_reasoning': 'Emotional Reasoning',
    'fortune_telling': 'Fortune Telling',
    'jumping_to_conclusions': 'Jumping to Conclusions',
    'labeling': 'Labeling',
    'mental_filter': 'Mental Filter',
    'mind_reading': 'Mind Reading',
    'overgeneralization': 'Overgeneralization',
    'personalization': 'Personalization',
    'should_statements': '"Should" Statements',
  };

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  Future<void> _fetchEntries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final response = await _apiService.get(
        ApiConstants.journalEntries,
        headers: ApiConstants.getHeaders(token: authProvider.accessToken),
      );

      final data = response['data'] ?? response['results'] ?? response;
      if (data is List) {
        _entries
          ..clear()
          ..addAll(
            data
                .whereType<Map<String, dynamic>>()
                .map(JournalEntry.fromJson),
          );
      } else {
        _entries.clear();
      }

      Logger.success('Journal entries fetched: ${_entries.length}');
    } catch (e) {
      Logger.error('Journal fetch error: $e');
      _errorMessage = 'Failed to load journal entries.';
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: _isFetchingGuide
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.help_outline),
            onPressed: _isFetchingGuide ? null : _showCbtGuide,
            tooltip: 'CBT Guide',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchEntries,
          ),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isCreating ? null : _openCreateJournal,
        icon: _isCreating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: const Text('Add Journal'),
      ),
    );
  }

  Future<void> _showCbtGuide() async {
    setState(() {
      _isFetchingGuide = true;
    });

    try {
      final response = await _apiService.get(ApiConstants.journalCbtGuide);
      if (!mounted) {
        return;
      }

      final title = (response['title'] ?? 'CBT Guide').toString();
      final summary = (response['summary'] ?? '').toString();
      final steps = response['steps'] is List ? response['steps'] as List : [];

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (summary.isNotEmpty) Text(summary),
                if (summary.isNotEmpty) const SizedBox(height: 12),
                if (steps.isNotEmpty)
                  const Text(
                    'Steps',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                for (final step in steps)
                  if (step is Map<String, dynamic>)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${step['step'] ?? ''}. ${step['title'] ?? ''}\n'
                        '${step['instruction'] ?? ''}',
                      ),
                    ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load CBT guide: $e')),
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isFetchingGuide = false;
      });
    }
  }

  Future<void> _openCreateJournal() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final situationController = TextEditingController();
    final automaticThoughtController = TextEditingController();
    final Set<String> selectedDistortions = {};
    final evidenceForController = TextEditingController();
    final evidenceAgainstController = TextEditingController();
    final balancedThoughtController = TextEditingController();
    final behavioralResponseController = TextEditingController();
    int mood = 1;
    int emotionBefore = 50;
    int emotionAfter = 50;
    bool isFavorite = false;
    bool isArchived = false;
    final entryDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final shouldCreate = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: viewInsets.bottom + 16,
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(false),
                        tooltip: 'Back',
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'New Journal Entry',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: mood,
                    decoration: const InputDecoration(
                      labelText: 'Mood (1-5)',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Very Low')),
                      DropdownMenuItem(value: 2, child: Text('Low')),
                      DropdownMenuItem(value: 3, child: Text('Neutral')),
                      DropdownMenuItem(value: 4, child: Text('Good')),
                      DropdownMenuItem(value: 5, child: Text('Great')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        mood = value;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: situationController,
                    decoration: const InputDecoration(
                      labelText: 'Situation',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: automaticThoughtController,
                    decoration: const InputDecoration(
                      labelText: 'Automatic Thought',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cognitive Distortions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  StatefulBuilder(
                    builder: (context, setChipState) => Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _cognitiveDistortionOptions.entries.map((entry) {
                        return FilterChip(
                          label: Text(entry.value),
                          selected: selectedDistortions.contains(entry.key),
                          onSelected: (selected) {
                            setChipState(() {
                              if (selected) {
                                selectedDistortions.add(entry.key);
                              } else {
                                selectedDistortions.remove(entry.key);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: evidenceForController,
                    decoration: const InputDecoration(
                      labelText: 'Evidence For',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: evidenceAgainstController,
                    decoration: const InputDecoration(
                      labelText: 'Evidence Against',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: balancedThoughtController,
                    decoration: const InputDecoration(
                      labelText: 'Balanced Thought',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: behavioralResponseController,
                    decoration: const InputDecoration(
                      labelText: 'Behavioral Response',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: emotionBefore,
                    decoration: const InputDecoration(
                      labelText: 'Emotion Intensity Before (0-100)',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      11,
                      (index) => DropdownMenuItem(
                        value: index * 10,
                        child: Text('${index * 10}'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        emotionBefore = value;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: emotionAfter,
                    decoration: const InputDecoration(
                      labelText: 'Emotion Intensity After (0-100)',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      11,
                      (index) => DropdownMenuItem(
                        value: index * 10,
                        child: Text('${index * 10}'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        emotionAfter = value;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Favorite'),
                    value: isFavorite,
                    onChanged: (value) {
                      isFavorite = value;
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Archived'),
                    value: isArchived,
                    onChanged: (value) {
                      isArchived = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Create'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (shouldCreate != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    await _createEntry(
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      mood: mood,
      entryDate: entryDate,
      situation: situationController.text.trim(),
      automaticThought: automaticThoughtController.text.trim(),
      cognitiveDistortionKeys: selectedDistortions.toList(),
      evidenceFor: evidenceForController.text.trim(),
      evidenceAgainst: evidenceAgainstController.text.trim(),
      balancedThought: balancedThoughtController.text.trim(),
      behavioralResponse: behavioralResponseController.text.trim(),
      emotionIntensityBefore: emotionBefore,
      emotionIntensityAfter: emotionAfter,
      isFavorite: isFavorite,
      isArchived: isArchived,
    );
  }

  Future<void> _createEntry({
    required String title,
    required String content,
    required int mood,
    required String entryDate,
    required String situation,
    required String automaticThought,
    required List<String> cognitiveDistortionKeys,
    required String evidenceFor,
    required String evidenceAgainst,
    required String balancedThought,
    required String behavioralResponse,
    required int emotionIntensityBefore,
    required int emotionIntensityAfter,
    required bool isFavorite,
    required bool isArchived,
  }) async {
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content are required.')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final headers = ApiConstants.getHeaders(token: authProvider.accessToken);

      final distortionLabels = cognitiveDistortionKeys
          .map((k) => _cognitiveDistortionOptions[k] ?? k)
          .toList();

      await _apiService.post(
        ApiConstants.journalEntries,
        headers: headers,
        body: {
          'title': title,
          'content': content,
          'mood': mood,
          'entry_date': entryDate,
          'is_favorite': isFavorite,
          'is_archived': isArchived,
          'situation': situation,
          'automatic_thought': automaticThought,
          'emotion_intensity_before': emotionIntensityBefore,
          'cognitive_distortions': cognitiveDistortionKeys,
          'cognitive_distortion_labels': distortionLabels,
          'evidence_for': evidenceFor,
          'evidence_against': evidenceAgainst,
          'balanced_thought': balancedThought,
          'emotion_intensity_after': emotionIntensityAfter,
          'behavioral_response': behavioralResponse,
        },
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal entry created.')),
      );
      await _fetchEntries();
    } catch (e) {
      if (!mounted) {
        return;
      }
      final message = _formatApiError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create entry: $message')),
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isCreating = false;
      });
    }
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_entries.isEmpty) {
      return const Center(child: Text('No journal entries yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return Card(
          child: ListTile(
            title: Text(entry.title.isEmpty ? 'Untitled' : entry.title),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                entry.excerpt.isNotEmpty ? entry.excerpt : entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (entry.moodLabel.isNotEmpty)
                  Text(
                    entry.moodLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 4),
                Text(
                  entry.entryDate,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            leading: entry.isFavorite
                ? const Icon(Icons.star, color: Colors.amber)
                : const Icon(Icons.book_outlined),
          ),
        );
      },
    );
  }

  String _formatApiError(Object error) {
    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        final detail = responseData['detail'];
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map<String, dynamic> && first['msg'] != null) {
            return first['msg'].toString();
          }
        }

        if (responseData['message'] != null) {
          return responseData['message'].toString();
        }
      }

      if (responseData != null) {
        return responseData.toString();
      }
    }

    return error.toString();
  }
}
