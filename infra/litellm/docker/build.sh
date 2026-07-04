#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="${LITELLM_IMAGE_NAME:-litellm-enterprise}"
REGISTRY="${LITELLM_REGISTRY:-}"

usage() {
    echo "Usage: $0 <litellm-version> [--push]"
    echo ""
    echo "  litellm-version   Tag from ghcr.io/berriai/litellm (e.g. main-stable, v1.72.0)"
    echo "  --push            Push the built image to the registry"
    echo ""
    echo "Environment:"
    echo "  LITELLM_IMAGE_NAME   Output image name (default: litellm-enterprise)"
    echo "  LITELLM_REGISTRY     Registry prefix (default: none, local only)"
    exit 1
}

if [[ $# -lt 1 ]]; then
    usage
fi

VERSION="$1"
PUSH=false
if [[ "${2:-}" == "--push" ]]; then
    PUSH=true
fi

TAG="${VERSION}"
FULL_IMAGE="${IMAGE_NAME}:${TAG}"
if [[ -n "$REGISTRY" ]]; then
    FULL_IMAGE="${REGISTRY}/${FULL_IMAGE}"
fi

echo "Building ${FULL_IMAGE} from ghcr.io/berriai/litellm:${VERSION}"

docker build \
    --build-arg "LITELLM_VERSION=${VERSION}" \
    -t "${FULL_IMAGE}" \
    -f "${SCRIPT_DIR}/Dockerfile" \
    "${SCRIPT_DIR}"

echo "Built ${FULL_IMAGE}"

if $PUSH; then
    echo "Pushing ${FULL_IMAGE}"
    docker push "${FULL_IMAGE}"
fi
