import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Privacy Policy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'We value your privacy. This policy explains how we collect, use, '
            'and protect your information.\n\n'
            'Information We Collect\n'
            '• Account details (name, email)\n'
            '• Wellness data you provide\n'
            '• Usage analytics for improving the app\n\n'
            'How We Use Information\n'
            '• To personalize your wellness experience\n'
            '• To deliver recommendations and reminders\n'
            '• To improve app performance and security\n\n'
            'Contact us if you have any questions about this policy.',
          ),
        ],
      ),
    );
  }
}
