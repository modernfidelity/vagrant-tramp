# Class: MYSQL 
#
#   This class installs mysql client software, configure password, creates a database and imports
#   a database.sql from the shared www folder if it exists...
#
# @TODO : 
#
#

class mysql {

  apt::source { "percona":
    location    => "http://repo.percona.com/apt",
    release     => "lucid",
    repos       => "main",
    include_src => true,
    key         => "CD2EFD2A",
    key_server  => "keys.gnupg.net",
  }

  package { "percona-server-common-5.5":
    ensure  => installed,
    require => [ Apt::Source["percona"], Package["mysql-common"] ],
  }

  package { "mysql-common":
    ensure  => absent,
    require => [ Package["mysql-client"], Package["mysql-server"] ],
  }





}