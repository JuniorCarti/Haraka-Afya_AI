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
  String _selectedPaymentMethod = 'PayPal';
  bool _isButtonHovered = false;

  void _selectPlan(String plan) {
    setState(() {
      _selectedPlan = plan;
    });
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  Future<void> _startPayment() async {
    final amount = _selectedPlan == 'Premium'
        ? '7.99'
        : _selectedPlan == 'Family'
            ? '14.99'
            : '0.00';

    String paymentUrl;
    switch (_selectedPaymentMethod) {
      case 'PayPal':
        paymentUrl = 'http://10.0.2.2:3000/create-paypal-order';
        break;
      case 'M-Pesa':
        paymentUrl = 'http://10.0.2.2:3000/create-mpesa-order';
        break;
      case 'Airtel Money':
        paymentUrl = 'http://10.0.2.2:3000/create-airtel-order';
        break;
      case 'Stripe':
        paymentUrl = 'http://10.0.2.2:3000/create-stripe-order';
        break;
      default:
        paymentUrl = '';
    }

    try {
      final response = await http.post(
        Uri.parse(paymentUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Redirecting to $_selectedPaymentMethod...')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start $_selectedPaymentMethod payment.')),
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4285F4), // Blue
                Color(0xFF34A853), // Green
                Color(0xFFFBBC05), // Yellow
                Color(0xFFEA4335), // Red
              ],
              stops: [0.0, 0.3, 0.6, 1.0],
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
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white70,
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Choose Your Plan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unlock Premium Healthcare',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose the plan that works best for you',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
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
                  
                  // Payment Methods Section
                  Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        const SizedBox(width: 8),
                        _buildPaymentMethodCard(
                          name: 'PayPal',
                          logo: 'assets/paypal.png',
                          selected: _selectedPaymentMethod == 'PayPal',
                          onSelect: () => _selectPaymentMethod('PayPal'),
                        ),
                        _buildPaymentMethodCard(
                          name: 'M-Pesa',
                          logo: 'assets/mpesa.png',
                          selected: _selectedPaymentMethod == 'M-Pesa',
                          onSelect: () => _selectPaymentMethod('M-Pesa'),
                        ),
                        _buildPaymentMethodCard(
                          name: 'Airtel Money',
                          logo: 'assets/airtel.png',
                          selected: _selectedPaymentMethod == 'Airtel Money',
                          onSelect: () => _selectPaymentMethod('Airtel Money'),
                        ),
                        _buildPaymentMethodCard(
                          name: 'Stripe',
                          logo: 'assets/stripe.png',
                          selected: _selectedPaymentMethod == 'Stripe',
                          onSelect: () => _selectPaymentMethod('Stripe'),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  MouseRegion(
                    onEnter: (_) => setState(() => _isButtonHovered = true),
                    onExit: (_) => setState(() => _isButtonHovered = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: _isButtonHovered
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF4285F4), // Blue
                                  Color(0xFF34A853), // Green
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.white,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _startPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: _isButtonHovered
                              ? Colors.white
                              : const Color(0xFF4285F4),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: Text(
                          'Proceed to $_selectedPaymentMethod',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
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
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4285F4), // Blue
                            Color(0xFF34A853), // Green
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Most Popular',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            color: selected ? const Color(0xFF4285F4) : Colors.grey[400],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String name,
    required String logo,
    required bool selected,
    required VoidCallback onSelect,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onSelect,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(logo),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      color: selected ? const Color(0xFF4285F4) : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}