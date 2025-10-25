from typing import List

from pydantic import BaseModel


class AiSearchRequest(BaseModel):
  query: str
  top_k: int = 5
  latitude: float | None = None
  longitude: float | None = None


class AiSearchResult(BaseModel):
  title: str
  summary: str
  confidence: float


class AiSearchResponse(BaseModel):
  query: str
  results: List[AiSearchResult]
