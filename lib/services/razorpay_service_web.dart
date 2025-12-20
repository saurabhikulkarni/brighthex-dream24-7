import 'dart:js' as js;
import 'dart:js_util' as js_util;

/// Web implementation of Razorpay using JavaScript Checkout
class RazorpayPlatform {
  Function(Map<String, dynamic>)? _onSuccess;
  Function(String)? _onError;
  Function()? _onDismiss;

  void init({
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
    required Function() onDismiss,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    _onDismiss = onDismiss;
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

      // Add handler callbacks to options
      final handler = js.JsObject.jsify({
        'success': _createSuccessCallback(),
        'failure': _createFailureCallback(),
      });
      js_util.setProperty(jsOptions, 'handler', handler);

      // Create Razorpay instance and open checkout
      final RazorpayConstructor = js.context['Razorpay'] as js.JsFunction;
      final razorpay = js.JsObject(RazorpayConstructor, [jsOptions]);
      razorpay.callMethod('open');
    } catch (e) {
      _onError?.call('Failed to open Razorpay checkout. Error: $e');
    }
  }

  dynamic _createSuccessCallback() {
    return js.allowInterop((dynamic response) {
      final jsResponse = response as js.JsObject;
      _onSuccess?.call({
        'razorpay_payment_id': js_util.getProperty(jsResponse, 'razorpay_payment_id')?.toString() ?? '',
        'razorpay_order_id': js_util.getProperty(jsResponse, 'razorpay_order_id')?.toString() ?? '',
        'razorpay_signature': js_util.getProperty(jsResponse, 'razorpay_signature')?.toString() ?? '',
      });
    });
  }

  dynamic _createFailureCallback() {
    return js.allowInterop((dynamic error) {
      // Error is a JavaScript object with error details
      final jsError = error as js.JsObject;
      final description = js_util.getProperty(jsError, 'description')?.toString();
      final errorCode = js_util.getProperty(jsError, 'error')?.toString();
      final errorMessage = js_util.getProperty(jsError, 'error')?.toString();
      final source = js_util.getProperty(jsError, 'source')?.toString();
      final step = js_util.getProperty(jsError, 'step')?.toString();
      final reason = js_util.getProperty(jsError, 'reason')?.toString();
      
      final errorText = description ?? 
                       errorCode ?? 
                       errorMessage ?? 
                       reason ?? 
                       'Payment failed. Please try again.';
      
      _onError?.call(errorText);
    });
  }

  void dispose() {
    _onSuccess = null;
    _onError = null;
    _onDismiss = null;
  }
}
