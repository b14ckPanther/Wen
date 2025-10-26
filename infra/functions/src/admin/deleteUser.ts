import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const deleteUserCallable = functions.https.onCall(
  async (data, context) => {
    const targetUserId: string | undefined = data?.userId;
    if (!context.auth?.uid) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required.",
      );
    }

    if (!targetUserId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "userId is required",
      );
    }

    const adminUid = context.auth.uid;
    const db = admin.firestore();
    const adminDoc = await db.collection("users").doc(adminUid).get();
    const role = adminDoc.get("role");
    if (role !== "admin") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can delete users.",
      );
    }

    const userRef = db.collection("users").doc(targetUserId);
    await userRef.delete().catch(() => undefined);

    try {
      await admin.auth().deleteUser(targetUserId);
    } catch (error: any) {
      if (error?.code !== "auth/user-not-found") {
        throw new functions.https.HttpsError(
          "internal",
          error?.message ?? "Failed to remove user from Authentication.",
        );
      }
    }

    const ownedBusinesses = await db
      .collection("businesses")
      .where("ownerId", "==", targetUserId)
      .get();

    const batch = db.batch();
    ownedBusinesses.docs.forEach((doc) => {
      batch.update(doc.ref, {
        ownerId: null,
        approved: false,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
    if (!ownedBusinesses.empty) {
      await batch.commit();
    }

    return { status: "ok" };
  },
);
