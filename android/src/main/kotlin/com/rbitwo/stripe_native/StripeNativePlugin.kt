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
import org.json.*


class StripeNativePlugin: MethodCallHandler {

  var publishableKey: String? = null
  var merchantIdentifier: String? = null
  var currencyKey: String = "USD"
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
      channel.setMethodCallHandler(plugin)
    }
  }

  private fun createPaymentDataRequest(total: Double, name: String): PaymentDataRequest? {

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
                    .put("totalPrice", total.toString())
                    .put("totalPriceStatus", "FINAL")
                    .put("currencyCode", currencyKey)
            )
            .put("merchantInfo", JSONObject()
                    .put("merchantName", name))

            // don't require email address
            .put("emailRequired", false)
            .toString()

    return PaymentDataRequest.fromJson(paymentDataRequest)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "setPublishableKey") {
      publishableKey = call.arguments as String

      var walletEnvironment = WalletConstants.ENVIRONMENT_TEST
      if ("pk_live" in this.publishableKey!!) {
        walletEnvironment = WalletConstants.ENVIRONMENT_PRODUCTION
      }
      paymentsClient = Wallet.getPaymentsClient(this.activity!!,
              Wallet.WalletOptions.Builder()
                      .setEnvironment(walletEnvironment)
                      .build())
      result.success(null)


    } else if (call.method == "setMerchantIdentifier") {
      merchantIdentifier = call.arguments as String
      result.success(null)

    } else if (call.method == "setCurrencyKey") {

      currencyKey = call.arguments as String
      result.success(null)

    } else if (call.method == "setCountryKey") {

      result.success(null)

    } else if (call.method == "receiptNativePay") {

      var receiptArgs = call.arguments as Map<String, Any>
      var merchantName = receiptArgs["merchantName"] as? String

      if (merchantName == null) {
        return
      }

      var total = 0.0
      receiptArgs.forEach({entry ->
        if (entry.value is Double) {
          total += (entry.value as Double)
        }
      })

      googlePay(result, total, merchantName!!)

    } else if (call.method == "nativePay") {
      var paymentArgs = call.arguments as Map<String, Any>
      var subtotal = paymentArgs["subtotal"] as? Double
      var tip = paymentArgs["tip"] as? Double
      var tax = paymentArgs["tax"] as? Double
      var merchantName = paymentArgs["merchantName"] as? String

      if (subtotal == null || tip == null || tax == null || merchantName == null ) {
        result.error("Incorrect payment parameters", "4", null)
        return
      }

      var total = subtotal!! + tax!! + tip!!

      googlePay(result, total, merchantName)

    } else if (call.method == "confirmPayment") {
      result.success(null)
    } else {
      result.notImplemented()
    }
  }

  private fun googlePay(result: Result, total: Double, name: String) {
    flutterResult = result
    val request = IsReadyToPayRequest.newBuilder()
            .addAllowedPaymentMethod(WalletConstants.PAYMENT_METHOD_CARD)
            .addAllowedPaymentMethod(WalletConstants.PAYMENT_METHOD_TOKENIZED_CARD)
            .build()
    paymentsClient?.isReadyToPay(request)?.addOnCompleteListener { task ->
      try {
        val result = task.getResult(ApiException::class.java)!!
        if (result) {
          val request = createPaymentDataRequest(total, name)

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
  }


}
