from __future__ import annotations

from abc import ABC, abstractmethod
from typing import List

from ..config import Settings, settings
from ..clients.openai_client import OpenAIEmbeddingClient
from ..clients.qdrant_client import QdrantVectorStore, VectorSearchHit
from ..schemas import AiSearchRequest, AiSearchResult


class BaseAiSearchService(ABC):
    @abstractmethod
    def search(self, request: AiSearchRequest) -> tuple[str, List[AiSearchResult]]:
        raise NotImplementedError


class MockAiSearchService(BaseAiSearchService):
    def search(self, request: AiSearchRequest) -> tuple[str, List[AiSearchResult]]:
        normalized_query = request.query.strip() or "Arab business"
        results = [
            AiSearchResult(
                title="Top picks near you",
                summary=(
                    f"I found curated {normalized_query.lower()} options based on rating, recency, and plan tier. "
                    "Al Madina Bistro is trending for its Gulf fusion tasting menu, Palm Beauty Lounge offers a Ramadan spa package, "
                    "and Souk Artisan Hub is running a handmade gifts pop-up."
                ),
                confidence=0.86,
            ),
            AiSearchResult(
                title="Why these results?",
                summary=(
                    "Scores weigh reviews, owner responsiveness, and premium plan boosts. "
                    "In live mode this will come from embeddings + Qdrant vector search."
                ),
                confidence=0.69,
            ),
        ][: request.top_k]
        return normalized_query, results


class LiveAiSearchService(BaseAiSearchService):
    def __init__(self, settings: Settings) -> None:
        settings.require_live_credentials()
        self._embedding_client = OpenAIEmbeddingClient(
            settings.openai_api_key,  # type: ignore[arg-type]
            settings.openai_model,
        )
        self._vector_store = QdrantVectorStore(
            settings.qdrant_url,  # type: ignore[arg-type]
            settings.qdrant_api_key,  # type: ignore[arg-type]
            settings.qdrant_collection,
        )

    def _format_result(self, hit: VectorSearchHit) -> AiSearchResult:
        payload = hit.payload
        name = payload.get("name", "Unknown business")
        description = payload.get("description", "No description available.")
        plan = payload.get("plan", "standard")
        summary = f"{name}: {description} (plan: {plan})."

        score = hit.score
        if score > 1:
            confidence = 1 / (1 + score)
        else:
            confidence = max(min(score, 0.99), 0.05)
        return AiSearchResult(title=name, summary=summary, confidence=confidence)

    def search(self, request: AiSearchRequest) -> tuple[str, List[AiSearchResult]]:
        normalized_query = request.query.strip() or "Arab business"
        embedding = self._embedding_client.embed(normalized_query)
        hits = self._vector_store.search(embedding, request.top_k)
        results = [self._format_result(hit) for hit in hits]
        return normalized_query, results


def get_ai_search_service() -> BaseAiSearchService:
    if settings.mode == "live":
        try:
            return LiveAiSearchService(settings)
        except RuntimeError as exc:
            import logging

            logging.getLogger(__name__).warning(
                "Falling back to mock AI search service: %s", exc
            )
            return MockAiSearchService()
    return MockAiSearchService()
