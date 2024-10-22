ARG PGVECTORS_TAG
ARG BITNAMI_TAG
FROM tensorchord/pgvecto-rs-binary:pg${BITNAMI_TAG%%.*}-${PGVECTORS_TAG}-${TARGETARCH} AS pgvectors
FROM debian:bullseye-slim AS builder

COPY --from=pgvectors /pgvecto-rs-binary-release.deb /
RUN dpkg -x /pgvecto-rs-binary-release.deb /tmp/pgvectors

ARG BITNAMI_TAG
FROM bitnami/postgresql:${BITNAMI_TAG}

ARG BITNAMI_TAG

# drop to root to install packages
USER root

COPY --from=builder /tmp/pgvectors/usr/lib/postgresql/${BITNAMI_TAG%%.*}/lib/* /opt/bitnami/postgresql/lib/
COPY --from=builder /tmp/pgvectors/usr/share/postgresql/${BITNAMI_TAG%%.*}/extension/* /opt/bitnami/postgresql/share/extension/

USER 1001

ENV POSTGRESQL_EXTRA_FLAGS="-c shared_preload_libraries=vectors.so"
