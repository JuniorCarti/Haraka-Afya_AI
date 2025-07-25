import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  String _selectedPlan = 'Premium';

  void _selectPlan(String plan) {
    setState(() {
      _selectedPlan = plan;
    });
  }

  Future<void> _startPayment() async {
    final amount = _selectedPlan == 'Premium'
        ? '7.99'
        : _selectedPlan == 'Family'
            ? '14.99'
            : '0.00';

    final url = Uri.parse('http://10.0.2.2:3000/create-order'); // Use 10.0.2.2 for Android emulator; use real IP for physical device
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount}),
      );

      final data = jsonDecode(response.body);
      final approvalUrl = data['links']?.firstWhere(
        (link) => link['rel'] == 'approve',
        orElse: () => null,
      )?['href'];

      if (approvalUrl != null) {
        // Open the URL in browser or WebView for user approval
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Redirecting to PayPal...')),
        );
        // You can use `url_launcher` or `webview_flutter` to handle approvalUrl
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start PayPal payment.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFD8FBE5),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Choose Your Plan',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unlock Premium Healthcare',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose the plan that works best for you',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                _buildPlanCard(
                  title: 'Free',
                  price: '\$0.00',
                  description: 'Basic health tips and limited AI consultations',
                  features: [
                    '5 AI consultations per month',
                    'Basic health tips',
                    'Symptom checker',
                    'Find nearby hospitals',
                  ],
                  selected: _selectedPlan == 'Free',
                  onSelect: () => _selectPlan('Free'),
                ),
                const SizedBox(height: 16),
                _buildPlanCard(
                  title: 'Premium',
                  price: '\$7.99',
                  description: 'Unlimited AI consultations and advanced features',
                  features: [
                    'Unlimited AI consultations',
                    'Personalized health insights',
                    'Medication reminders',
                  ],
                  isPopular: true,
                  selected: _selectedPlan == 'Premium',
                  onSelect: () => _selectPlan('Premium'),
                ),
                const SizedBox(height: 16),
                _buildPlanCard(
                  title: 'Family',
                  price: '\$14.99',
                  description: 'Perfect for families with up to 6 members',
                  features: [
                    'Everything in Premium',
                    'Up to 6 family members',
                    'Family health dashboard',
                    'Shared medication tracking',
                    'Emergency contacts',
                  ],
                  selected: _selectedPlan == 'Family',
                  onSelect: () => _selectPlan('Family'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF259A4F),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Proceed to PayPal', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String description,
    required List<String> features,
    required bool selected,
    required VoidCallback onSelect,
    bool isPopular = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? const Color(0xFF259A4F) : Colors.grey.shade300, width: 2),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPopular)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF259A4F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Most Popular', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 12),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: Color(0xFF259A4F), size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(feature, style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
