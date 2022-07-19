
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
    const orderIdWithTimestamp = currentOrder + "_" + Date.now();
    payWithPaystack(event, orderTotal, email, currency, orderIdWithTimestamp)
}

function payWithPaystack(event, amount, email,  currency, orderIdWithTimestamp){
    event.preventDefault();
    const amount_kobo = String(amount) * 100
    const amount_kobo_int = parseInt(amount_kobo);
    const url = "https://api.paystack.co/transaction/initialize";
    const xhttp = new XMLHttpRequest();
    const secret = $("#paystack_checkout_payload").data("secret");

    const postObj = {
        "email": email,
        "amount": amount_kobo_int,
        "currency":currency,
        "reference": orderIdWithTimestamp
    }

    let post = JSON.stringify(postObj)
    xhttp.open("POST", url, true);
    xhttp.setRequestHeader('Content-type', 'application/json');
    xhttp.setRequestHeader('Authorization', 'Bearer '+ secret);
    xhttp.onreadystatechange = function() {
        if(this.readyState === 4 && this.status === 200) {
            const jsonResponse = JSON.parse(this.responseText);
            const paystack = new PaystackPop();
            const ref = jsonResponse["data"]["access_code"]
            const paystackPop = paystack.resumeTransaction(ref);

            paystackPop.onSuccess = function () {
                $('#checkout_form_payment').submit();
            }

            paystackPop.onCancel = function () {
                const button = $('input[type="submit"][name="commit"]')
                button.disabled = true
                location.reload();
            };
        }
    };
    xhttp.send(post);
}
