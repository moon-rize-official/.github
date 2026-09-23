#!/usr/bin/env bash
set -euo pipefail

ORG="${ORG:-moon-rize-official}"
API_VERSION="${GITHUB_API_VERSION:-2026-03-10}"

command -v gh >/dev/null 2>&1 || { echo "ERROR: GitHub CLI (gh) is required." >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is required." >&2; exit 1; }

echo "Moon Rize GitHub ruleset installer"
echo "Organization: $ORG"
echo

gh auth status >/dev/null

rulesets_json="$(gh api --paginate   -H "Accept: application/vnd.github+json"   -H "X-GitHub-Api-Version: $API_VERSION"   "/orgs/$ORG/rulesets" | jq -s 'add')"

upsert_ruleset() {
  local name="$1"
  local payload="$2"
  local id

  id="$(jq -r --arg name "$name" '.[] | select(.name == $name) | .id' <<<"$rulesets_json" | head -n1)"

  if [[ -n "$id" && "$id" != "null" ]]; then
    echo "Updating ruleset: $name (id=$id)"
    gh api --method PUT       -H "Accept: application/vnd.github+json"       -H "X-GitHub-Api-Version: $API_VERSION"       "/orgs/$ORG/rulesets/$id"       --input "$payload" >/dev/null
  else
    echo "Creating ruleset: $name"
    gh api --method POST       -H "Accept: application/vnd.github+json"       -H "X-GitHub-Api-Version: $API_VERSION"       "/orgs/$ORG/rulesets"       --input "$payload" >/dev/null
  fi
}

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/default-branch.json" <<'JSON'
{
  "name": "MRZ-01 Default Branch Protection",
  "target": "branch",
  "enforcement": "active",
  "bypass_actors": [
    {
      "actor_id": null,
      "actor_type": "OrganizationAdmin",
      "bypass_mode": "always"
    }
  ],
  "conditions": {
    "repository_name": {
      "include": ["~ALL"],
      "exclude": [],
      "protected": false
    },
    "ref_name": {
      "include": ["~DEFAULT_BRANCH"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "deletion"
    },
    {
      "type": "non_fast_forward"
    },
    {
      "type": "pull_request",
      "parameters": {
        "allowed_merge_methods": ["merge", "squash", "rebase"],
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_approving_review_count": 0,
        "required_review_thread_resolution": true
      }
    }
  ]
}
JSON

cat >"$tmpdir/release-tags.json" <<'JSON'
{
  "name": "MRZ-04 Release Tag Protection",
  "target": "tag",
  "enforcement": "active",
  "bypass_actors": [
    {
      "actor_id": null,
      "actor_type": "OrganizationAdmin",
      "bypass_mode": "always"
    }
  ],
  "conditions": {
    "repository_name": {
      "include": ["~ALL"],
      "exclude": [],
      "protected": false
    },
    "ref_name": {
      "include": ["refs/tags/v*"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "deletion"
    },
    {
      "type": "non_fast_forward"
    }
  ]
}
JSON

upsert_ruleset "MRZ-01 Default Branch Protection" "$tmpdir/default-branch.json"
upsert_ruleset "MRZ-04 Release Tag Protection" "$tmpdir/release-tags.json"

echo
echo "Rulesets applied."
echo "Verify at: https://github.com/organizations/$ORG/settings/rules"
echo
echo "NOTE: This baseline deliberately does not require a named status check yet."
echo "After MRZ / Validate has run successfully in every repository, add it as a required"
echo "status check or required workflow at the organization level."
