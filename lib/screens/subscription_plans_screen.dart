import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFF3F8F7), Color(0xFFF9FCF5)],
          ),
        ),
        child: SafeArea(
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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unlock Premium Healthcare',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose the plan that works best for you',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),

                // Free Plan
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildPlanCard(
                    title: 'Free',
                    price: '\$0.00',
                    subPriceText: 'Forever',
                    description: 'Basic health tips and limited AI consultations',
                    features: [
                      '5 AI consultations per month',
                      'Basic health tips',
                      'Symptom checker',
                      'Find nearby hospitals',
                    ],
                    buttonColor: Colors.white,
                    textColor: Colors.black,
                    borderColor: Colors.grey.shade300,
                    isPopular: false,
                  ),
                ),
                const SizedBox(height: 16),

                // Premium Plan (FIXED: text now black for visibility)
                _buildPlanCard(
                  title: 'Premium',
                  price: '\$7.99',
                  description: 'Unlimited AI consultations and advanced features',
                  features: [
                    'Unlimited AI consultations',
                    'Personalized health insights',
                    'Medication reminders',
                  ],
                  buttonColor: const Color(0xFF16A249),
                  textColor: Colors.black, // 👈 FIXED TEXT COLOR
                  isPopular: true,
                ),

                const SizedBox(height: 16),

                // Family Plan
                _buildFamilyCard(),

                const SizedBox(height: 24),
                _buildPaymentMethods(),
                const SizedBox(height: 24),
                _buildInfoRow(Icons.lock, 'Secure payments powered by Stripe'),
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
    String? subPriceText,
    required String description,
    required List<String> features,
    required Color buttonColor,
    required Color textColor,
    Color? borderColor,
    required bool isPopular,
  }) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            if (subPriceText != null)
              Text(subPriceText, style: TextStyle(color: textColor.withOpacity(0.7))),
            if (isPopular)
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A249),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.star, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Most Popular', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(description, style: TextStyle(color: textColor.withOpacity(0.7))),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF8FCF9),
                    ),
                    child: const Icon(Icons.check, color: Color(0xFF17A249), size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature, style: TextStyle(fontSize: 16, color: textColor))),
                ],
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: buttonColor == Colors.white ? textColor : Colors.white,
                  side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {},
                child: const Text('Choose Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyCard() {
    return _buildPlanCard(
      title: 'Family',
      price: '\$14.99',
      description: 'Perfect for families with up to 6 members',
      features: [
        'Everything in Premium',
        'Up to 6 family members',
        'Family health dashboard',
        'Shared medication tracking',
        'Emergency contacts'
      ],
      buttonColor: Colors.white,
      textColor: Colors.black,
      borderColor: Colors.grey.shade300,
      isPopular: false,
    );
  }

  Widget _buildPaymentMethods() {
    final List<String> logos = [
      'assets/mpesa.png',
      'assets/airtel.png',
      'assets/stripe.png',
      'assets/paypal.png'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Methods', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: logos.map((logo) => Image.asset(logo, height: 40)).toList(),
        )
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.black54))),
      ],
    );
  }
}
