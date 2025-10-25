from __future__ import annotations

from dataclasses import dataclass
from typing import List

from qdrant_client import QdrantClient
from qdrant_client.models import ScoredPoint


@dataclass
class VectorSearchHit:
    id: str
    score: float
    payload: dict


class QdrantVectorStore:
    def __init__(self, url: str, api_key: str, collection_name: str) -> None:
        self._client = QdrantClient(url=url, api_key=api_key)
        self._collection = collection_name

    def search(self, embedding: List[float], top_k: int) -> List[VectorSearchHit]:
        scored_points: List[ScoredPoint] = self._client.search(
            collection_name=self._collection,
            query_vector=embedding,
            limit=top_k,
            with_payload=True,
        )
        hits: List[VectorSearchHit] = []
        for point in scored_points:
            payload = point.payload or {}
            identifier = str(point.id)
            hits.append(VectorSearchHit(id=identifier, score=float(point.score), payload=payload))
        return hits
