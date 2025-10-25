import { firestore } from 'firebase-admin';
import { logger } from 'firebase-functions';

const db = firestore();

export async function syncEmbeddingsBatch() {
  const pending = await db
    .collection('ai_embedding_queue')
    .where('status', '==', 'pending')
    .orderBy('updatedAt')
    .limit(10)
    .get();

  if (pending.empty) {
    logger.info('[AI] No pending embeddings to process.');
    return;
  }

  const batch = db.batch();
  for (const doc of pending.docs) {
    batch.update(doc.ref, {
      status: 'processing',
      updatedAt: firestore.FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
  logger.info(`[AI] Marked ${pending.size} documents as processing. (Embeddings not generated in stub).`);
}
