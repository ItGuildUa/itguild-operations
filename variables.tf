variable "secrets" {
  type = object({
    github_token = string
  })

  sensitive = true
}

variable "github" {
  description = "All Github related settigns"

  type = object({
    organization = string

    teams = object({
      maintainers_team = string
      private          = list(string)
      public           = list(string)
    })

    gitops_repo = object({
      enable_protection = bool

      name = string

      contrib_teams  = list(string) // push
      readonly_teams = list(string) // pull
    })

    guild_site_repo = object({
      enable_protection = bool

      name        = string
      description = string
      homepage    = string
      private     = bool

      contrib_teams  = list(string) // push
      readonly_teams = list(string) // pull
    })

    internal_repo = object({
      enable_protection = bool

      name        = string
      description = string
      homepage    = string
      private     = bool

      contrib_teams  = list(string) // push
      readonly_teams = list(string) // pull
    })

    members = list(object({
      name          = string
      admin         = bool
      github_handle = string
      teams         = list(string)
    }))
  })
}
