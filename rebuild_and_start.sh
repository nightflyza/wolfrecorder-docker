docker stop wolfrec
docker compose build --no-cache
docker compose up -d
docker logs -f wolfrec
