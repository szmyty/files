#!/usr/bin/env bash

pnpm exec storybook \
    -- -p "${STORYBOOK_PORT:-6006}" \
    -c "${STORYBOOK_CONFIG_FILE:-.storybook}"
