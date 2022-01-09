# Teams

resource "github_team" "public_teams" {
  for_each = toset(var.github.teams.public)

  name    = each.key
  privacy = "closed"

  lifecycle {
    ignore_changes = [
      etag,
    ]
  }
}

resource "github_team" "private_teams" {
  for_each = toset(var.github.teams.private)

  name    = each.key
  privacy = "secret"

  lifecycle {
    ignore_changes = [
      etag,
    ]
  }
}

### Guild Site Repo

resource "github_repository" "guild_site" {
  name         = var.github.guild_site_repo.name
  description  = var.github.guild_site_repo.description
  homepage_url = var.github.guild_site_repo.homepage

  visibility = var.github.guild_site_repo.private ? "private" : "public"

  vulnerability_alerts = true

  has_issues    = false
  has_projects  = false
  has_wiki      = false
  has_downloads = false
  is_template   = false

  allow_auto_merge   = false
  allow_rebase_merge = false
  allow_squash_merge = false

  delete_branch_on_merge = true
  license_template       = "mit"

  archive_on_destroy = true

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      etag,
    ]
  }
}

### Guild Internal Projects Repo

resource "github_repository" "internal_repo" {
  name         = var.github.internal_repo.name
  description  = var.github.internal_repo.description
  homepage_url = var.github.internal_repo.homepage

  visibility = var.github.internal_repo.private ? "private" : "public"

  has_issues    = false
  has_projects  = false
  has_wiki      = false
  has_downloads = false
  is_template   = false

  allow_auto_merge   = false
  allow_rebase_merge = false
  allow_squash_merge = false

  delete_branch_on_merge = true
  license_template       = "mit"

  archive_on_destroy = true

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      etag,
    ]
  }
}

### Guild Operations Repo

data "github_repository" "guild_operations" {
  full_name = "${var.github.organization}/${var.github.gitops_repo.name}"
}

### Repo teams

locals {
  all_teams = merge(github_team.public_teams, github_team.private_teams)
}

resource "github_team_repository" "guild_site_contrib" {
  count      = length(var.github.guild_site_repo.contrib_teams)
  team_id    = local.all_teams[var.github.guild_site_repo.contrib_teams[count.index]].id
  repository = github_repository.guild_site.name
  permission = "push"

  lifecycle {
    ignore_changes = [
      etag,
    ]
  }
}

resource "github_team_repository" "guild_site_readonly" {
  count      = length(var.github.guild_site_repo.readonly_teams)
  team_id    = local.all_teams[var.github.guild_site_repo.readonly_teams[count.index]].id
  repository = github_repository.guild_site.name
  permission = "pull"

  lifecycle {
    ignore_changes = [
      etag,
    ]
  }
}

resource "github_team_repository" "guild_operations_contrib" {
  count      = length(var.github.gitops_repo.contrib_teams)
  team_id    = local.all_teams[var.github.gitops_repo.contrib_teams[count.index]].id
  repository = data.github_repository.guild_operations.name
  permission = "push"

  lifecycle {
    ignore_changes = [
      etag,
    ]
  }
}

resource "github_team_repository" "guild_operations_readonly" {
  count      = length(var.github.gitops_repo.readonly_teams)
  team_id    = local.all_teams[var.github.gitops_repo.readonly_teams[count.index]].id
  repository = data.github_repository.guild_operations.name
  permission = "pull"

  lifecycle {
    ignore_changes = [
      etag,
    ]
  }
}

resource "github_team_repository" "guild_intrenal_contrib" {
  count      = length(var.github.internal_repo.contrib_teams)
  team_id    = local.all_teams[var.github.internal_repo.contrib_teams[count.index]].id
  repository = github_repository.internal_repo.name
  permission = "push"

  lifecycle {
    ignore_changes = [
      etag,
    ]
  }
}

resource "github_team_repository" "guild_intrenal_readonly" {
  count      = length(var.github.internal_repo.readonly_teams)
  team_id    = local.all_teams[var.github.internal_repo.readonly_teams[count.index]].id
  repository = github_repository.internal_repo.name
  permission = "pull"

  lifecycle {
    ignore_changes = [
      etag,
    ]
  }
}

### Protection

locals {
  maintainers_handles = [
    for member in var.github.members : member.github_handle
    if contains(member.teams, var.github.teams.maintainers_team)
  ]
}

data "github_user" "maintainers" {
  count    = length(local.maintainers_handles)
  username = local.maintainers_handles[count.index]
}

resource "github_branch_protection" "guild_site_protection" {
  count                           = var.github.guild_site_repo.enable_protection ? 1 : 0
  repository_id                   = github_repository.guild_site.name
  pattern                         = "main"
  enforce_admins                  = true
  require_signed_commits          = true
  require_conversation_resolution = true

  allows_deletions    = false
  allows_force_pushes = false

  required_status_checks {
    /* contexts = ["Generate Pages"] */
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    restrict_dismissals             = true
    dismissal_restrictions          = data.github_user.maintainers[*].node_id
    require_code_owner_reviews      = true
    required_approving_review_count = 2
  }

  push_restrictions = data.github_user.maintainers[*].node_id
}

resource "github_branch_protection" "guild_operations_protection" {
  count                           = var.github.gitops_repo.enable_protection ? 1 : 0
  repository_id                   = data.github_repository.guild_operations.name
  pattern                         = "main"
  enforce_admins                  = false
  require_signed_commits          = true
  require_conversation_resolution = true

  allows_deletions    = false
  allows_force_pushes = true
}

resource "github_branch_protection" "guild_internal_protection" {
  count                           = var.github.internal_repo.enable_protection ? 1 : 0
  repository_id                   = github_repository.internal_repo.name
  pattern                         = "main"
  enforce_admins                  = true
  require_signed_commits          = true
  require_conversation_resolution = true

  allows_deletions    = false
  allows_force_pushes = false

  required_status_checks {
    /* contexts = [] */
  }

  required_pull_request_reviews {
    dismiss_stale_reviews  = true
    restrict_dismissals    = true
    dismissal_restrictions = data.github_user.maintainers[*].node_id
  }

  push_restrictions = data.github_user.maintainers[*].node_id
}

### Memberships

locals {
  org_members = { for member in var.github.members : member.github_handle => member.admin ? "admin" : "member" }
}

resource "github_membership" "org_membership" {
  for_each = local.org_members
  username = each.key
  role     = each.value
}

locals {
  membership = tolist(flatten([
    for member in var.github.members : [
      for team in var.github.teams : {
        username   = member.github_handle
        team_id    = local.all_teams[team].id
        maintainer = contains(member.teams, var.github.teams.maintainers_team)
      } if contains(member.teams, team)
    ]
  ]))
}

resource "github_team_membership" "membership" {
  count    = length(local.membership)
  team_id  = local.membership[count.index].team_id
  username = local.membership[count.index].username
  role     = local.membership[count.index].maintainer ? "maintainer" : "member"

  lifecycle {
    ignore_changes = [
      etag,
    ]
  }
}
