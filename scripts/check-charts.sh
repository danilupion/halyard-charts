#!/usr/bin/env bash
# What CI checks (.github/workflows/chart-ci.yml), runnable before a push: the library chart and every chart linted
# strictly, then every chart rendered with its defaults and with each ci/*-values.yaml. No cluster needed.
set -euo pipefail
cd "$(dirname "$0")/.."

helm lint --strict charts/common

for c in charts/*/*; do
  [ -f "$c/Chart.yaml" ] || continue
  helm dependency update "$c"
  helm lint --strict "$c"
done

for c in charts/*/*; do
  [ -f "$c/Chart.yaml" ] || continue
  # ci/default-values.yaml marks charts whose bare defaults cannot
  # render (required values); every ci/*-values.yaml is rendered
  if [ ! -f "$c/ci/default-values.yaml" ]; then
    echo "--- $c (default values)"
    helm template test "$c" > /dev/null
  fi
  for f in "$c"/ci/*-values.yaml; do
    [ -e "$f" ] || continue
    echo "--- $c ($f)"
    helm template test "$c" -f "$f" > /dev/null
  done
done
