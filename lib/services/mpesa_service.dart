import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';

class MpesaService {
  // Daraja API Configuration (Sandbox)
  static const String _consumerKey = 'YOUR_CONSUMER_KEY';
  static const String _consumerSecret = 'YOUR_CONSUMER_SECRET';
  static const String _shortCode = '174379'; // Till Number
  static const String _passkey = 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919';
  static const String _callbackUrl = 'https://your-domain.com/mpesa-callback';
  
  static const String _baseUrl = 'https://sandbox.safaricom.co.ke';

  Future<String?> _getAccessToken() async {
    try {
      final auth = base64.encode(utf8.encode('$_consumerKey:$_consumerSecret'));
      final response = await http.get(
        Uri.parse('$_baseUrl/oauth/v1/generate?grant_type=client_credentials'),
        headers: {'Authorization': 'Basic $auth'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      }
    } catch (e) {
      AppConfig.logError('Mpesa Auth Error', e);
    }
    return null;
  }

  Future<Map<String, dynamic>> initiateStkPush({
    required String phoneNumber,
    required double amount,
    required String reference,
    required String description,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null) return {'success': false, 'message': 'Authentication failed'};

      final timestamp = _getTimestamp();
      final password = base64.encode(utf8.encode('$_shortCode$_passkey$timestamp'));
      
      final formattedPhone = _formatPhoneNumber(phoneNumber);

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'BusinessShortCode': _shortCode,
          'Password': password,
          'Timestamp': timestamp,
          'TransactionType': 'CustomerPayBillOnline',
          'Amount': amount.toInt(),
          'PartyA': formattedPhone,
          'PartyB': _shortCode,
          'PhoneNumber': formattedPhone,
          'CallBackURL': _callbackUrl,
          'AccountReference': reference,
          'TransactionDesc': description,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['ResponseCode'] == '0') {
        return {
          'success': true, 
          'message': 'STK Push initiated', 
          'checkoutRequestId': data['CheckoutRequestID']
        };
      } else {
        return {'success': false, 'message': data['CustomerMessage'] ?? 'STK Push failed'};
      }
    } catch (e) {
      AppConfig.logError('Mpesa STK Push Error', e);
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }

  String _formatPhoneNumber(String phone) {
    // Implement phone formatting (e.g., convert 07xx to 2547xx)
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('0')) {
      cleaned = '254${cleaned.substring(1)}';
    } else if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }
    return cleaned;
  }
}
