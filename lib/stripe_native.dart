import 'dart:async';
import 'package:flutter/services.dart';

class Order {
  double subtotal;
  double tax;
  double tip;
  String merchantName;

  Order(double subtotal, double tax, double tip, String merchantName) {
    this.subtotal = subtotal;
    this.tax = tax;
    this.tip = tip;
    this.merchantName = merchantName;
  }
}

class StripeNative {
  static const MethodChannel _channel = const MethodChannel('stripe_native');

  static String merchantIdentifier = "";
  static bool get nativePayReady => merchantIdentifier.isNotEmpty;

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void setMerchantIdentifier(String identifier) {
    _channel.invokeMethod('setMerchantIdentifier', identifier);
    merchantIdentifier = identifier;
  }

  static Future<String> useNativePay(Order anOrder) async {
    var orderMap = {"subtotal": anOrder.subtotal, "tax": anOrder.tax, "tip": anOrder.tip, "merchantName": anOrder.merchantName};
    final String nativeToken = await _channel.invokeMethod('nativePay', orderMap);
    return nativeToken;
  }
}
