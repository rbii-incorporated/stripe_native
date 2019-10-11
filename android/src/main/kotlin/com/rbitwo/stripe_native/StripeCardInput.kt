package com.rbitwo.stripe_native

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.text.Editable
import android.text.Spannable
import android.text.TextWatcher
import android.util.AttributeSet
import android.view.View
import com.google.android.material.snackbar.Snackbar
import com.stripe.android.ApiResultCallback
import com.stripe.android.model.Card
import com.stripe.android.model.PaymentMethod
import com.stripe.android.model.PaymentMethodCreateParams
import com.stripe.android.view.CardInputWidget
import java.lang.Exception
import com.stripe.android.Stripe

class StripeCardInput: Activity() {

    abstract class CardWatcher: TextWatcher {
        override fun afterTextChanged(s: Editable?) {

        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.stripe_card_input)

    }

    lateinit var stripeClient: StripeNativePlugin
    lateinit var stripeView: View

    override fun onCreateView(parent: View?, name: String?, context: Context?, attrs: AttributeSet?): View {
        stripeView = super.onCreateView(parent, name, context, attrs)

        //stripeView.findViewById<CardInputWidget>(R.id.card_input_widget).setCardNumberTextWatcher()

        stripeView.findViewById<View>(R.id.doneButton).setOnClickListener { getToken() }

        return stripeView
    }

    private fun getToken() {
        val cardInputWidget = stripeView.findViewById<View>(R.id.card_input_widget) as CardInputWidget

        if (cardInputWidget.card != null) {

            if (stripeClient.publishableKey == null) {
                //TODO hand back error for lack of publishable key
                return
            }
            
            val token = Stripe(stripeClient.activity!!.applicationContext, stripeClient.publishableKey!!).createTokenSynchronous(cardInputWidget.card!!)

        } else {
            stripeView.let {
                Snackbar.make(it, "The card info you entered is not correct", Snackbar.LENGTH_LONG)
                        .show()
            }
        }

    }


}

