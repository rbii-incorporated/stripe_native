import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardPayTheme {
  Color primaryBackgroundColor;

  CardPayTheme({this.primaryBackgroundColor});
}

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
  static bool get nativePayReady =>
      merchantIdentifier.isNotEmpty && publishableKey.isNotEmpty;
  static String currencyKey = "";
  static String countryKey = "";

  static void setPublishableKey(String key) {
    _channel.invokeMethod("setPublishableKey", key);
    publishableKey = key;
  }

  static void setMerchantIdentifier(String identifier) {
    _channel.invokeMethod('setMerchantIdentifier', identifier);
    merchantIdentifier = identifier;
  }

  static void setCurrencyKey(String key) {
    _channel.invokeMethod('setCurrencyKey', key);
    currencyKey = key;
  }

  static void setCountryKey(String key) {
    _channel.invokeMethod('setCountryKey', key);
    countryKey = key;
  }

  static void setCardPayTheme(CardPayTheme cardTheme) {
    var cardTheme = {

    };
    _channel.invokeMethod('cardTheme', cardTheme);
  }

  static Future<String> get useCardPay async =>
      await _channel.invokeMethod('cardInput');

  static Future<String> useNativePay(Order anOrder) async {
    var orderMap = {
      "subtotal": anOrder.subtotal,
      "tax": anOrder.tax,
      "tip": anOrder.tip,
      "merchantName": anOrder.merchantName
    };
    return await _channel.invokeMethod('nativePay', orderMap);
  }

  static Future<String> useReceiptNativePay(Receipt aReceipt) async {
    var newOrder = Map<String, dynamic>();
    newOrder.addAll(aReceipt.items);
    newOrder.addAll({"merchantName": aReceipt.merchantName});
    return await _channel.invokeMethod('receiptNativePay', newOrder);
  }

  static void confirmPayment(bool isSuccess) =>
      _channel.invokeMethod("confirmPayment", isSuccess);
}
