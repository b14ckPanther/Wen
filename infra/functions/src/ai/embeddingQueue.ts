import {Change, EventContext} from 'firebase-functions';
import {firestore} from 'firebase-admin';
import {DocumentSnapshot, FieldValue} from 'firebase-admin/firestore';

const db = firestore();

export interface EmbeddingQueueEntry {
  docPath: string;
  status: 'pending' | 'processing' | 'success' | 'error';
  errorMessage?: string;
  updatedAt: FieldValue;
}

/**
 * Enqueue business document for AI embedding processing.
 * @param {Change<FirebaseFirestore.DocumentSnapshot>} change Firestore change.
 * @param {EventContext} context Function context (unused).
 */
export async function enqueueDocument(
    change: Change<DocumentSnapshot>, context: EventContext) {
  const after = change.after;
  if (!after.exists) {
    // Document deleted; we can consider removing from vector store later.
    return;
  }

  const docPath = after.ref.path;
  const queueRef = db.collection('ai_embedding_queue').doc(after.id);
  await queueRef.set(<EmbeddingQueueEntry>{
    docPath,
    status: 'pending',
    updatedAt: firestore.FieldValue.serverTimestamp(),
  });
}
