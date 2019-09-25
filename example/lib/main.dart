import 'package:flutter/material.dart';
import 'package:stripe_native/stripe_native.dart';

void main() => runApp(NativePayExample());

class NativePayExample extends StatefulWidget {
  @override
  _NativePayExampleState createState() => _NativePayExampleState();
}

class _NativePayExampleState extends State<NativePayExample> {

  @override
  void initState() {
    super.initState();
    StripeNative.setPublishableKey("pk_test_yZuUz6Sqm83H4lA7SrlAvYCh003MvJiJlR");
    StripeNative.setMerchantIdentifier("merchant.rbii.stripe-example");
  }

  Widget get nativeButton => Padding(padding: EdgeInsets.all(10), child: RaisedButton(padding: EdgeInsets.all(10),
        child: Text("Native-Pay"),
        onPressed: () async {

          // subtotal, tax, tip, merchant
          var anOrder = Order(5.50, 1.0, 2.0, "Some Store");

          /* custom receipt w/ useReceiptNativePay */
          var receipt = <String, double>{"Nice Hat": 5.00, "Used Hat" : 1.50};
          var aReceipt = Receipt(receipt, "Hat Store");

          // get token
          var token = await StripeNative.useNativePay(anOrder);
//          var token = await StripeNative.useReceiptNativePay(aReceipt);

          print(token);
          /* After using the plugin to get a token, charge that token. On iOS the Apple-Pay sheet animation will signal failure or success using confirmPayment. Google-Pay does not have a similar implementation, so I may flash a SnackBar using wasCharged in a real application.
          call own charge endpoint w/ token
          const wasCharged = await AppAPI.charge(token, amount);
          then show success or failure
          StripeNative.confirmPayment(wasCharged);
          */
          // Until this method below is called, iOS will spin a loading indicator on the Apple-Pay sheet
          StripeNative.confirmPayment(true); // iOS load to check.
          // StripeNative.confirmPayment(false); // iOS load to X.

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
