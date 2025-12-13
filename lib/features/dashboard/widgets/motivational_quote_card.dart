import 'package:flutter/material.dart';
import 'dart:math';

class MotivationalQuoteCard extends StatelessWidget {
  const MotivationalQuoteCard({super.key});

  static const List<Map<String, String>> _quotes = [
    {
      'quote': 'Take care of your body. It\'s the only place you have to live.',
      'author': 'Jim Rohn',
    },
    {
      'quote': 'The greatest wealth is health.',
      'author': 'Virgil',
    },
    {
      'quote': 'Your body hears everything your mind says. Stay positive.',
      'author': 'Naomi Judd',
    },
    {
      'quote': 'Wellness is the complete integration of body, mind, and spirit.',
      'author': 'Greg Anderson',
    },
    {
      'quote': 'To keep the body in good health is a duty, otherwise we shall not be able to keep our mind strong and clear.',
      'author': 'Buddha',
    },
    {
      'quote': 'The mind and body are not separate. What affects one, affects the other.',
      'author': 'Anonymous',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final quote = _quotes[random.nextInt(_quotes.length)];

    return Card(
      color: Colors.purple[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_quote,
                  color: Colors.purple[300],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Daily Inspiration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              quote['quote']!,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.purple[900],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '— ${quote['author']}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
