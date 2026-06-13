import 'dart:js_interop';

/// Opens Razorpay checkout popup via JavaScript interop.
/// This only works on Flutter Web.
void openRazorpayCheckout({
  required String key,
  required int amount,
  required String currency,
  required String orderId,
  required String description,
  String? prefillName,
  String? prefillEmail,
  required void Function(String orderId, String paymentId, String signature) onSuccess,
  required void Function(String error) onError,
  required void Function() onCancel,
}) {
  // Create the options object to pass to JavaScript
  final options = _RazorpayOptions(
    key: key.toJS,
    amount: amount.toJS,
    currency: currency.toJS,
    order_id: orderId.toJS,
    description: description.toJS,
    prefill_name: (prefillName ?? '').toJS,
    prefill_email: (prefillEmail ?? '').toJS,
    onSuccess: ((JSString orderIdJS, JSString paymentIdJS, JSString signatureJS) {
      onSuccess(orderIdJS.toDart, paymentIdJS.toDart, signatureJS.toDart);
    }).toJS,
    onError: ((JSString errorJS) {
      onError(errorJS.toDart);
    }).toJS,
    onCancel: (() {
      onCancel();
    }).toJS,
  );

  _callOpenRazorpayCheckout(options);
}

@JS('openRazorpayCheckout')
external void _callOpenRazorpayCheckout(_RazorpayOptions options);

extension type _RazorpayOptions._(JSObject _) implements JSObject {
  external factory _RazorpayOptions({
    JSString key,
    JSNumber amount,
    JSString currency,
    JSString order_id,
    JSString description,
    JSString prefill_name,
    JSString prefill_email,
    JSFunction onSuccess,
    JSFunction onError,
    JSFunction onCancel,
  });
}
