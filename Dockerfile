FROM grafana/loki:2.9.4


USER root
RUN apk add --no-cache jq
USER nobody

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
