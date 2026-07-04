ARG LITELLM_VERSION=main-stable
FROM ghcr.io/berriai/litellm:${LITELLM_VERSION}

USER root

COPY patch_premium.py /tmp/patch_premium.py
RUN python3 /tmp/patch_premium.py && rm /tmp/patch_premium.py
