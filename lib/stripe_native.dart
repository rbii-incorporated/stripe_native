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

class Receipt {
  Map<String, double> items;
  String merchantName;

  Receipt(Map<String, double> items, String merchantName) {
    this.items = items;
    this.merchantName = merchantName;
  }
}

class StripeNative {
  static const MethodChannel _channel = const MethodChannel('stripe_native');

  static String publishableKey = "";
  static String merchantIdentifier = "";
  static bool get nativePayReady => merchantIdentifier.isNotEmpty && publishableKey.isNotEmpty;

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void setPublishableKey(String key) {
    _channel.invokeMethod("setPublishableKey", key);
    publishableKey = key;
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

  static Future<String> useReceiptNativePay(Receipt aReceipt) async {
    var newOrder = Map<String, dynamic>();
    newOrder.addAll(aReceipt.items);
    newOrder.addAll({"merchantName": aReceipt.merchantName});
    final String nativeToken = await _channel.invokeMethod('receiptNativePay', newOrder);
    return nativeToken;
  }

  static void confirmPayment(bool isSuccess) {
    _channel.invokeMethod("confirmPayment", isSuccess);
  }

}
