import 'package:flutter/material.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        backgroundColor: const Color(0xFF0C6D5B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Your Plan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unlock Premium Healthcare\nChoose the plan that works best for you',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Free Plan Card
            _buildPlanCard(
              title: 'Free',
              description: 'Basic health tips and limited AI consultations',
              features: const [
                '✓ 5 AI consultations per month',
                '✓ Basic health tips',
                '✓ Symptom checker',
                '✓ Find nearby hospitals',
              ],
              isCurrent: false,
              isPopular: false,
              price: 'Free',
            ),
            
            const SizedBox(height: 16),
            
            // Premium Plan Card
            _buildPlanCard(
              title: 'Premium',
              description: 'Unlimited AI consultations and advanced features',
              features: const [
                '✓ Unlimited AI consultations',
                '✓ Personalized health insights',
                '✓ Medication reminders',
                '✓ Health history tracking',
                '✓ Priority support',
                '✓ Telemedicine consultations',
              ],
              isCurrent: true,
              isPopular: true,
              price: '\$7.99 per month',
            ),
            
            const SizedBox(height: 16),
            
            // Family Plan Card
            _buildPlanCard(
              title: 'Family',
              description: 'Perfect for families with up to 6 members',
              features: const [
                '✓ Everything in Premium',
                '✓ Up to 6 family members',
                '✓ Family health dashboard',
                '✓ Shared medication tracking',
                '✓ Emergency contacts',
                '✓ Family health reports',
              ],
              isCurrent: false,
              isPopular: false,
              price: '\$12.99 per month',
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Payment Methods Section
            const Text(
              'Payment Methods',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPaymentMethod('APP'),
                _buildPaymentMethod('DD'),
                _buildPaymentMethod('M-PESA'),
                _buildPaymentMethod('Airtel Money'),
              ],
            ),
            
            const SizedBox(height: 16),
            const Text(
              'Secure payments powered by Stripe',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Support for Visa cards and mobile money',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cancel anytime through customer portal',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              '30-day money back guarantee',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String description,
    required List<String> features,
    required bool isCurrent,
    required bool isPopular,
    required String price,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrent 
            ? const BorderSide(color: Color(0xFF0C6D5B), width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C6D5B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Most Popular',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features
                  .map((feature) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(feature),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              price,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C6D5B),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(isCurrent ? 'Current Plan' : 'Select Plan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String method) {
    return Chip(
      label: Text(method),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}