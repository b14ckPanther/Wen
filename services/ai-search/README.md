# Wen AI Search Service (Stub)

This FastAPI service will host the semantic search endpoint consumed by the mobile app. Milestone I.2 provides a mocked implementation returning canned results while we integrate embeddings and Qdrant.

## Local development

```bash
cd services/ai-search
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export AI_SEARCH_MODE=mock  # or live once embeddings are ready
uvicorn api.main:app --reload

# optional: run tests
pytest tests -q
```

API Docs available at `http://127.0.0.1:8000/docs`.

## Docker build

```bash
docker build -t wen-ai-search:dev .

For **live mode** deployments set:

- `AI_SEARCH_MODE=live`
- `OPENAI_API_KEY` (and optional `OPENAI_EMBEDDING_MODEL`)
- `QDRANT_URL`, `QDRANT_API_KEY`, `QDRANT_COLLECTION`
- `FIREBASE_PROJECT_ID` and optionally `FIREBASE_CREDENTIALS_PATH` (service account JSON) or rely on Workload Identity / ADC.

In live mode the service will verify Firebase ID tokens and attempt to hit OpenAI/Qdrant. Make sure credentials are available in Cloud Run before flipping the mode.
```

## Deployment plan (future)
1. Push the container to Artifact Registry (`gcloud builds submit` or `gcloud run deploy`).
2. Configure environment variables for OpenAI/Qdrant keys.
3. Restrict invocation to authenticated clients via Firebase ID tokens.
4. Add Cloud Run IAM & VPC connector if needed.
