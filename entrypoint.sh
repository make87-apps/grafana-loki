#!/bin/sh
set -e

mkdir -p /tmp/loki
: > /tmp/loki/loki.yaml  # clear or create config

config=$(echo "$MAKE87_CONFIG" | jq -c '.config')

cat <<EOF >> /tmp/loki/loki.yaml
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
    active_index_directory: $(echo "$config" | jq -r '.storage_path // "/tmp/loki"')/index
    cache_location: $(echo "$config" | jq -r '.storage_path // "/tmp/loki"')/index_cache
    shared_store: $(echo "$config" | jq -r '.object_store // "filesystem"')

  filesystem:
    directory: $(echo "$config" | jq -r '.storage_path // "/tmp/loki"')/chunks

limits_config:
  retention_period: $(echo "$config" | jq -r '.retention_period // "7d"')
  max_entries_limit_per_query: $(echo "$config" | jq -r '.max_entries_limit_per_query // 5000')
EOF

exec loki -config.file=/tmp/loki/loki.yaml
