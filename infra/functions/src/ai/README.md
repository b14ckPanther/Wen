# AI Embedding Queue (Stub)

Two entry points:
- `onBusinessChange` (Firestore trigger) enqueues business records into `ai_embedding_queue`.
- `scheduledSyncEmbeddings` (Pub/Sub scheduled) marks queued items as processing (no actual embeddings yet).

Future work:
- Integrate OpenAI/Vertex AI embedding APIs.
- Push vectors into Qdrant.
- Update queue entries with success/error and clean them up.
