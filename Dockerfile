FROM grafana/loki:2.9.4

USER root
RUN apk add --no-cache jq
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
USER nobody

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
