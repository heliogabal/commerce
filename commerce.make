; commerce make file to build distro
core = "7.x"
api = "2"

;projects[drupal][version] = "7.x"
;Use Omega8 core instead of Drupal core:
projects[drupal][type] = "core"
projects[drupal][download][type] = "get"
projects[drupal][download][url] = "http://files.aegir.cc/dev/drupal-7.23.3.tar.gz"
; include the d.o. profile base
;includes[] = "drupal-org.make"


; include commerce profile from github
projects[commerce][type] = "profile"
projects[commerce][download][type] = "git"
projects[commerce][download][url] = "https://github.com/heliogabal/commerce.git"
projects[commerce][download][branch] = "master"

; Patches for Core
;projects[drupal][patch][] = "http://drupal.org/files/issues/install-redirect-on-empty-database-728702-36.patch"
;projects[drupal][patch][] = "http://drupal.org/files/drupal-1470656-14.patch"
;projects[drupal][patch][] = "http://drupal.org/files/drupal-865536-204.patch"
;projects[drupal][patch][] = "http://drupal.org/files/drupal7-allow_change_system-requirements-1772316-18.patch"
;projects[drupal][patch][] = "http://drupal.org/files/1275902-15-entity_uri_callback-D7.patch"

; Profiler Library
libraries[profiler][download][type] = "get"
libraries[profiler][download][url] = "http://ftp.drupal.org/files/projects/profiler-7.x-2.0-beta1.tar.gz"