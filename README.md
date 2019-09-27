# Stripe Native

#### Create chargeable stripe tokens using Apple and Google Pay.

This plugin will give you easy access to the Apple and Google Pay payment sheets. And provide one-time source tokens that are used to create a [Stripe Charge](https://stripe.com/docs/api/charges/create). 

![Apple Pay](https://user-images.githubusercontent.com/7946558/65780165-02838700-e0fe-11e9-9db9-5fe4e44ed819.gif)

## Setup

### Both (Required)
To begin one will need a Stripe project, from there collect a publishable key.

### iOS (Required)

On the Apple Developer portal, one will need to create a merchant identifier. Then connect that identifier to the Stripe project. 

From the Stripe dashboard, create a signing certificate to share with Apple, then upload the signed certificate to Stripe.

![Merchant Identifier](https://user-images.githubusercontent.com/7946558/65781103-e1239a80-e0ff-11e9-9f0a-178fcdf1e490.png)

Lastly, open the apps' iOS module. Add the newly created identifier to the project's signing capabilities.

![Signing Capablities](https://user-images.githubusercontent.com/7946558/65781273-2c3dad80-e100-11e9-89fb-ebc4d480c0f0.png)

### Android (Optional)

On the Google Play console, add the merchant identifier to the app capabilites. This makes the merchant known to Google Pay. With it, users will not see a warning saying this app is an unidentified merchant.

## Functions

### Set Publishable Key

Prior to calling native pay, set the publishable key.

```dart
StripeNative.setPublishableKey("pk_test_yZuUz6Sqm83H4lA7SrlAvYCh003MvJiJlR");
```

### Set Merchant Identifier

Prior to calling native pay, set the merchant identifier.

```dart
StripeNative.setMerchantIdentifier("merchant.rbii.stripe-example");
```

### Native-Pay

There are two ways to create a payment sheet. With a list of items and prices, or with some subtotal, tax and tip.

Both methods require a merchant name to display at the bottom of the sheet. 

```dart
// subtotal, tax, tip, merchant name
var order = Order(5.50, 1.0, 2.0, "Some Store");
var token = await StripeNative.useNativePay(order);
```

```dart
const receipt = <String, double>{"Nice Hat": 5.00, "Used Hat" : 1.50};
var aReceipt = Receipt(receipt, "Hat Store");
var token = await StripeNative.useReceiptNativePay(aReceipt);
```

### Confirm Payment (iOS)

On iOS the payment sheet spins and ends with a check or X depending on the result passed in. During the spinning, query an endpoint for a charge using the token. This function does not affect Android.

```dart
// call charge endpoint w/ token
const wasCharged = await AppAPI.charge(token, amount);
// then show success or failure
StripeNative.confirmPayment(wasCharged);
```
