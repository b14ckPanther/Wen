import logging

from fastapi import Depends, FastAPI, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from .config import settings, verify_firebase_token
from .schemas import AiSearchRequest, AiSearchResponse
from .services.ai_search import get_ai_search_service

app = FastAPI(title="Wen AI Search", version="0.3.0")
security = HTTPBearer(auto_error=False)
ai_service = get_ai_search_service()
logger = logging.getLogger(__name__)


def verify_token(credentials: HTTPAuthorizationCredentials | None = Depends(security)):
    if settings.mode == "mock":
        return "mock-user"
    if credentials is None:
        raise HTTPException(status_code=401, detail="Missing Authorization header")
    try:
        decoded = verify_firebase_token(credentials.credentials)
    except Exception as exc:  # pylint: disable=broad-except
        raise HTTPException(status_code=401, detail="Invalid Firebase ID token") from exc
    return decoded.get("uid", "unknown")


@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.post("/v1/search", response_model=AiSearchResponse)
def ai_search(payload: AiSearchRequest, uid: str = Depends(verify_token)):
    normalized_query, results = ai_service.search(payload)
    logger.debug(
        "Served AI search request via %s (query=%s, uid=%s)",
        ai_service.__class__.__name__,
        normalized_query,
        uid,
    )
    return AiSearchResponse(query=normalized_query, results=results)
