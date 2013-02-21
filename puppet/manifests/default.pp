
# Basic Puppet Default manifest


# PUPPET
# --------------------------

class groups {

  group { "puppet":
      ensure => present,
  }

}

# APACHE
# --------------------------

class apache {

  exec { 'apt-get update':
    command => '/usr/bin/apt-get update --fix-missing'
  }

  package { "apache2":
    ensure => present,
  }

  service { "apache2":
    ensure => running,
    require => Package["apache2"],
  }

  file { '/var/www':
    ensure => link,
    target => "/vagrant",
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

# PHP
# --------------------------

class php {

  package { "php5":
    ensure => present,
  }
 
  package { "php5-cli":
    ensure => present,
  }
 
  package { "php5-mysql":
    ensure => present,
  }
 
  package { "libapache2-mod-php5":
    ensure => present,
  }
}
 

# NGINX
# --------------------------

class nginx {
 
  package { "nginx":
    ensure => latest,
  }


}


# VARNISH
# --------------------------

class varnish {
 
  package { "varnish":
    ensure => latest,
  }


}


# MySQL
# --------------------------

class mysql {

  package {
    ["mysql-client", "mysql-server", "libmysqlclient-dev"]: 
      ensure => installed, 
      #require => Exec['apt-update']
  }

 
  service { "mysql":
    ensure => running,
    require => Package["mysql-server"],
  }
 
  exec { "set-mysql-password":
    unless  => "mysql -uroot -proot",
    path    => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password root",
    require => Service["mysql"],
 
  }
 
  #exec { "create-database":
  #  unless  => "/usr/bin/mysql -usite_development -psite_development site_development",
  #  command => "/usr/bin/mysql -uroot -proot -e \"create database site_development; grant all on site_development.* to site_dev@localhost identified by 'site_development';\"",
  #  require => Service["mysql"],
  #}


}



# --------------------------


include groups
include nginx
include apache
include php
include varnish
include mysql