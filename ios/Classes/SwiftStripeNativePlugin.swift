import Flutter
import UIKit
import PassKit
import Stripe

let prefixAndCountries =  ["AF": ["Afghanistan","93"],
"AX": ["Aland Islands","358"],
"AL": ["Albania","355"],
"DZ": ["Algeria","213"],
"AS": ["American Samoa","1"],
"AD": ["Andorra","376"],
"AO": ["Angola","244"],
"AI": ["Anguilla","1"],
"AQ": ["Antarctica","672"],
"AG": ["Antigua and Barbuda","1"],
"AR": ["Argentina","54"],
"AM": ["Armenia","374"],
"AW": ["Aruba","297"],
"AU": ["Australia","61"],
"AT": ["Austria","43"],
"AZ": ["Azerbaijan","994"],
"BS": ["Bahamas","1"],
"BH": ["Bahrain","973"],
"BD": ["Bangladesh","880"],
"BB": ["Barbados","1"],
"BY": ["Belarus","375"],
"BE": ["Belgium","32"],
"BZ": ["Belize","501"],
"BJ": ["Benin","229"],
"BM": ["Bermuda","1"],
"BT": ["Bhutan","975"],
"BO": ["Bolivia","591"],
"BA": ["Bosnia and Herzegovina","387"],
"BW": ["Botswana","267"],
"BV": ["Bouvet Island","47"],
"BQ": ["BQ","599"],
"BR": ["Brazil","55"],
"IO": ["British Indian Ocean Territory","246"],
"VG": ["British Virgin Islands","1"],
"BN": ["Brunei Darussalam","673"],
"BG": ["Bulgaria","359"],
"BF": ["Burkina Faso","226"],
"BI": ["Burundi","257"],
"KH": ["Cambodia","855"],
"CM": ["Cameroon","237"],
"CA": ["Canada","1"],
"CV": ["Cape Verde","238"],
"KY": ["Cayman Islands","345"],
"CF": ["Central African Republic","236"],
"TD": ["Chad","235"],
"CL": ["Chile","56"],
"CN": ["China","86"],
"CX": ["Christmas Island","61"],
"CC": ["Cocos (Keeling) Islands","61"],
"CO": ["Colombia","57"],
"KM": ["Comoros","269"],
"CG": ["Congo (Brazzaville)","242"],
"CD": ["Congo, Democratic Republic of the","243"],
"CK": ["Cook Islands","682"],
"CR": ["Costa Rica","506"],
"CI": ["Côte d'Ivoire","225"],
"HR": ["Croatia","385"],
"CU": ["Cuba","53"],
"CW": ["Curacao","599"],
"CY": ["Cyprus","537"],
"CZ": ["Czech Republic","420"],
"DK": ["Denmark","45"],
"DJ": ["Djibouti","253"],
"DM": ["Dominica","1"],
"DO": ["Dominican Republic","1"],
"EC": ["Ecuador","593"],
"EG": ["Egypt","20"],
"SV": ["El Salvador","503"],
"GQ": ["Equatorial Guinea","240"],
"ER": ["Eritrea","291"],
"EE": ["Estonia","372"],
"ET": ["Ethiopia","251"],
"FK": ["Falkland Islands (Malvinas)","500"],
"FO": ["Faroe Islands","298"],
"FJ": ["Fiji","679"],
"FI": ["Finland","358"],
"FR": ["France","33"],
"GF": ["French Guiana","594"],
"PF": ["French Polynesia","689"],
"TF": ["French Southern Territories","689"],
"GA": ["Gabon","241"],
"GM": ["Gambia","220"],
"GE": ["Georgia","995"],
"DE": ["Germany","49"],
"GH": ["Ghana","233"],
"GI": ["Gibraltar","350"],
"GR": ["Greece","30"],
"GL": ["Greenland","299"],
"GD": ["Grenada","1"],
"GP": ["Guadeloupe","590"],
"GU": ["Guam","1"],
"GT": ["Guatemala","502"],
"GG": ["Guernsey","44"],
"GN": ["Guinea","224"],
"GW": ["Guinea-Bissau","245"],
"GY": ["Guyana","595"],
"HT": ["Haiti","509"],
"VA": ["Holy See (Vatican City State)","379"],
"HN": ["Honduras","504"],
"HK": ["Hong Kong, Special Administrative Region of China","852"],
"HU": ["Hungary","36"],
"IS": ["Iceland","354"],
"IN": ["India","91"],
"ID": ["Indonesia","62"],
"IR": ["Iran, Islamic Republic of","98"],
"IQ": ["Iraq","964"],
"IE": ["Ireland","353"],
"IM": ["Isle of Man","44"],
"IL": ["Israel","972"],
"IT": ["Italy","39"],
"JM": ["Jamaica","1"],
"JP": ["Japan","81"],
"JE": ["Jersey","44"],
"JO": ["Jordan","962"],
"KZ": ["Kazakhstan","77"],
"KE": ["Kenya","254"],
"KI": ["Kiribati","686"],
"KP": ["Korea, Democratic People's Republic of","850"],
"KR": ["Korea, Republic of","82"],
"KW": ["Kuwait","965"],
"KG": ["Kyrgyzstan","996"],
"LA": ["Lao PDR","856"],
"LV": ["Latvia","371"],
"LB": ["Lebanon","961"],
"LS": ["Lesotho","266"],
"LR": ["Liberia","231"],
"LY": ["Libya","218"],
"LI": ["Liechtenstein","423"],
"LT": ["Lithuania","370"],
"LU": ["Luxembourg","352"],
"MO": ["Macao, Special Administrative Region of China","853"],
"MK": ["Macedonia, Republic of","389"],
"MG": ["Madagascar","261"],
"MW": ["Malawi","265"],
"MY": ["Malaysia","60"],
"MV": ["Maldives","960"],
"ML": ["Mali","223"],
"MT": ["Malta","356"],
"MH": ["Marshall Islands","692"],
"MQ": ["Martinique","596"],
"MR": ["Mauritania","222"],
"MU": ["Mauritius","230"],
"YT": ["Mayotte","262"],
"MX": ["Mexico","52"],
"FM": ["Micronesia, Federated States of","691"],
"MD": ["Moldova","373"],
"MC": ["Monaco","377"],
"MN": ["Mongolia","976"],
"ME": ["Montenegro","382"],
"MS": ["Montserrat","1"],
"MA": ["Morocco","212"],
"MZ": ["Mozambique","258"],
"MM": ["Myanmar","95"],
"NA": ["Namibia","264"],
"NR": ["Nauru","674"],
"NP": ["Nepal","977"],
"NL": ["Netherlands","31"],
"AN": ["Netherlands Antilles","599"],
"NC": ["New Caledonia","687"],
"NZ": ["New Zealand","64"],
"NI": ["Nicaragua","505"],
"NE": ["Niger","227"],
"NG": ["Nigeria","234"],
"NU": ["Niue","683"],
"NF": ["Norfolk Island","672"],
"MP": ["Northern Mariana Islands","1"],
"NO": ["Norway","47"],
"OM": ["Oman","968"],
"PK": ["Pakistan","92"],
"PW": ["Palau","680"],
"PS": ["Palestinian Territory, Occupied","970"],
"PA": ["Panama","507"],
"PG": ["Papua New Guinea","675"],
"PY": ["Paraguay","595"],
"PE": ["Peru","51"],
"PH": ["Philippines","63"],
"PN": ["Pitcairn","872"],
"PL": ["Poland","48"],
"PT": ["Portugal","351"],
"PR": ["Puerto Rico","1"],
"QA": ["Qatar","974"],
"RE": ["Réunion","262"],
"RO": ["Romania","40"],
"RU": ["Russian Federation","7"],
"RW": ["Rwanda","250"],
"SH": ["Saint Helena","290"],
"KN": ["Saint Kitts and Nevis","1"],
"LC": ["Saint Lucia","1"],
"PM": ["Saint Pierre and Miquelon","508"],
"VC": ["Saint Vincent and Grenadines","1"],
"BL": ["Saint-Barthélemy","590"],
"MF": ["Saint-Martin (French part)","590"],
"WS": ["Samoa","685"],
"SM": ["San Marino","378"],
"ST": ["Sao Tome and Principe","239"],
"SA": ["Saudi Arabia","966"],
"SN": ["Senegal","221"],
"RS": ["Serbia","381"],
"SC": ["Seychelles","248"],
"SL": ["Sierra Leone","232"],
"SG": ["Singapore","65"],
"SX": ["Sint Maarten","1"],
"SK": ["Slovakia","421"],
"SI": ["Slovenia","386"],
"SB": ["Solomon Islands","677"],
"SO": ["Somalia","252"],
"ZA": ["South Africa","27"],
"GS": ["South Georgia and the South Sandwich Islands","500"],
"SS​": ["South Sudan","211"],
"ES": ["Spain","34"],
"LK": ["Sri Lanka","94"],
"SD": ["Sudan","249"],
"SR": ["Suriname","597"],
"SJ": ["Svalbard and Jan Mayen Islands","47"],
"SZ": ["Swaziland","268"],
"SE": ["Sweden","46"],
"CH": ["Switzerland","41"],
"SY": ["Syrian Arab Republic (Syria)","963"],
"TW": ["Taiwan, Republic of China","886"],
"TJ": ["Tajikistan","992"],
"TZ": ["Tanzania, United Republic of","255"],
"TH": ["Thailand","66"],
"TL": ["Timor-Leste","670"],
"TG": ["Togo","228"],
"TK": ["Tokelau","690"],
"TO": ["Tonga","676"],
"TT": ["Trinidad and Tobago","1"],
"TN": ["Tunisia","216"],
"TR": ["Turkey","90"],
"TM": ["Turkmenistan","993"],
"TC": ["Turks and Caicos Islands","1"],
"TV": ["Tuvalu","688"],
"UG": ["Uganda","256"],
"UA": ["Ukraine","380"],
"AE": ["United Arab Emirates","971"],
"GB": ["United Kingdom","44"],
"US": ["United States of America","1"],
"UY": ["Uruguay","598"],
"UZ": ["Uzbekistan","998"],
"VU": ["Vanuatu","678"],
"VE": ["Venezuela (Bolivarian Republic of)","58"],
"VN": ["Viet Nam","84"],
"VI": ["Virgin Islands, US","1"],
"WF": ["Wallis and Futuna Islands","681"],
"EH": ["Western Sahara","212"],
"YE": ["Yemen","967"],
"ZM": ["Zambia","260"],
"ZW": ["Zimbabwe","263"]]

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
    case MissingPublishableKey(message: String?)
    case MissingMerchantIdentifier(message: String?)
    case MissingMerchantName(message: String?)
    case StripeCannotSubmitPayment(message: String?)
    case CountryKeyIsInvalid(message: String?)
    case FunctionDoesNotExist(message: String?)
    case PaymentParameterTypeMismatch(message: String?)
    case ConfirmationParameterTypeMismatch(message: String?)
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
            
            guard let key = call.arguments as? String else { return }
            currencyKey = key
            
        } else if (call.method == "setCountryKey") {
            
            guard let key = call.arguments as? String else { return }
            countryKey = key
            
        } else if (call.method == "nativePay") {
            
            let orderDict = call.arguments as! Dictionary<String, AnyObject>
            guard let subtotal = orderDict["subtotal"] as? Double, let tax = orderDict["tax"] as? Double, let tip = orderDict["tip"] as? Double, let merchantName = orderDict["merchantName"] as? String else {
                hand(error: StripeNativeError.PaymentParameterTypeMismatch(message: "Please check arguments passed in to native pay, as is the subtotal, tax, tip need to be numbers. The merchant name is a required string."))
                return
            }
            let payment = Payment(subtotal: subtotal, tax: tax, tip: tip, merchantName: merchantName)
            fetchNativeToken(result: result, payment: payment)
            
        } else if (call.method == "receiptNativePay") {
            
            guard var receiptDict = call.arguments as? Dictionary<String, Any?> else {
                hand(error: StripeNativeError.PaymentParameterTypeMismatch(message: "The receipt used does not contain arguments valid for creating a receipt, please use the Receipt helper object before calling receiptNativePay"))
                return
            }
            
            guard let merchantName = receiptDict.removeValue(forKey: "merchantName") as? String else {
                hand(error: StripeNativeError.MissingMerchantName(message: "Before using receiptNativePay please pay in a merchant name."))
                return
            }
            
            let items = receiptDict.compactMap { (arg) -> Item in
                let (key, val) = arg
                guard let price = val as? Double else {
                    hand(error: StripeNativeError.PaymentParameterTypeMismatch(message: "The receipt object contains a price that is not a number."))
                    return Item(name: key, price: 0)
                }
                return Item(name: key, price: price)
            }
            
            fetchReceiptToken(result: result, items: items, name: merchantName)
            
        }  else if (call.method == "confirmPayment") {
            
            guard let isSuccess = call.arguments as? Bool else {
                hand(error: StripeNativeError.ConfirmationParameterTypeMismatch(message: "confirmPayment requires a path that is represented by a boolean. True will successfully dismiss the paysheet, while false will display improper payment to the user."))
                return
            }
            let status = isSuccess == true ? PKPaymentAuthorizationStatus.success : PKPaymentAuthorizationStatus.failure
            let paymentResult = PKPaymentAuthorizationResult(status: status, errors: nil)
            completion?(paymentResult)
            flutterResult?(true)
            
        } else {
            
            hand(error: StripeNativeError.FunctionDoesNotExist(message: "The function " + call.method + " does not exist on StripeNative"))
            
        }
    }
    
    
    
    private func fetchReceiptToken(result: @escaping FlutterResult, items: [Item], name: String) {
        guard let identifier = merchantIdentifier else {
            hand(error: StripeNativeError.MissingMerchantIdentifier(message: "Please call setMerchantIdentifier before using receiptNativePay."))
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
        
        guard isCountryCodeValid(request: paymentRequest) else {
            hand(error: StripeNativeError.CountryKeyIsInvalid(message: "The country key used " + paymentRequest.countryCode + " is invalid"))
            return
        }
        
        if Stripe.canSubmitPaymentRequest(paymentRequest), let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) {
            paymentAuthorizationViewController.delegate = self
            UIApplication.shared.keyWindow?.rootViewController?.present(paymentAuthorizationViewController, animated: true)
        } else {
            hand(error: StripeNativeError.StripeCannotSubmitPayment(message: "Stripe was unable to create the payment request " + (paymentRequest.applicationData?.base64EncodedString() ?? "")))
        }
    }

    private func fetchNativeToken(result: @escaping FlutterResult, payment: Payment) {
        guard let identifier = merchantIdentifier else {
            hand(error: StripeNativeError.MissingMerchantIdentifier(message: "Please call setMerchantIdentifier before using receiptNativePay."))
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
        
        
        guard isCountryCodeValid(request: paymentRequest) else {
            hand(error: StripeNativeError.CountryKeyIsInvalid(message: "The country key used " + paymentRequest.countryCode + " is invalid"))
            return
        }
        
        if Stripe.canSubmitPaymentRequest(paymentRequest), let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) {
            paymentAuthorizationViewController.delegate = self
            UIApplication.shared.keyWindow?.rootViewController?.present(paymentAuthorizationViewController, animated: true)
        } else {
            hand(error: StripeNativeError.StripeCannotSubmitPayment(message: "Stripe was unable to create the payment request " + (paymentRequest.applicationData?.base64EncodedString() ?? "")))
        }
    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        self.completion = completion
        
        stripeClient?.createToken(with: payment) { (tok, tokenError) in
            guard let token = tok, tokenError == nil else {
                if let error = tokenError {
                    self.hand(error: error)
                }
                return
            }
            self.flutterResult?(token.tokenId)
        }
    }

    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func isCountryCodeValid(request: PKPaymentRequest) -> Bool {
        
        return prefixAndCountries.keys.contains(countryKey)
        
        /*
        guard let supported = request.supportedCountries else { return false }

        return supported.contains(countryKey)
        */

    }
    
    private func hand(error: Error) {
        completion?(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: [error]))
        
        var flutterError = FlutterError(code: error.localizedDescription, message: nil, details: nil)
        if let stripeError = error as? StripeNativeError {
            var flutterMessage = ""
            switch stripeError {
                case .ConfirmationParameterTypeMismatch(let message):
                    flutterMessage = message ?? ""
                case .CountryKeyIsInvalid(let message):
                    flutterMessage = message ?? ""
                case .FunctionDoesNotExist(let message):
                    flutterMessage = message ?? ""
                case .MissingMerchantIdentifier(let message):
                    flutterMessage = message ?? ""
                case .MissingMerchantName(let message):
                    flutterMessage = message ?? ""
                case .MissingPublishableKey(let message):
                    flutterMessage = message ?? ""
                case .PaymentParameterTypeMismatch(let message):
                    flutterMessage = message ?? ""
                case .StripeCannotSubmitPayment(let message):
                    flutterMessage = message ?? ""
            }
            flutterError = FlutterError(code: error.localizedDescription, message: flutterMessage, details: nil)
        }
        
        self.flutterResult?(flutterError)
    }
    
}
