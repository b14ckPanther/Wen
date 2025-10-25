# Wen AI Search Plan

## Objectives
- Deliver semantic search and recommendations beyond keyword matching.
- Keep provider-agnostic architecture (OpenAI, Vertex AI, local models).
- Control cost/privacy via batching, queues, and minimal logging.

## Proposed Architecture

### 1. Ingestion
1. Firestore trigger `onBusinessChange` (see `infra/functions/src/ai/embeddingQueue.ts`) enqueues documents into `ai_embedding_queue` whenever a business or category changes.
2. Scheduled Cloud Function `scheduledSyncEmbeddings` drains the queue in batches. Future work:
   - Fetch latest business doc.
   - Generate embedding via OpenAI `text-embedding-3-small` (or Vertex AI / local model).
   - Upsert vector + payload into Qdrant, store metadata in Firestore (`businesses/{id}.ai`).
   - Update queue entry status.

### 2. Query Service
1. Mobile app calls `POST /v1/search` on the Cloud Run service (`services/ai-search`). Payload: `{ userId, query, location?, top_k, filters }`.
2. Service flow (mock today, real soon):
   - Verify Firebase ID token (TODO in Milestone I.4).
   - If `AI_SEARCH_MODE=mock`, return canned results for demos/tests.
   - If `AI_SEARCH_MODE=live`, compute query embedding (OpenAI), query Qdrant with filters, rerank, and synthesise explanations via GPT-4o-mini.
3. Response shape:
   ```json
   {
     "query": "coffee",
     "results": [
       {"title": "Top picks near you", "summary": "...", "confidence": 0.86}
     ]
   }
   ```

### 3. Components
| Component                | Technology                         | Notes |
|-------------------------|------------------------------------|-------|
| Ingestion queue         | Firestore + Cloud Functions        | Already scaffolded in I.1 |
| Embedding generator     | OpenAI API / Vertex AI / local     | Start with OpenAI `text-embedding-3-small` |
| Vector store            | Qdrant Cloud                       | Supports payload filters + snapshots |
| Service                 | FastAPI on Cloud Run (`services/ai-search`) | Stub supports `mock`/`live` modes |
| Cache (later)           | Cloud Memorystore (Redis)          | Cache frequent queries |
| Monitoring              | Cloud Logging + Prometheus metrics | Track latency/cost |

### 4. Data schema (Qdrant payload)
```json
{
  "id": "business-001",
  "vector": [ ... ],
  "payload": {
    "name": "Al Madina Bistro",
    "description": "Modern Emirati fusion cuisine",
    "categoryId": "restaurants",
    "plan": "premium",
    "location": { "lat": 25.2048, "lng": 55.2708 },
    "keywords": ["emirati", "fusion"],
    "updatedAt": 1731523200
  }
}
```

### 5. Roadmap
1. **Milestone I** – Mobile AI stub + architecture outline ✔️
2. **Milestone I.1** – Ingestion queue & scheduler scaffold ✔️
3. **Milestone I.2** – FastAPI stub + Dockerfile (mock mode) ✔️
4. **Milestone I.3** – Configure live mode hooks (this milestone): env-driven mode, OpenAI/Qdrant client skeleton, deployment docs.
5. **Milestone I.4** – Implement real embedding + Qdrant calls, secure the endpoint, connect mobile client, add metrics/caching.

### 6. Cost estimates (live mode)
- Embeddings: 5K docs × 300 tokens ≈ 1.5M tokens → ≈ $30 initial, minimal daily updates.
- Qdrant Cloud small tier ≈ $20/mo.
- Cloud Run service (0.5 vCPU) mostly idle → low cost (<$10/mo) plus egress.
- Redis cache ≈ $30/mo when introduced.
- Monitor via Cloud Monitoring alerts.

### 7. Success metrics
- Query latency < 800 ms p95.
- Conversion uplift vs keyword search (A/B once live).
- Owner upgrade influence (AI recommendations clicking into paid plans).
