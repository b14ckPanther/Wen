import logging
import os
from dataclasses import dataclass

import firebase_admin
from firebase_admin import auth, credentials

logger = logging.getLogger(__name__)


@dataclass
class Settings:
    mode: str = os.getenv("AI_SEARCH_MODE", "mock").strip().lower()
    openai_api_key: str | None = os.getenv("OPENAI_API_KEY")
    openai_model: str = os.getenv("OPENAI_EMBEDDING_MODEL", "text-embedding-3-small")
    qdrant_url: str | None = os.getenv("QDRANT_URL")
    qdrant_api_key: str | None = os.getenv("QDRANT_API_KEY")
    qdrant_collection: str = os.getenv("QDRANT_COLLECTION", "wen-businesses")
    firebase_project_id: str | None = os.getenv("FIREBASE_PROJECT_ID")
    firebase_credentials_path: str | None = os.getenv("FIREBASE_CREDENTIALS_PATH")

    def require_live_credentials(self) -> None:
        missing = []
        if not self.openai_api_key:
            missing.append("OPENAI_API_KEY")
        if not self.qdrant_url:
            missing.append("QDRANT_URL")
        if not self.qdrant_api_key:
            missing.append("QDRANT_API_KEY")
        if not self.firebase_project_id:
            missing.append("FIREBASE_PROJECT_ID")
        if missing:
            raise RuntimeError(
                "Missing configuration: " + ", ".join(missing) +
                ". Set these environment variables or keep AI_SEARCH_MODE=mock."
            )


settings = Settings()
logger.info("AI search service running in %s mode", settings.mode)


if settings.firebase_project_id:
    if not firebase_admin._apps:  # type: ignore[attr-defined]
        if settings.firebase_credentials_path:
            cred = credentials.Certificate(settings.firebase_credentials_path)
            logger.info("Initializing Firebase app with service account credentials.")
        else:
            cred = credentials.ApplicationDefault()
            logger.info("Initializing Firebase app using application default credentials.")
        firebase_admin.initialize_app(cred, {
            "projectId": settings.firebase_project_id,
        })
else:
    logger.warning("FIREBASE_PROJECT_ID not set; live mode auth verification will fail.")


def verify_firebase_token(id_token: str) -> dict:
    try:
        return auth.verify_id_token(id_token)
    except Exception as exc:  # pylint: disable=broad-except
        logger.warning("Failed to verify Firebase token: %s", exc)
        raise
