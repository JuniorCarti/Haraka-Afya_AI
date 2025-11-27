import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  String _selectedPlan = 'Premium';
  String _selectedPaymentMethod = 'M-Pesa';
  bool _isButtonHovered = false;
  bool _isProcessingPayment = false;

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

  // M-Pesa Payment Function
  Future<void> _processMpesaPayment() async {
    if (_selectedPlan == 'Free') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Free plan activated successfully!')),
      );
      return;
    }

    // Show phone number input dialog for M-Pesa
    final phoneNumber = await _showPhoneNumberDialog();
    if (phoneNumber == null || phoneNumber.isEmpty) return;

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final amount = _selectedPlan == 'Premium' ? 7.99 : 14.99;
      
      // Direct M-Pesa integration
      final result = await _initiateMpesaSTKPush(
        phoneNumber: phoneNumber,
        amount: amount,
        plan: _selectedPlan,
      );

      if (result['ResponseCode'] == '0') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('M-Pesa payment initiated! Check your phone to complete.'),
            duration: Duration(seconds: 5),
          ),
        );
        
        // Wait a bit then navigate back
        await Future.delayed(Duration(seconds: 3));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('M-Pesa payment failed: ${result['ResponseDescription']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment error: $e')),
      );
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  // M-Pesa STK Push Implementation
  Future<Map<String, dynamic>> _initiateMpesaSTKPush({
    required String phoneNumber,
    required double amount,
    required String plan,
  }) async {
    final consumerKey = dotenv.get('MPESA_CONSUMER_KEY');
    final consumerSecret = dotenv.get('MPESA_CONSUMER_SECRET');
    final businessShortCode = dotenv.get('MPESA_BUSINESS_SHORTCODE');
    final passKey = dotenv.get('MPESA_PASSKEY');
    
    // Get access token
    final credentials = base64.encode(utf8.encode('$consumerKey:$consumerSecret'));
    final tokenResponse = await http.get(
      Uri.parse('https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials'),
      headers: {'Authorization': 'Basic $credentials'},
    );

    if (tokenResponse.statusCode != 200) {
      throw Exception('Failed to get access token');
    }

    final accessToken = json.decode(tokenResponse.body)['access_token'];

    // Generate timestamp and password
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final password = base64.encode(utf8.encode('$businessShortCode$passKey$timestamp'));

    // Format phone number
    String formattedPhone = phoneNumber;
    if (phoneNumber.startsWith('0')) {
      formattedPhone = '254${phoneNumber.substring(1)}';
    } else if (phoneNumber.startsWith('+254')) {
      formattedPhone = phoneNumber.substring(1);
    }

    // STK Push payload
    final payload = {
      "BusinessShortCode": businessShortCode,
      "Password": password,
      "Timestamp": timestamp,
      "TransactionType": "CustomerPayBillOnline",
      "Amount": amount.toStringAsFixed(0),
      "PartyA": formattedPhone,
      "PartyB": businessShortCode,
      "PhoneNumber": formattedPhone,
      "CallBackURL": dotenv.get('MPESA_CALLBACK_URL'),
      "AccountReference": "HARAKA_AFYA",
      "TransactionDesc": "Subscription - $plan Plan",
    };

    final response = await http.post(
      Uri.parse('https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('STK Push failed: ${response.body}');
    }
  }

  Future<String?> _showPhoneNumberDialog() async {
    String phoneNumber = '';
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('M-Pesa Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your M-Pesa registered phone number:'),
              SizedBox(height: 16),
              TextField(
                onChanged: (value) => phoneNumber = value,
                decoration: InputDecoration(
                  hintText: '07XXXXXXXX',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, phoneNumber),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00A650),
              ),
              child: Text('Confirm Payment'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processOtherPayment() async {
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

  Future<void> _startPayment() async {
    if (_selectedPaymentMethod == 'M-Pesa') {
      await _processMpesaPayment();
    } else {
      await _processOtherPayment();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF259450)),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Unlock premium healthcare features and get personalized support',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Plans Section
              Text(
                'Available Plans',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                title: 'Free',
                price: '\$0',
                period: 'forever',
                description: 'Basic health features for everyone',
                features: [
                  '5 AI consultations per month',
                  'Basic health tips',
                  'Symptom checker',
                  'Find nearby hospitals',
                ],
                selected: _selectedPlan == 'Free',
                onSelect: () => _selectPlan('Free'),
                color: const Color(0xFFE8F5E9),
                textColor: const Color(0xFF259450),
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                title: 'Premium',
                price: '\$7.99',
                period: 'per month',
                description: 'Advanced features for better health management',
                features: [
                  'Unlimited AI consultations',
                  'Personalized health insights',
                  'Medication reminders',
                  'Priority support',
                  'Advanced analytics',
                ],
                isPopular: true,
                selected: _selectedPlan == 'Premium',
                onSelect: () => _selectPlan('Premium'),
                color: const Color(0xFFE3F2FD),
                textColor: const Color(0xFF1976D2),
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                title: 'Family',
                price: '\$14.99',
                period: 'per month',
                description: 'Complete health management for your family',
                features: [
                  'Everything in Premium',
                  'Up to 6 family members',
                  'Family health dashboard',
                  'Shared medication tracking',
                  'Emergency contacts',
                  '24/7 premium support',
                ],
                selected: _selectedPlan == 'Family',
                onSelect: () => _selectPlan('Family'),
                color: const Color(0xFFF3E5F5),
                textColor: const Color(0xFF8E24AA),
              ),
              const SizedBox(height: 32),

              // Payment Methods Section
              Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    const SizedBox(width: 4),
                    _buildPaymentMethodCard(
                      name: 'M-Pesa',
                      logo: 'assets/mpesa.png',
                      selected: _selectedPaymentMethod == 'M-Pesa',
                      onSelect: () => _selectPaymentMethod('M-Pesa'),
                      color: const Color(0xFF00A650),
                    ),
                    _buildPaymentMethodCard(
                      name: 'PayPal',
                      logo: 'assets/paypal.png',
                      selected: _selectedPaymentMethod == 'PayPal',
                      onSelect: () => _selectPaymentMethod('PayPal'),
                      color: const Color(0xFF003087),
                    ),
                    _buildPaymentMethodCard(
                      name: 'Airtel Money',
                      logo: 'assets/airtel.png',
                      selected: _selectedPaymentMethod == 'Airtel Money',
                      onSelect: () => _selectPaymentMethod('Airtel Money'),
                      color: const Color(0xFFE21836),
                    ),
                    _buildPaymentMethodCard(
                      name: 'Stripe',
                      logo: 'assets/stripe.png',
                      selected: _selectedPaymentMethod == 'Stripe',
                      onSelect: () => _selectPaymentMethod('Stripe'),
                      color: const Color(0xFF635BFF),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Button
              if (_isProcessingPayment)
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A650)),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Processing M-Pesa Payment...',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                MouseRegion(
                  onEnter: (_) => setState(() => _isButtonHovered = true),
                  onExit: (_) => setState(() => _isButtonHovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: _isButtonHovered
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF259450),
                                Color(0xFF1976D2),
                              ],
                            )
                          : const LinearGradient(
                              colors: [
                                Color(0xFF259450),
                                Color(0xFF27AE60),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF259450).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _startPayment,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedPlan == 'Free' ? Icons.check : Icons.lock_open,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedPlan == 'Free' 
                                    ? 'Continue with Free Plan'
                                    : 'Subscribe with $_selectedPaymentMethod',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (_selectedPlan != 'Free')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _selectedPaymentMethod == 'M-Pesa'
                        ? 'You will receive an STK push on your phone to complete payment'
                        : 'You will be redirected to $_selectedPaymentMethod to complete your payment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required String description,
    required List<String> features,
    required bool selected,
    required VoidCallback onSelect,
    required Color color,
    required Color textColor,
    bool isPopular = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? textColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPopular)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFD700),
                          Color(0xFFFFA000),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'MOST POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        color: textColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          period,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 8),
                if (selected)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: textColor.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        'Currently Selected',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
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
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          color: selected ? color.withOpacity(0.05) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onSelect,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 100,
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
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      color: selected ? color : Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
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