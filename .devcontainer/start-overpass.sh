#!/usr/bin/env bash
# Starts the local Overpass server, importing the Finland data first if the database is missing.
cd "$(dirname "$0")/.." || exit 1

COMPOSE="docker compose -f docker-compose.overpass.yml"
DB_DIR="overpass_db"

mkdir -p "$DB_DIR"

# replicate_id is the last file the import writes; a partial import leaves other files (even nodes.bin) behind
if [ ! -f "$DB_DIR/replicate_id" ]; then
    if [ -n "$(docker ps -q --filter name=maptoposter-overpass-run)" ]; then
        echo "Overpass import is already running"
        exit 0
    fi

    # The container runs as uid 10001 and must be able to write to the host folder
    chmod -R a+rwX "$DB_DIR" 2>/dev/null || true

    echo "Overpass database is missing, importing Finland (this takes a while)..."
    $COMPOSE run --rm --no-deps --entrypoint /opt/overpass/bin/import_osm_data.sh overpass \
        --diff-url=https://download.geofabrik.de/europe/finland-updates/ \
        --data-source=https://download.geofabrik.de/europe/finland-latest.osm.pbf \
        --meta=no || { echo "Overpass import failed"; exit 1; }
fi

echo "Starting local Overpass server..."
$COMPOSE up -d || { echo "Could not start local Overpass server" >&2; exit 1; }
echo "Local Overpass server started."
