# == Class: transmission::config
#
# This class handles the main configuration files for the module
#
# == Actions:
#
# * Deploys configuration files and cron
#
# === Authors:
#
# Craig Watson <craig@cwatson.org>
#
# === Copyright:
#
# Copyright (C) Craig Watson
# Published under the Apache License v2.0
#
class transmission::config {

  # == Defaults

  File {
    owner   => 'debian-transmission',
    group   => 'debian-transmission',
    require => Package[$::transmission::params::packages],
  }

  # == Transmission config

  file { '/etc/transmission-daemon':
    ensure => directory,
    mode   => '0770',
  }

  file { '/etc/transmission-daemon/settings.json.puppet':
    ensure  => file,
    mode    => '0600',
    content => template('transmission/settings.json.erb'),
    require => File['/etc/transmission-daemon'],
  }

  # == Transmission Home

  file { $::transmission::params::home_dir:
    ensure => directory,
    mode   => '0770',
  }

  file { "${::transmission::params::home_dir}/settings.json":
    ensure  => link,
    target  => '/etc/transmission-daemon/settings.json',
    require => File[$::transmission::params::home_dir],
  }

  file { $::transmission::params::download_dirs:
    ensure => directory,
    mode   => '0770',
  }

  # == Blocklist update cron

  cron { 'transmission_update_blocklist':
    ensure  => $::transmission::params::cron_ensure,
    command => "/usr/bin/transmission-remote${::transmission::params::remote_command_auth} --blocklist-update > /dev/null",
    require => Package['transmission-cli','transmission-common','transmission-daemon'],
    user    => 'root',
    minute  => '0',
    hour    => '*',
  }

}
