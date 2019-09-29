# stripe_native example

- In main.dart, there exists a minimum implementation using an example publishable key and merchant identifier.
- The nativePay button will need to conform to Apple and Google's expectations prior to store submissions, in this example it does not.

### Prior to opening a payment sheet

- Have your publishable key, and merchant identifier linked to a Stripe dashboard.
- Call setPublishableKey() using the key associated with your Stripe project.
- Call setMerchantIdentifier() using the merchant identifier associated with the same Stripe project.

### Opening a payment sheet

- You can either use an Order, or Receipt object to open the payment sheet.
- An Order is an object with a subtotal, tax, and tip amount.
- A receipt is an object with a list of item prices.
- Both helpers will also require a merchant name to display at the bottom of the iOS payment sheet.

### Receipt

- const itemPrices = <String, double>{"Nice Hat": 5.00, "Used Hat" : 1.50};
- var receipt = Receipt(itemPrices, "Hat Store");
- useReceiptNativePay(receipt)

### Order

- subtotal, tax, tip, merchant name
- var order = Order(5.50, 1.0, 2.0, "Some Store");
- useNativePay(order)

### Using the token

- useNativePay and useReceiptNativePay return a Future<String>, the string is a source token that can be used by the Stripe Charge API.
- You'll need to write your own endpoint that takes this token and the transaction amount as parameters.
- Have your endpoint come back and tell the client whether the charge was successful or not.
- On iOS, you'll need to call confirmPayment with a parameter representing the success of the charge.
- confirmPayment is an iOS only function, but calling it on both platforms does not hurt.
- The Apple payment sheet has its own animation, confirmPayment helps show the user whether the charge was succesful or not using that animation.
