import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:stripe_native/stripe_native.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
//    StripeNative.setPublishableKey("pk_test_yZuUz6Sqm83H4lA7SrlAvYCh003MvJiJlR");
    StripeNative.setPublishableKey("pk_test_yZuUz6Sqm83H4lA7SrlAvYCh003MvJiJlR");
    StripeNative.setMerchantIdentifier("merchant.rbii.stripe-example");
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await StripeNative.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Widget get nativeButton => Padding(padding: EdgeInsets.all(10), child: RaisedButton(padding: EdgeInsets.all(10),
        child: Text("Native-Pay"),
        onPressed: () async {
//          print("Native-Pay isReady: ${StripeNative.nativePayReady}");
          var anOrder = Order(5.50, 1.0, 2.0, "Some Store");
          // get token
          var token = await StripeNative.useNativePay(anOrder);
          print(token);
          // show success or failure
          StripeNative.confirmPayment(true);
        }
    ));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Stripe Native Example'),
        ),
        body: Center(
          child: nativeButton
        ),
      ),
    );
  }
}
