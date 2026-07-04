# LiteLLM Enterprise Docker Build

Builds a patched LiteLLM image with enterprise features unlocked. Takes any official `ghcr.io/berriai/litellm` tag, injects a one-line patch into `LicenseCheck.is_premium()` to return `True`, and produces a drop-in replacement image.

## Quick start

```bash
# 1. Build
./build.sh main-stable

# 2. Configure
cp .env.example .env
# fill in LITELLM_MASTER_KEY, POSTGRES_PASSWORD, and provider API keys

# 3. Deploy
docker compose up -d
```

## Build script

```
./build.sh <version> [--push]
```

`<version>` is any tag from `ghcr.io/berriai/litellm` -- for example `main-stable`, `v1.72.0`, or a specific SHA.

Environment variables:

| Variable | Default | Description |
|---|---|---|
| `LITELLM_IMAGE_NAME` | `litellm-enterprise` | Output image name |
| `LITELLM_REGISTRY` | (empty, local only) | Registry prefix for push |

Pass `--push` to push the built image after building.

## Docker Compose

The compose file starts LiteLLM + Postgres. Configurable via `.env`:

| Variable | Default | Description |
|---|---|---|
| `LITELLM_IMAGE` | `litellm-enterprise:main-stable` | Image to run |
| `LITELLM_PORT` | `4000` | Host port |
| `LITELLM_MASTER_KEY` | (required) | Proxy master key |
| `POSTGRES_PASSWORD` | `dbpassword9090` | Postgres password |
| `ANTHROPIC_API_KEY` | | Anthropic provider key |
| `OPENAI_API_KEY` | | OpenAI provider key |

Edit `config.yaml` to add models, callbacks, guardrails, or any other LiteLLM proxy settings.

## How the patch works

`patch_premium.py` runs at image build time. It finds `LicenseCheck.is_premium()` in the installed litellm package using AST parsing and inserts `return True` as the first line of the method body. The rest of the method is unreachable but left in place so the file stays structurally intact.

## Upgrading

```bash
./build.sh v1.73.0
# update .env: LITELLM_IMAGE=litellm-enterprise:v1.73.0
docker compose up -d
```
