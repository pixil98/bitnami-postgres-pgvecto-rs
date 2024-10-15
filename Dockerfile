ARG PG_MAJOR
ARG PGVECTORS_TAG
ARG TARGETARCH
ARG BITNAMI_TAG
FROM tensorchord/pgvecto-rs-binary:pg${PG_MAJOR}-${PGVECTORS_TAG}-${TARGETARCH} AS pgvectors

ARG BITNAMI_TAG
FROM bitnami/postgresql:${BITNAMI_TAG}

ARG BITNAMI_TAG

# drop to root to install packages
USER root

COPY --from=pgvectors /pgvecto-rs-binary-release.deb /tmp/pgvectors.deb

RUN mkdir /tmp/pgvectors && \
    dpkg -x /tmp/pgvectors.deb /tmp/pgvectors && \
    cp -r /tmp/pgvectors/usr/lib/postgresql/${BITNAMI_TAG%%.*}/lib/* /opt/bitnami/postgresql/lib/ && \
    cp -r /tmp/pgvectors/usr/share/postgresql/${BITNAMI_TAG%%.*}/extension/* /opt/bitnami/postgresql/share/extension/ && \
    rm -rf /tmp/pgvectors /tmp/pgvectors.deb

USER 1001

ENV POSTGRESQL_EXTRA_FLAGS="-c shared_preload_libraries=vectors.so"
