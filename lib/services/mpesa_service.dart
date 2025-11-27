import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MpesaService {
  
  // Generate access token - USING THE URL FROM YOUR SCREENSHOT
  Future<String> getAccessToken() async {
    try {
      final consumerKey = dotenv.get('MPESA_CONSUMER_KEY');
      final consumerSecret = dotenv.get('MPESA_CONSUMER_SECRET');
      
      print('🔑 Getting M-Pesa access token with key: ${consumerKey.substring(0, 10)}...');
      
      final credentials = base64.encode(utf8.encode('$consumerKey:$consumerSecret'));
      
      // THIS IS THE EXACT URL YOU ASKED ABOUT
      final response = await http.get(
        Uri.parse('https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials'),
        headers: {
          'Authorization': 'Basic $credentials',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];
        print('✅ Access token received successfully!');
        return token;
      } else {
        throw Exception('Failed to get access token: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Access token error: $e');
      throw Exception('Cannot connect to M-Pesa: $e');
    }
  }

  // Generate timestamp
  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }

  // Initiate STK Push
  Future<Map<String, dynamic>> initiateSTKPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    try {
      print('🚀 Starting M-Pesa payment...');
      
      // STEP 1: GET ACCESS TOKEN USING THAT URL
      final accessToken = await getAccessToken();
      
      // STEP 2: Prepare STK Push request
      final businessShortCode = '174379';
      final passKey = 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919';
      final timestamp = _getTimestamp();
      final password = base64.encode(utf8.encode('$businessShortCode$passKey$timestamp'));

      // Format phone number
      String formattedPhone = phoneNumber;
      if (phoneNumber.startsWith('0')) {
        formattedPhone = '254${phoneNumber.substring(1)}';
      }

      final payload = {
        "BusinessShortCode": businessShortCode,
        "Password": password,
        "Timestamp": timestamp,
        "TransactionType": "CustomerPayBillOnline",
        "Amount": amount.toStringAsFixed(0),
        "PartyA": formattedPhone,
        "PartyB": businessShortCode,
        "PhoneNumber": formattedPhone,
        "CallBackURL": "https://sandbox.safaricom.co.ke/mpesa/c2b/v1/simulate",
        "AccountReference": accountReference,
        "TransactionDesc": transactionDesc,
      };

      print('📦 Sending STK Push request...');
      
      // STEP 3: Send STK Push request
      final response = await http.post(
        Uri.parse('https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 30));

      print('📡 STK Response Status: ${response.statusCode}');
      print('📡 STK Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['ResponseCode'] == '0') {
          print('✅ STK Push initiated successfully!');
          return responseData;
        } else {
          throw Exception('M-Pesa error: ${responseData['ResponseDescription']}');
        }
      } else {
        throw Exception('STK Push failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ STK Push error: $e');
      rethrow;
    }
  }
}