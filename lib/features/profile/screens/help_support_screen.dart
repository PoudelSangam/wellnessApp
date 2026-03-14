import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Need help? We are here for you.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Email: support@sangam1313.com.np\n'
            'Phone: +977-000000000\n'
            'Hours: 9:00 AM - 6:00 PM (NST)',
          ),
          SizedBox(height: 20),
          Text(
            'FAQ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text('• How do I update my profile?\n'
              '• How do I reset my password?\n'
              '• Why is a workout missing?\n'
              '• How do I delete my account?'),
        ],
      ),
    );
  }
}
