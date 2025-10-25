import asyncio

from httpx import AsyncClient

from api.main import app


async def test_health_endpoint():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


async def test_ai_search_stub():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post(
            "/v1/search",
            headers={"Authorization": "Bearer test-token"},
            json={"query": "Coffee", "top_k": 1},
        )
    assert response.status_code == 200
    data = response.json()
    assert data["query"].lower().startswith("coffee")
    assert len(data["results"]) == 1
    assert "Gulf" in data["results"][0]["summary"]


if __name__ == "__main__":
    asyncio.run(test_health_endpoint())
    asyncio.run(test_ai_search_stub())
