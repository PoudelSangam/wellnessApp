import 'package:flutter/material.dart';

class ProgramCard extends StatefulWidget {
  final String title;
  final String description;
  final List<String> items;
  final String duration;
  final String frequency;
  final String? intensity;
  final String? focus;
  final IconData icon;
  final Color color;
  final String programType; // 'physical' or 'mental'
  final List<String>? itemIds;
  final ValueChanged<String>? onItemTap;
  final VoidCallback? onStartWorkout;

  const ProgramCard({
    super.key,
    required this.title,
    required this.description,
    required this.items,
    required this.duration,
    required this.frequency,
    this.intensity,
    this.focus,
    required this.icon,
    required this.color,
    required this.programType,
    this.itemIds,
    this.onItemTap,
    this.onStartWorkout,
  });

  @override
  State<ProgramCard> createState() => _ProgramCardState();
}

class _ProgramCardState extends State<ProgramCard> {
  int _selectedItemIndex = 0;
  bool _showAllItems = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Start Workout Button
            if (widget.onStartWorkout != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onStartWorkout,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Workout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

            if (widget.onStartWorkout != null)
              const SizedBox(height: 16),

            // Items/Activities
            Text(
              widget.intensity != null ? 'Exercises' : 'Activities',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ...(_showAllItems ? widget.items : widget.items.take(5)).toList().asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Builder(
                    builder: (context) {
                      final index = entry.key;
                      final item = entry.value;
                      final canOpenDetail =
                          widget.onItemTap != null &&
                          widget.itemIds != null &&
                          index >= 0 &&
                          index < widget.itemIds!.length;

                      final card = Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedItemIndex == index
                                ? widget.color
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.fitness_center, color: widget.color, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            if (canOpenDetail)
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: widget.color,
                              ),
                          ],
                        ),
                      );

                      if (!canOpenDetail) {
                        return card;
                      }

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedItemIndex = index;
                          });
                          widget.onItemTap!(widget.itemIds![index]);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: card,
                      );
                    },
                  ),
                )),
            if (widget.items.length > 5)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAllItems = !_showAllItems;
                    });
                  },
                  icon: Icon(
                    _showAllItems ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                  ),
                  label: Text(
                    _showAllItems
                        ? 'Show less'
                        : 'Show more (${widget.items.length - 5} more)',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
