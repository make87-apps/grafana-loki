# Grafana Loki
This is a make87 app that wraps Grafana Loki, the log aggregation system from Grafana Labs optimized for cost-effective, scalable, and label-based log storage.

It offers a production-ready deployment and seamless integration with make87, including automated configuration and compatibility with any log-forwarding agent like Vector.


>  **Licensing Notice**
>  This app wraps the official Grafana Loki project, licensed under the Apache License 2.0.
>  All original rights and trademarks belong to Grafana Labs, the creators of Loki.

## Features
- 📦 Easily deploy Grafana Loki as a logging backend on any node
- 🧩 Full compatibility with various log shippers (Fluent Bit, Promtail, etc.)
- ⚙️ Configure Loki’s retention and storage limits through make87
- 🔐 Secure HTTP endpoints for ingesting and querying logs
- 📊 Works out-of-the-box with Grafana dashboards via Loki data source

## Configuration
Loki’s configuration is rendered via loki.yaml, dynamically managed through make87’s configuration interface. Storage, schema, server, and limits sections are available for customization.