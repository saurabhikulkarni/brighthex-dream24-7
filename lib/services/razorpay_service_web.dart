import 'dart:js' as js;

/// Web implementation of Razorpay using JavaScript Checkout
class RazorpayPlatform {
  Function(Map<String, dynamic>)? _onSuccess;
  Function(String)? _onError;

  void init({
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
    required Function() onDismiss,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
  }

  void open(Map<String, dynamic> options) {
    try {
      // Check if Razorpay is loaded
      if (!js.context.hasProperty('Razorpay')) {
        _onError?.call('Razorpay library not loaded. Please refresh the page.');
        return;
      }

      // Convert Dart Map to JavaScript object
      final jsOptions = js.JsObject.jsify(Map<String, dynamic>.from(options));

      // Create JavaScript functions for callbacks
      final successCallback = js.JsFunction.withThis((thisArg, response) {
        _handleSuccess(response);
      });
      
      final failureCallback = js.JsFunction.withThis((thisArg, error) {
        _handleFailure(error);
      });

      // Add handler callbacks to options
      jsOptions['handler'] = js.JsObject.jsify({
        'success': successCallback,
        'failure': failureCallback,
      });

      // Create Razorpay instance and open checkout
      final RazorpayConstructor = js.context['Razorpay'] as js.JsFunction;
      final razorpay = js.JsObject(RazorpayConstructor, [jsOptions]);
      razorpay.callMethod('open');
    } catch (e) {
      _onError?.call('Failed to open Razorpay checkout. Error: $e');
    }
  }

  void _handleSuccess(dynamic response) {
    try {
      final jsResponse = response as js.JsObject;
      _onSuccess?.call({
        'razorpay_payment_id': jsResponse['razorpay_payment_id']?.toString() ?? '',
        'razorpay_order_id': jsResponse['razorpay_order_id']?.toString() ?? '',
        'razorpay_signature': jsResponse['razorpay_signature']?.toString() ?? '',
      });
    } catch (e) {
      _onError?.call('Error processing payment response: $e');
    }
  }

  void _handleFailure(dynamic error) {
    try {
      final jsError = error as js.JsObject;
      final description = jsError['description']?.toString();
      final errorObj = jsError['error'];
      String? errorCode;
      String? errorMessage;
      
      if (errorObj != null && errorObj is js.JsObject) {
        errorCode = errorObj['code']?.toString();
        errorMessage = errorObj['description']?.toString();
      }
      
      final reason = jsError['reason']?.toString();
      
      final errorText = description ?? 
                       errorCode ?? 
                       errorMessage ?? 
                       reason ?? 
                       'Payment failed. Please try again.';
      
      _onError?.call(errorText);
    } catch (e) {
      _onError?.call('Payment failed. Please try again.');
    }
  }

  void dispose() {
    _onSuccess = null;
    _onError = null;
  }
}
