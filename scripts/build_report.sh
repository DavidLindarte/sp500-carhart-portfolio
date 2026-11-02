#!/usr/bin/env bash
# Render the executed notebook as a static HTML page for GitHub Pages (code + outputs)
set -euo pipefail
jupyter nbconvert notebooks/sp500_carhart_portfolio.ipynb --to html --output-dir docs --output report \
  --HTMLExporter.theme=light
