FROM ubuntu:16.04

ARG BUILDER_UID=9999

ENV PATH /home/builder/.local/bin:$PATH

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    zip \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --no-log-init --shell /bin/bash --uid $BUILDER_UID builder
USER builder
WORKDIR /home/builder
