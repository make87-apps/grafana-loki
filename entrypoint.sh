#!/bin/sh
set -e

mkdir -p /loki
: > /loki/loki.yaml  # clear or create config

config=$(echo "$MAKE87_CONFIG" | jq -c '.config')

# Top-level defaults
cat <<EOF >> /loki/loki.yaml
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    ring:
      kvstore:
        store: inmemory
  chunk_idle_period: $(echo "$config" | jq -r '.chunk_idle_period // "5m"')

schema_config:
  configs:
    - from: 2022-01-01
      store: boltdb-shipper
      object_store: $(echo "$config" | jq -r '.object_store // "filesystem"')
      schema: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb_shipper:
    active_index_directory: $(echo "$config" | jq -r '.storage_path // "/loki"')/index
    cache_location: $(echo "$config" | jq -r '.storage_path // "/loki"')/index_cache
    shared_store: $(echo "$config" | jq -r '.object_store // "filesystem"')

  filesystem:
    directory: $(echo "$config" | jq -r '.storage_path // "/loki"')/chunks

limits_config:
  retention_period: $(echo "$config" | jq -r '.retention_period // "7d"')
  max_entries_limit_per_query: $(echo "$config" | jq -r '.max_entries_limit_per_query // 5000')
EOF

exec loki -config.file=/loki/loki.yaml

