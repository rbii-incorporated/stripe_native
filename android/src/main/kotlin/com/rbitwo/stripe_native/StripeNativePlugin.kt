package com.rbitwo.stripe_native

import android.app.Activity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import com.google.android.gms.wallet.Wallet
import com.google.android.gms.wallet.AutoResolveHelper
import com.google.android.gms.wallet.WalletConstants
import com.google.android.gms.wallet.PaymentDataRequest
import com.stripe.android.GooglePayConfig
import com.google.android.gms.wallet.PaymentData
import com.google.android.gms.wallet.PaymentsClient
import com.google.android.gms.wallet.IsReadyToPayRequest
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.tasks.Task
import androidx.core.app.ActivityCompat.finishAffinity
import org.json.*


class StripeNativePlugin: MethodCallHandler {

  var publishableKey: String? = null
  var merchantIdentifier: String? = null
  var paymentsClient: PaymentsClient? = null
  
  var activity: Activity? = null

  var paymentTask: Task<PaymentData>? = null

  var flutterResult: Result? = null

  val LOAD_PAYMENT_DATA_REQUEST_CODE = 14

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "stripe_native")
      val plugin = StripeNativePlugin()
      plugin.activity = registrar.activity()
      registrar.addActivityResultListener({requestCode, resultCode, data ->
        when (requestCode) {
          plugin.LOAD_PAYMENT_DATA_REQUEST_CODE -> {
            /*
            {"apiVersionMinor":0,"apiVersion":2,"paymentMethodData":{"description":"Visa •••• 6890","tokenizationData":{"type":"PAYMENT_GATEWAY","token":"{\n  \"id\": \"tok_1FKWOCLdTh2xDuV4ryMXeDUn\",\n  \"object\": \"token\",\n  \"card\": {\n    \"id\": \"card_1FKWOCLdTh2xDuV4pJmsahYA\",\n    \"object\": \"card\",\n    \"address_city\": \"Sonoma\",\n    \"address_country\": \"US\",\n    \"address_line1\": \"21801 Pearson Ave\",\n    \"address_line1_check\": \"unchecked\",\n    \"address_line2\": null,\n    \"address_state\": \"CA\",\n    \"address_zip\": \"95476\",\n    \"address_zip_check\": \"unchecked\",\n    \"brand\": \"Visa\",\n    \"country\": \"US\",\n    \"cvc_check\": null,\n    \"dynamic_last4\": \"4242\",\n    \"exp_month\": 12,\n    \"exp_year\": 2024,\n    \"funding\": \"credit\",\n    \"last4\": \"6890\",\n    \"metadata\": {\n    },\n    \"name\": \"John Blanchard\",\n    \"tokenization_method\": \"android_pay\"\n  },\n  \"client_ip\": \"74.125.113.99\",\n  \"created\": 1568925488,\n  \"livemode
             */
            when (resultCode) {
              Activity.RESULT_OK ->
                PaymentData.getFromIntent(data)?.let({plugin.flutterResult!!.success("tok" + it.toJson().substringAfter("tokenizationData").substringAfter("token").substringAfter("id").substringBefore("object").substringAfter("tok").substringBefore("\\\""))})

              Activity.RESULT_CANCELED -> {
                plugin.flutterResult!!.error("canceled", requestCode.toString(), data)
              }

              AutoResolveHelper.RESULT_ERROR -> {
                AutoResolveHelper.getStatusFromIntent(data)?.let {
                  plugin.flutterResult!!.error("Error", it.statusMessage, data)
                }
              }
            }
          }
        }
        true
      })
      plugin.paymentsClient = Wallet.getPaymentsClient(plugin.activity!!,
              Wallet.WalletOptions.Builder()
                      .setEnvironment(WalletConstants.ENVIRONMENT_TEST)
                      .build())
      channel.setMethodCallHandler(plugin)
    }
  }

  private fun createPaymentDataRequest(): PaymentDataRequest? {
    // create PaymentMethod
    if (publishableKey == null) {
      print("Please set Stripes' publishable key before calling useNativePay.")
      return null;
    }

    val cardPaymentMethod = JSONObject()
            .put("type", "CARD")
            .put(
                    "parameters",
                    JSONObject()
                            .put("allowedAuthMethods", JSONArray()
                                    .put("PAN_ONLY")
                                    .put("CRYPTOGRAM_3DS"))
                            .put("allowedCardNetworks",
                                    JSONArray()
                                            .put("AMEX")
                                            .put("DISCOVER")
                                            .put("JCB")
                                            .put("MASTERCARD")
                                            .put("VISA"))

                            // require billing address
                            .put("billingAddressRequired", true)
                            .put(
                                    "billingAddressParameters",
                                    JSONObject()
                                            // require full billing address
                                            .put("format", "FULL")

                                            // require phone number
                                            .put("phoneNumberRequired", true)
                            )
            )
            .put("tokenizationSpecification",
                    GooglePayConfig(publishableKey as String).tokenizationSpecification)

    // create PaymentDataRequest
    val paymentDataRequest = JSONObject()
            .put("apiVersion", 2)
            .put("apiVersionMinor", 0)
            .put("allowedPaymentMethods",
                    JSONArray().put(cardPaymentMethod))
            .put("transactionInfo", JSONObject()
                    .put("totalPrice", "10.00")
                    .put("totalPriceStatus", "FINAL")
                    .put("currencyCode", "USD")
            )
            .put("merchantInfo", JSONObject()
                    .put("merchantName", "Example Merchant"))

            // require email address
            .put("emailRequired", true)
            .toString()

    return PaymentDataRequest.fromJson(paymentDataRequest)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")


    } else if (call.method == "setPublishableKey") {
      publishableKey = call.arguments as String
      result.success(null)


    } else if (call.method == "setMerchantIdentifier") {
      merchantIdentifier = call.arguments as String
      result.success(null)


    } else if (call.method == "nativePay") {
      flutterResult = result
      val request = IsReadyToPayRequest.newBuilder()
              .addAllowedPaymentMethod(WalletConstants.PAYMENT_METHOD_CARD)
              .addAllowedPaymentMethod(WalletConstants.PAYMENT_METHOD_TOKENIZED_CARD)
              .build()
      paymentsClient?.isReadyToPay(request)?.addOnCompleteListener { task ->
        try {
          val result = task.getResult(ApiException::class.java)!!
          if (result) {
            val request = createPaymentDataRequest()

            if (request == null) {
              print("Unable to create Google-Pay request")
            } else {

              paymentTask = paymentsClient?.loadPaymentData(request)
              if (paymentTask == null) {
                print("Unable to create Google_pay payment data")
              } else {
                AutoResolveHelper.resolveTask(
                        paymentTask!!,
                        this.activity!!,
                        LOAD_PAYMENT_DATA_REQUEST_CODE
                )
              }
            }
          } else {
            print("Google Pay is not ready, try calling setMerchantIdentifier first.")
          }
        } catch (exception: ApiException) {
          print("exception inside ready w/ Google pay: " + exception.statusCode)
        }
        

      }
    } else if (call.method == "confirmPayment") {
      result.success(null)
    } else {
      result.notImplemented()
    }
  }


}
