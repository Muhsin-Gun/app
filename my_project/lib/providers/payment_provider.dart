import 'package:flutter/foundation.dart';
import '../services/mpesa_service.dart';
import '../core/app_config.dart';

class PaymentProvider extends ChangeNotifier {
  final MpesaService _mpesaService = MpesaService();

  bool _isProcessing = false;
  String? _errorMessage;
  String? _successMessage;
  String? _checkoutRequestId;

  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get checkoutRequestId => _checkoutRequestId;

  Future<bool> processMpesaPayment({
    required String phoneNumber,
    required double amount,
    required String reference,
  }) async {
    try {
      _setLoading(true);
      _clearMessages();

      AppConfig.log('Initiating M-Pesa payment: $amount for $reference');

      final result = await MpesaService.initiateSTKPush(
        phoneNumber: phoneNumber,
        amount: amount.toInt(),
        accountReference: reference,
        transactionDesc: 'Payment for service $reference',
      );

      if (result != null && result['ResponseCode'] == '0') {
        _successMessage = 'Payment initiated successfully';
        _checkoutRequestId = result['CheckoutRequestID'];
        AppConfig.log(
          'M-Pesa payment initiated successfully: $_checkoutRequestId',
        );
        return true;
      } else {
        _errorMessage = result?['ResponseDescription'] ?? 'Payment failed';
        return false;
      }
    } catch (e) {
      AppConfig.logError('Payment processing error', e);
      _errorMessage = 'An unexpected error occurred during payment';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isProcessing = loading;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _checkoutRequestId = null;
    notifyListeners();
  }
}
