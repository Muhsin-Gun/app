import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';

class MpesaService {
  static const String _baseUrl = 'https://sandbox.safaricom.co.ke';
  static const String _consumerKey = 'YOUR_CONSUMER_KEY'; // Replace with actual
  static const String _consumerSecret =
      'YOUR_CONSUMER_SECRET'; // Replace with actual
  static const String _shortCode = '174379'; // Test shortcode
  static const String _passkey =
      'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919'; // Test passkey

  static Future<String?> getAccessToken() async {
    try {
      final credentials = base64Encode(
        utf8.encode('$_consumerKey:$_consumerSecret'),
      );
      final response = await http.get(
        Uri.parse('$_baseUrl/oauth/v1/generate?grant_type=client_credentials'),
        headers: {'Authorization': 'Basic $credentials'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      }
      return null;
    } catch (e) {
      AppConfig.logError('Failed to get M-Pesa access token', e);
      return null;
    }
  }

  static Future<Map<String, dynamic>?> initiateSTKPush({
    required String phoneNumber,
    required int amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    try {
      final token = await getAccessToken();
      if (token == null) return null;

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(RegExp(r'[^0-9]'), '')
          .substring(0, 14);
      final password = base64Encode(
        utf8.encode('$_shortCode$_passkey$timestamp'),
      );

      final body = {
        'BusinessShortCode': _shortCode,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount,
        'PartyA': phoneNumber,
        'PartyB': _shortCode,
        'PhoneNumber': phoneNumber,
        'CallBackURL': 'https://your-callback-url.com/mpesa/callback',
        'AccountReference': accountReference,
        'TransactionDesc': transactionDesc,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      AppConfig.logError('Failed to initiate STK push', e);
      return null;
    }
  }

  static Future<bool> checkPaymentStatus(String checkoutRequestId) async {
    try {
      final token = await getAccessToken();
      if (token == null) return false;

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(RegExp(r'[^0-9]'), '')
          .substring(0, 14);
      final password = base64Encode(
        utf8.encode('$_shortCode$_passkey$timestamp'),
      );

      final body = {
        'BusinessShortCode': _shortCode,
        'Password': password,
        'Timestamp': timestamp,
        'CheckoutRequestID': checkoutRequestId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/stkpushquery/v1/query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ResponseCode'] == '0';
      }
      return false;
    } catch (e) {
      AppConfig.logError('Failed to check payment status', e);
      return false;
    }
  }
}
