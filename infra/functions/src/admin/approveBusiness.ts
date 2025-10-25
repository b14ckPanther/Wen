import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const approveBusinessCallable = functions.https.onCall(
  async (data, context) => {
    const businessId: string | undefined = data?.businessId;
    if (!context.auth?.token) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required.",
      );
    }
    const userId = context.auth.uid;
    const db = admin.firestore();
    const userDoc = await db.collection("users").doc(userId).get();
    const role = userDoc.get("role");
    if (role !== "admin") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can approve businesses.",
      );
    }
    if (!businessId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "businessId is required",
      );
    }
    const businessRef = db.collection("businesses").doc(businessId);
    const businessSnap = await businessRef.get();
    if (!businessSnap.exists) {
      throw new functions.https.HttpsError("not-found", "Business not found.");
    }
    await businessRef.update({
      approved: true,
      approvedAt: admin.firestore.FieldValue.serverTimestamp(),
      approvedBy: userId,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { status: "ok" };
  },
);
