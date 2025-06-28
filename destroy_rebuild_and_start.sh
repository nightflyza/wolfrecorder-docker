docker compose down
docker compose down -v
docker rmi -f $(docker images -aq)
docker compose build --no-cache
docker compose up -d
docker logs -f wolfrec
