github = {
  organization = "ItGuildUa"

  teams = {
    maintainers_team = "Operators"

    private = ["Members", "Operators"]
    public  = ["Editors"]
  }

  gitops_repo = {
    enable_protection = true
    name              = "itguild-operations"

    contrib_teams  = ["Operators"] // push
    readonly_teams = []            // pull
  }

  guild_site_repo = {
    enable_protection = true

    name        = "itguild-site"
    description = "Сайт гільдії ІТ Фахівців"
    homepage    = "https://www.itguild.org.ua/"
    private     = false

    contrib_teams  = ["Editors"] // push
    readonly_teams = ["Members"] // pull
  }

  internal_repo = {
    enable_protection = false

    name        = "itguild-internal-projects"
    description = "Внутрішні проекти гільдії"
    homepage    = "https://www.itguild.org.ua/"
    private     = true

    contrib_teams  = ["Members"] // push
    readonly_teams = []          // pull
  }

  members = [{ # Admin
    name          = "Taras"
    admin         = true
    github_handle = "tarantot"
    teams         = ["Members", "Editors", "Operators"]
    }, {
    name          = "Yuriy Yarosh"
    admin         = true
    github_handle = "yuriy-yarosh"
    teams         = ["Members", "Editors", "Operators"]
    }, { # Members
    name          = "Alex Raiev"
    admin         = false
    github_handle = "alex-raiev"
    teams         = ["Members"]
    }, {
    name          = "Yegor Chumakov"
    admin         = false
    github_handle = "egopher"
    teams         = ["Members", "Editors"]
    }, {
    name          = "Igor Filippov"
    admin         = false
    github_handle = "IgorFilippov3"
    teams         = ["Members"]
    }, {
    name          = "Włodzimierz Rożkow"
    admin         = false
    github_handle = "rozhok"
    teams         = ["Members"]
    }, {
    name          = "Julia Kotunova"
    admin         = false
    github_handle = "yullifer"
    teams         = ["Members"]
  }]
}
