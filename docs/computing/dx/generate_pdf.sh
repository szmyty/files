#!/usr/bin/env bash

pandoc "developer_experience_outline.md" \
    -o "developer_experience_outline.pdf" \
    --from markdown \
    --template eisvogel.latex \
    --listings \
    --table-of-contents \
    --number-sections \
    --highlight-style pygments \
    --pdf-engine=xelatex \
    --metadata-file=metadata.yaml
