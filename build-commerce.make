; commerce make file to build distro
core = "7.x"
api = "2"

; include the d.o. profile base
includes[] = "drupal-org-core.make"

; include commerce profile from github
projects[commerce][type] = "profile"
projects[commerce][download][type] = "git"
projects[commerce][download][url] = "https://github.com/heliogabal/commerce.git"
projects[commerce][download][branch] = "master"
