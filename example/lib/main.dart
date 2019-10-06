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

  Future<String> get receiptPayment async {
    /* custom receipt w/ useReceiptNativePay */
    const receipt = <String, double>{"Nice Hat": 5.00, "Used Hat" : 1.50};
    var aReceipt = Receipt(receipt, "Hat Store");
    return await StripeNative.useReceiptNativePay(aReceipt);
  }

  Future<String> get orderPayment async {
    // subtotal, tax, tip, merchant name
    var order = Order(5.50, 1.0, 2.0, "Some Store");
    return await StripeNative.useNativePay(order);
  }

  Widget get cardInputButton => Padding(padding: EdgeInsets.all(10), child: RaisedButton(padding: EdgeInsets.all(10),
      child: Text("Card Pay"),
      onPressed: () async {

        var token = await StripeNative.useCardPay;

        print(token);

      }
  ));

  Widget get nativeButton => Padding(padding: EdgeInsets.all(10), child: RaisedButton(padding: EdgeInsets.all(10),
        child: Text("Native Pay"),
        onPressed: () async {

          // var token = await orderPayment;
          var token = await receiptPayment;

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

  Widget get buttonColumn => Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[cardInputButton, nativeButton]);

  @override
  Widget build(BuildContext context) => MaterialApp(home: Scaffold(body: Center(child: buttonColumn)));


}
