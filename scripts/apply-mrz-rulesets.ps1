#requires -Version 7.0
$ErrorActionPreference = "Stop"

$Org = if ($env:ORG) { $env:ORG } else { "moon-rize-official" }
$ApiVersion = "2022-11-28"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw "GitHub CLI (gh) is required." }
gh auth status
if ($LASTEXITCODE -ne 0) { throw "Run: gh auth login" }

Write-Host "Ensuring music-sorter uses main as its default branch..."
gh api --method PATCH -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: $ApiVersion" "/repos/$Org/music-sorter" -f default_branch=main | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Failed to set music-sorter default branch." }

$rulesets = (gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: $ApiVersion" "/orgs/$Org/rulesets") | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw "Unable to read organization rulesets. Use an organization-owner account." }

function Upsert-Ruleset {
  param([string]$Name, [hashtable]$Payload)
  $existing = $rulesets | Where-Object { $_.name -eq $Name } | Select-Object -First 1
  $tmp = [System.IO.Path]::GetTempFileName()
  try {
    $Payload | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $tmp -Encoding utf8
    if ($existing) {
      Write-Host "Updating $Name"
      gh api --method PUT -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: $ApiVersion" "/orgs/$Org/rulesets/$($existing.id)" --input $tmp | Out-Null
    } else {
      Write-Host "Creating $Name"
      gh api --method POST -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: $ApiVersion" "/orgs/$Org/rulesets" --input $tmp | Out-Null
    }
    if ($LASTEXITCODE -ne 0) { throw "Failed to apply ruleset: $Name" }
  } finally {
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
  }
}

$default = @{
  name = "MRZ-01 Default Branch Protection"
  target = "branch"
  enforcement = "active"
  bypass_actors = @(@{ actor_id = $null; actor_type = "OrganizationAdmin"; bypass_mode = "always" })
  conditions = @{
    repository_name = @{ include = @("~ALL"); exclude = @(); protected = $false }
    ref_name = @{ include = @("~DEFAULT_BRANCH"); exclude = @() }
  }
  rules = @(
    @{ type = "deletion" },
    @{ type = "non_fast_forward" },
    @{ type = "pull_request"; parameters = @{
      allowed_merge_methods = @("merge","squash","rebase")
      dismiss_stale_reviews_on_push = $false
      require_code_owner_review = $false
      require_last_push_approval = $false
      required_approving_review_count = 0
      required_review_thread_resolution = $true
    }}
  )
}

$tags = @{
  name = "MRZ-04 Release Tag Protection"
  target = "tag"
  enforcement = "active"
  bypass_actors = @(@{ actor_id = $null; actor_type = "OrganizationAdmin"; bypass_mode = "always" })
  conditions = @{
    repository_name = @{ include = @("~ALL"); exclude = @(); protected = $false }
    ref_name = @{ include = @("refs/tags/v*"); exclude = @() }
  }
  rules = @(@{ type = "deletion" }, @{ type = "non_fast_forward" })
}

Upsert-Ruleset "MRZ-01 Default Branch Protection" $default
Upsert-Ruleset "MRZ-04 Release Tag Protection" $tags

Write-Host ""
Write-Host "Done. Verify: https://github.com/organizations/$Org/settings/rules"