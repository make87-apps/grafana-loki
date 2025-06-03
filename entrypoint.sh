#!/bin/sh
set -e

# Create folder for temporary config
mkdir -p /tmp/loki
: > /tmp/loki/loki.yaml  # clear or create config file

# Extract config from env
config=$(echo "$MAKE87_CONFIG" | jq -c '.config')
storage_path=$(echo "$config" | jq -r '.storage_path // "/loki"')
object_store=$(echo "$config" | jq -r '.object_store // "filesystem"')

# Write Loki configuration
cat <<EOF >> /tmp/loki/loki.yaml
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1  # ← ADD THIS LINE
  chunk_idle_period: $(echo "$config" | jq -r '.chunk_idle_period // "5m"')

schema_config:
  configs:
    - from: 2022-01-01
      store: boltdb-shipper
      object_store: ${object_store}
      schema: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb_shipper:
    active_index_directory: ${storage_path}/index
    cache_location: ${storage_path}/index_cache
    shared_store: ${object_store}

  filesystem:
    directory: ${storage_path}/chunks

limits_config:
  retention_period: $(echo "$config" | jq -r '.retention_period // "7d"')
  max_entries_limit_per_query: $(echo "$config" | jq -r '.max_entries_limit_per_query // 5000')

compactor:
  working_directory: ${storage_path}/compactor
EOF

# Start Loki with the generated config
exec loki -config.file=/tmp/loki/loki.yaml -target=all
