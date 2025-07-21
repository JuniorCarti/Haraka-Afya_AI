import 'package:flutter/material.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Subscription Plans',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0C6D5B),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unlock Premium Healthcare\nChoose the plan that works best for you',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
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
              buttonText: 'Current Plan',
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
              buttonText: 'Upgrade Now',
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
              buttonText: 'Select Plan',
            ),
            
            const SizedBox(height: 32),
            const Divider(height: 1),
            const SizedBox(height: 24),
            
            // Payment Methods Section
            const Text(
              'Payment Methods',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
                _buildPaymentMethod('VISA'),
                _buildPaymentMethod('Mastercard'),
              ],
            ),
            
            const SizedBox(height: 24),
            _buildInfoRow(Icons.lock, 'Secure payments powered by Stripe'),
            _buildInfoRow(Icons.credit_card, 'Support for Visa cards and mobile money'),
            _buildInfoRow(Icons.cancel, 'Cancel anytime through customer portal'),
            _buildInfoRow(Icons.money, '30-day money back guarantee'),
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
    required String buttonText,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: isCurrent 
              ? Border.all(color: const Color(0xFF0C6D5B), width: 2)
              : null,
          borderRadius: BorderRadius.circular(12),
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
                    'MOST POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: features
                    .map((feature) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            feature,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrent 
                        ? Colors.grey[300]
                        : const Color(0xFF0C6D5B),
                    foregroundColor: isCurrent 
                        ? Colors.black
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String method) {
    return Chip(
      label: Text(
        method,
        style: const TextStyle(fontSize: 14),
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}