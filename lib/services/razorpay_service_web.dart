import 'dart:js' as js;
import 'dart:js_interop' as js_interop;
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
    return js_interop.JSExportedDartFunction((js_interop.JSAny response) {
      _onSuccess?.call({
        'razorpay_payment_id': js_util.getProperty(response, 'razorpay_payment_id')?.toString() ?? '',
        'razorpay_order_id': js_util.getProperty(response, 'razorpay_order_id')?.toString() ?? '',
        'razorpay_signature': js_util.getProperty(response, 'razorpay_signature')?.toString() ?? '',
      });
    }.toJS);
  }

  dynamic _createFailureCallback() {
    return js_interop.JSExportedDartFunction((js_interop.JSAny error) {
      // Error is a JavaScript object with error details
      final description = js_util.getProperty(error, 'description')?.toString();
      final errorCode = js_util.getProperty(error, 'error')?.toString();
      final errorMessage = js_util.getProperty(error, 'error')?.toString();
      final source = js_util.getProperty(error, 'source')?.toString();
      final step = js_util.getProperty(error, 'step')?.toString();
      final reason = js_util.getProperty(error, 'reason')?.toString();
      
      final errorText = description ?? 
                       errorCode ?? 
                       errorMessage ?? 
                       reason ?? 
                       'Payment failed. Please try again.';
      
      _onError?.call(errorText);
    }.toJS);
  }

  void dispose() {
    _onSuccess = null;
    _onError = null;
    _onDismiss = null;
  }
}
