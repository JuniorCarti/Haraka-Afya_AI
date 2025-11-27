import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mpesa_service.dart';
import '../models/payment_model.dart';

class MpesaPaymentScreen extends StatefulWidget {
  final double amount;
  final String serviceType;
  final String reference;

  const MpesaPaymentScreen({
    Key? key,
    required this.amount,
    required this.serviceType,
    required this.reference,
  }) : super(key: key);

  @override
  _MpesaPaymentScreenState createState() => _MpesaPaymentScreenState();
}

class _MpesaPaymentScreenState extends State<MpesaPaymentScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final MpesaService _mpesaService = MpesaService();
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('M-Pesa Payment'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Summary
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Service:'),
                        Text(widget.serviceType),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reference:'),
                        Text(widget.reference),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'KES ${widget.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Phone Input
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'M-Pesa Phone Number',
                hintText: '07XXXXXXXX',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),
            Text(
              'Enter your M-Pesa registered phone number',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            
            // Status Message
            if (_statusMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('successfully') 
                      ? Colors.green[100] 
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('successfully') 
                        ? Colors.green[800] 
                        : Colors.orange[800],
                  ),
                ),
              ),
            SizedBox(height: 20),
            
            // Pay Button
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _makePayment,
                    child: Text(
                      'Pay with M-Pesa',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
            SizedBox(height: 10),
            
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel Payment'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePayment() async {
    if (_phoneController.text.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter your phone number';
      });
      return;
    }

    if (_phoneController.text.length < 10) {
      setState(() {
        _statusMessage = 'Please enter a valid phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Initiating payment...';
    });

    try {
      final result = await _mpesaService.initiateSTKPush(
        phoneNumber: _phoneController.text,
        amount: widget.amount,
        accountReference: widget.reference,
        transactionDesc: 'Haraka Afya - ${widget.serviceType}',
      );

      if (result['ResponseCode'] == '0') {
        setState(() {
          _statusMessage = 'Payment initiated successfully! Check your phone to complete the payment.';
        });
        
        // You can add navigation to success page or back to previous screen
        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context, true); // Return success
      } else {
        setState(() {
          _statusMessage = 'Payment failed: ${result['ResponseDescription']}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}