#!/usr/bin/env bash

COMPOSE_DIR="$HOME/.immich-app"

# Default action = up
ACTION="${1:-up}"

cd "$COMPOSE_DIR" || exit 1

case "$ACTION" in
    up|"")
        sudo docker compose up -d
        ;;
    down|-d)
        sudo docker compose down
        ;;
    restart|-r)
        sudo docker compose down
        sudo docker compose up -d
        ;;
    status|-s)
        sudo docker compose ps
        ;;
    logs|-l)
        sudo docker compose logs -f
        ;;
    *)
        echo "Usage: immich {up|down|restart|status|logs}"
        exit 1
        ;;
esac
