#!/usr/bin/env bash
# Decides whether the Check formula workflow has a formula to install.
#
# Usage: formula-present.sh [<previous-commit>]   (run from the repo root)
#
# - Formula/harell.rb exists: present=true.
# - It is missing but <previous-commit> had it: the change removes the
#   formula, which would leave Homebrew users with nothing to install. Fail.
#   An intentional removal is merged by a maintainer who can bypass checks.
# - It is missing and never existed (a new tap): present=false, so the
#   workflow skips the install steps and passes.
#
# The result goes to $GITHUB_OUTPUT when set, otherwise to stdout.
set -euo pipefail

formula=Formula/harell.rb
previous="${1:-}"
output="${GITHUB_OUTPUT:-/dev/stdout}"

if [ -f "$formula" ]; then
  echo "present=true" >> "$output"
  exit 0
fi

if [ -n "$previous" ] && git cat-file -e "$previous:$formula" 2>/dev/null; then
  echo "::error::This change removes $formula. Merge an intentional removal with a maintainer bypass."
  exit 1
fi

echo "::notice::No $formula; nothing to install"
echo "present=false" >> "$output"
