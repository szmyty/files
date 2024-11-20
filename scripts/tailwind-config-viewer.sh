#!/usr/bin/env bash

pnpm exec npx \
    tailwind-config-viewer \
    --config "${TAILWIND_CONFIG_FILE:-./tailwind.config.ts}" \
    serve \
    --port "${TAILWIND_CONFIG_VIEWER_PORT:-5030}" \
    --open
