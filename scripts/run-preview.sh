#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export LUMINA_GREETER_PREVIEW=1
exec qs -p "$project_dir"
