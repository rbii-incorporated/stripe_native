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

struct Item {
    let name: String
    let price: Double
}

enum StripeNativeError: Error {
    case MissingPublishableKey
    case MissingMerchantIdentifier
    case MissingMerchantName
    case StripeCannotSubmitPayment
    case FunctionDoesNotExist
    case PaymentParameterTypeMismatch
    case ConfirmationParameterTypeMismatch
}

public class SwiftStripeNativePlugin: NSObject, FlutterPlugin, PKPaymentAuthorizationViewControllerDelegate {

    var publishableKey: String?
    var merchantIdentifier: String?
    var currencyKey = "USD"
    var countryKey = "US"
    var flutterResult: FlutterResult?
    
    var completion: ((PKPaymentAuthorizationResult) -> Void)?
    
    var stripeClient: STPAPIClient?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "stripe_native", binaryMessenger: registrar.messenger())
        let instance = SwiftStripeNativePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "setPublishableKey") {
            
            publishableKey = call.arguments as? String
            guard let key = publishableKey else { return }
            stripeClient = STPAPIClient(publishableKey: key)
            
        } else if (call.method == "setMerchantIdentifier") {
            
            merchantIdentifier = call.arguments as? String
            
        } else if (call.method == "setCurrencyKey") {
            
            currencyKey = call.arguments as? String
            
        } else if (call.method == "setCountryKey") {
            
            countryKey = call.arguments as? String
            
        } else if (call.method == "nativePay") {
            
            let orderDict = call.arguments as! Dictionary<String, AnyObject>
            guard let subtotal = orderDict["subtotal"] as? Double, let tax = orderDict["tax"] as? Double, let tip = orderDict["tip"] as? Double, let merchantName = orderDict["merchantName"] as? String else {
                hand(errors: [StripeNativeError.PaymentParameterTypeMismatch])
                return
            }
            let payment = Payment(subtotal: subtotal, tax: tax, tip: tip, merchantName: merchantName)
            fetchNativeToken(result: result, payment: payment)
            
        } else if (call.method == "receiptNativePay") {
            
            guard var receiptDict = call.arguments as? Dictionary<String, Any?> else {
                hand(errors: [StripeNativeError.PaymentParameterTypeMismatch])
                return
            }
            
            guard let merchantName = receiptDict.removeValue(forKey: "merchantName") as? String else {
                hand(errors: [StripeNativeError.MissingMerchantName])
                return
            }
            
            let items = receiptDict.compactMap { (arg) -> Item in
                let (key, val) = arg
                guard let price = val as? Double else {
                    hand(errors: [StripeNativeError.PaymentParameterTypeMismatch])
                    return Item(name: key, price: 0)
                }
                return Item(name: key, price: price)
            }
            
            fetchReceiptToken(result: result, items: items, name: merchantName)
            
        }  else if (call.method == "confirmPayment") {
            
            guard let isSuccess = call.arguments as? Bool else {
                hand(errors: [StripeNativeError.ConfirmationParameterTypeMismatch])
                return
            }
            let status = isSuccess == true ? PKPaymentAuthorizationStatus.success : PKPaymentAuthorizationStatus.failure
            let paymentResult = PKPaymentAuthorizationResult(status: status, errors: nil)
            completion?(paymentResult)
            flutterResult?(true)
            
        } else {
            
            hand(errors: [StripeNativeError.FunctionDoesNotExist])
            
        }
    }
    
    private func fetchReceiptToken(result: @escaping FlutterResult, items: [Item], name: String) {
        guard let identifier = merchantIdentifier else {
            hand(errors: [StripeNativeError.MissingMerchantIdentifier])
            return
        }
        
        flutterResult = result
        
        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: identifier, country: countryKey, currency: currencyKey)
        
        let total = items.reduce(0) { (next, item) -> Double in
            return item.price + next
        }
        
        paymentRequest.paymentSummaryItems = items.map { (item) -> PKPaymentSummaryItem in
            return PKPaymentSummaryItem(label: item.name, amount: NSDecimalNumber(floatLiteral: item.price))
        }
        
        paymentRequest.paymentSummaryItems.append(PKPaymentSummaryItem(label: name, amount: NSDecimalNumber(floatLiteral: total)))
        
        if Stripe.canSubmitPaymentRequest(paymentRequest), let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) {
            paymentAuthorizationViewController.delegate = self
            UIApplication.shared.keyWindow?.rootViewController?.present(paymentAuthorizationViewController, animated: true)
        } else {
            hand(errors: [StripeNativeError.StripeCannotSubmitPayment])
        }
    }

    private func fetchNativeToken(result: @escaping FlutterResult, payment: Payment) {
        guard let identifier = merchantIdentifier else {
            hand(errors: [StripeNativeError.MissingMerchantIdentifier])
            return
        }
        
        flutterResult = result
        
        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: identifier, country: countryKey, currency: currencyKey)

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
            hand(errors: [StripeNativeError.StripeCannotSubmitPayment])
        }
    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        self.completion = completion
        
        stripeClient?.createToken(with: payment) { (tok, tokenError) in
            guard let token = tok, tokenError == nil else {
                if let error = tokenError {
                    self.hand(errors: [error])
                }
                return
            }
            self.flutterResult?(token.tokenId)
        }
    }

    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func hand(errors: [Error]) {
        completion?(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: errors))
        
        let errorsDescription = errors.reduce("") { (next, error) -> String in
            return next + ", " + error.localizedDescription
        }
        
        self.flutterResult?(errorsDescription)
    }
}
