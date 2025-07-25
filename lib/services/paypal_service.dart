import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PayPalService {
 static const String _backendBaseUrl = 'http://192.168.1.205:3000';// Use localhost for Android emulator, or replace with your LAN IP or deployed server

  static Future<void> createPayPalOrder({required String amount}) async {
    final url = Uri.parse('$_backendBaseUrl/create-order');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final approvalLink = data['links']
            .firstWhere((link) => link['rel'] == 'approve')['href'];

        if (await canLaunchUrl(Uri.parse(approvalLink))) {
          await launchUrl(Uri.parse(approvalLink), mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Could not launch PayPal approval URL');
        }
      } else {
        print('Error creating order: ${response.body}');
        throw Exception('Failed to create PayPal order');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
