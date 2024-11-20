#!/usr/bin/env bash

pnpm exec dotenv \
    -e dx.env \
    -- bash -c \
    printenv | sort
