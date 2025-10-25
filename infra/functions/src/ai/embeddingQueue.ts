import { Change, EventContext } from 'firebase-functions';
import { firestore } from 'firebase-admin';

const db = firestore();

export interface EmbeddingQueueEntry {
  docPath: string;
  status: 'pending' | 'processing' | 'success' | 'error';
  errorMessage?: string;
  updatedAt: FirebaseFirestore.FieldValue;
}

export async function enqueueDocument(change: Change<FirebaseFirestore.DocumentSnapshot>, context: EventContext) {
  const after = change.after;
  if (!after.exists) {
    // Document deleted; we can consider removing from vector store later.
    return;
  }

  const docPath = after.ref.path;
  await db.collection('ai_embedding_queue').doc(after.id).set(<EmbeddingQueueEntry>{
    docPath,
    status: 'pending',
    updatedAt: firestore.FieldValue.serverTimestamp(),
  });
}
