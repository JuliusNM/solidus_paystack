$( document ).ready(function() {
    $('#checkout_form_payment').submit(function () {
        const checkedPaymentMethod = $('#payment-method-fields input[type="radio"]:checked').val();
        const paystackPaymentMethodId = $("#paystack_checkout_payload").data("paymentgateway");
        if (paystackPaymentMethodId.toString() === checkedPaymentMethod) {
            if (typeof window.event.data === "undefined") {
                payNowWithPaystack(window.event);
            }
            return true;
        }
    });
});

function payNowWithPaystack(event){
    const currentOrder = $("#paystack_checkout_payload").data("current_order_id");
    const orderTotal = $("#paystack_checkout_payload").data("order_total");
    const email = $("#paystack_checkout_payload").data("billing_email");
    const currency = $("#paystack_checkout_payload").data("currency");
    payWithPaystack(event, currentOrder, orderTotal, email, currency);
}

function payWithPaystack(event, orderId, amount, email, currency) {
    event.preventDefault();
    const secret = $("#paystack_checkout_payload").data("secret");
    const amount_kobo = String(amount) * 100
    let handler = PaystackPop.setup({
        key: secret,
        email: email,
        currency:currency,
        amount: amount_kobo,
        ref: orderId,
        onClose: function(){
            location.reload();
        },
        callback: function() {
            $('#checkout_form_payment').submit();
        }
    });
    handler.openIframe();
}