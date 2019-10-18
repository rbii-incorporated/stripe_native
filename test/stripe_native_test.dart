import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stripe_native/stripe_native.dart';

void main() {
  const MethodChannel channel = MethodChannel('stripe_native');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getPlatformVersion': {
          return '42';
        }
        case 'setMerchantIdentifier': {
          return "merchant.rbii.stripe-example";
        }
        case 'launchOrder': {
          return 1;
        }
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('setMerchantIdentifier', () async {
    await StripeNative.setMerchantIdentifier("merchant.rbii.stripe-example");
    expect(StripeNative.merchantIdentifier, "merchant.rbii.stripe-example");
  });
  
  test('setProperCountryCode', () async {
    await StripeNative.setCountryKey("BR");
    expect(StripeNative.countryKey, "BR");
  });

}
