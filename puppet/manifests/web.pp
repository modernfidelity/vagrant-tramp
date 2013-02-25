# Basic Puppet Apache Webserver manifest


# PUPPET
# --------------------------

class groups {

  group { "puppet":
      ensure => present,
  }

}



# SYSTEM-UPDATE
# --------------------------


class system-update {


  $sysPackages = [ "build-essential" ]

  exec { 'apt-get update':
   command => '/usr/bin/apt-get update --fix-missing'
  }

  package { $sysPackages:
    ensure => "installed",
    
  }

}


# APACHE
# --------------------------

class apache {



  package { "apache2":
    ensure => present,
  }

  service { "apache2":
    ensure => running,
    require => Package["apache2"],
  }

  file { '/var/www':
    ensure => link,
    target => "/vagrant/www",
    notify => Service['apache2'],
    force  => true
  }




  #file { "default-apache2":
  #  path    => "/etc/apache2/sites-available/default",
  #  ensure  => file,
  #  require => Package["apache2"],
  #  source  => "puppet:///modules/apache2/default",
  #  notify  => Service["apache2"]
  #}


}


# MEMCACHE
# --------------------------

class memcached {

  package { "memcached":
    ensure => present,
  }

  service { "memcached":
    ensure => running,
    require => Package["memcached"],
  }

}

# PHP
# --------------------------

class php {

  package { "php5":
    ensure => present,
  }

  package { "php5-dev":
    ensure => present,
  }
 
  package { "php-apc":
    ensure => present,
  }

  package { "php5-cli":
    ensure => present,
  }
 
  package { "php5-gd":
    ensure => present,
  }


  package { "php-pear":
    ensure => present,
  }

  package { "php5-memcache":
    ensure => present,
  }

  package { "php5-mysql":
    ensure => present,
  }
 
  package { "libapache2-mod-php5":
    ensure => present,
  }

}
 

# --------------------------


include groups
include system-update
include memcached
include apache
include php
