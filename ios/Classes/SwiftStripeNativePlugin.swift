import Flutter
import UIKit
import PassKit
import Stripe

struct Payment {
    let subtotal: Double
    let tax: Double
    let tip: Double
    let merchantName: String
}

public class SwiftStripeNativePlugin: NSObject, FlutterPlugin, PKPaymentAuthorizationViewControllerDelegate {
    
    var merchantIdentifier: String?
    var flutterResult: FlutterResult?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "stripe_native", binaryMessenger: registrar.messenger())
        let instance = SwiftStripeNativePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "getPlatformVersion") {
            result("iOS " + UIDevice.current.systemVersion)
        } else if (call.method == "setMerchantIdentifier") {
            merchantIdentifier = call.arguments as? String
        } else if (call.method == "nativePay") {
            let orderDict = call.arguments as! Dictionary<String, AnyObject>
            guard let subtotal = orderDict["subtotal"] as? Double, let tax = orderDict["tax"] as? Double, let tip = orderDict["tip"] as? Double, let merchantName = orderDict["merchantName"] as? String else { return }
            let payment = Payment(subtotal: subtotal, tax: tax, tip: tip, merchantName: merchantName)
            fetchNativeToken(result: result, payment: payment)
        } else {
            result(call.method + " is not part of stripe_native")
        }
    }

    private func fetchNativeToken(result: @escaping FlutterResult, payment: Payment) {
        guard let identifier = merchantIdentifier else {
            result("Please set merchant identifier before using native pay")
            return
        }
        
        flutterResult = result
        
        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: identifier, country: "US", currency: "USD")

        let total = payment.subtotal + payment.tax + payment.tip

        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Tip", amount: NSDecimalNumber(floatLiteral: payment.tip)),
            PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(floatLiteral: payment.tax)),
            PKPaymentSummaryItem(label: "Subtotal", amount: NSDecimalNumber(floatLiteral: payment.subtotal)),
            PKPaymentSummaryItem(label: payment.merchantName, amount: NSDecimalNumber(floatLiteral: total)),
        ]
        
        if Stripe.canSubmitPaymentRequest(paymentRequest), let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) {
            paymentAuthorizationViewController.delegate = self
            UIApplication.shared.keyWindow?.rootViewController?.present(paymentAuthorizationViewController, animated: true)
        } else {
            result("There's a problem w/ Apple pay configuration.")
        }
    }

    private func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        let identifier = payment.token.transactionIdentifier
        print("apple pay token: " + identifier)
        let status = identifier.isEmpty ? PKPaymentAuthorizationStatus.failure : PKPaymentAuthorizationStatus.success
        let result = PKPaymentAuthorizationResult(status: status, errors: nil)
        flutterResult?(identifier)
        completion(result)
    }

    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
