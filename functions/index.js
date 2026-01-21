const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

/**
 * Handle M-Pesa STK Push Callback
 * This endpoint is what Safaricom calls after a user completes/cancels the STK push.
 */
exports.mpesaCallback = functions.https.onRequest(async (req, res) => {
  const body = req.body;
  
  if (!body.Body || !body.Body.stkCallback) {
    console.error("Invalid M-Pesa callback body");
    return res.status(400).send("Invalid callback");
  }

  const result = body.Body.stkCallback;
  const resultCode = result.ResultCode;
  const merchantRequestId = result.MerchantRequestID;
  const checkoutRequestId = result.CheckoutRequestID;

  console.log(`Processing callback for CheckoutRequestID: ${checkoutRequestId}`);

  try {
    // Find the booking associated with this checkoutRequestId
    const bookingSnapshot = await db.collection("bookings")
        .where("checkoutRequestId", "==", checkoutRequestId)
        .limit(1)
        .get();

    if (bookingSnapshot.empty) {
      console.error(`No booking found for checkoutRequestId: ${checkoutRequestId}`);
      return res.status(404).send("Booking not found");
    }

    const bookingDoc = bookingSnapshot.docs[0];
    const bookingId = bookingDoc.id;

    if (resultCode === 0) {
      // Success: Payment completed
      const callbackMetadata = result.CallbackMetadata.Item;
      const mpesaReceiptNumber = callbackMetadata.find((item) => item.Name === "MpesaReceiptNumber").Value;
      const amount = callbackMetadata.find((item) => item.Name === "Amount").Value;

      console.log(`Payment successful: ${mpesaReceiptNumber} for amount ${amount}`);

      await db.collection("bookings").doc(bookingId).update({
        status: "confirmed",
        paymentStatus: "paid",
        mpesaReceiptNumber: mpesaReceiptNumber,
        paidAt: admin.firestore.FieldValue.serverTimestamp(),
        statusHistory: admin.firestore.FieldValue.arrayUnion("confirmed"),
      });
    } else {
      // Failure or Cancelled
      console.log(`Payment failed or cancelled: ${result.ResultDesc}`);
      await db.collection("bookings").doc(bookingId).update({
        status: "payment_failed",
        paymentError: result.ResultDesc,
      });
    }

    return res.status(200).send("Success");
  } catch (error) {
    console.error("Error processing callback:", error);
    return res.status(500).send("Internal error");
  }
});
