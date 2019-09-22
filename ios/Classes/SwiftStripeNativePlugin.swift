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

    var publishableKey: String?
    var merchantIdentifier: String?
    var flutterResult: FlutterResult?
    
    var completion: ((PKPaymentAuthorizationResult) -> Void)?
    
    var stripeClient: STPAPIClient?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "stripe_native", binaryMessenger: registrar.messenger())
        let instance = SwiftStripeNativePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "getPlatformVersion") {
            result("iOS " + UIDevice.current.systemVersion)
        } else if (call.method == "setPublishableKey") {
            publishableKey = call.arguments as? String
            guard let key = publishableKey else { return }
            stripeClient = STPAPIClient(publishableKey: key)
        } else if (call.method == "setMerchantIdentifier") {
            merchantIdentifier = call.arguments as? String
        } else if (call.method == "nativePay") {
            let orderDict = call.arguments as! Dictionary<String, AnyObject>
            guard let subtotal = orderDict["subtotal"] as? Double, let tax = orderDict["tax"] as? Double, let tip = orderDict["tip"] as? Double, let merchantName = orderDict["merchantName"] as? String else { return }
            let payment = Payment(subtotal: subtotal, tax: tax, tip: tip, merchantName: merchantName)
            fetchNativeToken(result: result, payment: payment)
        } else if (call.method == "confirmPayment") {
            let isSuccess = call.arguments as? Bool
            let status = isSuccess == true ? PKPaymentAuthorizationStatus.success : PKPaymentAuthorizationStatus.failure
            let paymentResult = PKPaymentAuthorizationResult(status: status, errors: nil)
            completion?(paymentResult)
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

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        self.completion = completion
        
        
        
        
//            stripeClient.createPaymentMethod(with: payment) { (paymentMethod: STPPaymentMethod?, error: Error?) in
//                guard let paymentMethod = paymentMethod, error == nil else {
//                    completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: [error!]))
//                    self.flutterResult?(nil)
//                    return
//                }
        
        stripeClient?.createToken(with: payment) { (tok, tokenError) in
            guard let token = tok, tokenError == nil else {
                completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: [tokenError!]))
                self.flutterResult?(nil)
                return
            }
            self.flutterResult?(token.tokenId)
        }
        
        
//            stripeClient.createSource(with: payment, completion: { (src, srcError) in
//                guard srcError == nil, let source = src else {
//                    completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: [srcError!]))
//                    self.flutterResult?(nil)
//                    return
//                }
//                self.flutterResult?(source.stripeID)
//            })
        }

    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    private func handFailure(completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: nil))
        self.flutterResult?(nil)
    }
}
