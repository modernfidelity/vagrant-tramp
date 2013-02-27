# Basic Puppet Database manifest


# PUPPET
# --------------------------

class groups {

  group { "puppet":
      ensure => present,
  }

}

include groups




# SYSTEM-UPDATE
# --------------------------


class system-update {


  $sysPackages = [ "build-essential" , "vim", "git-core"]

  exec { 'apt-get update':
   command => '/usr/bin/apt-get update --fix-missing'
  }

  package { $sysPackages:
    ensure => "installed",
    
  }

}


include system-update


# Percona APT Repo
# --------------------------

class percona-apt-repo {


  exec { 'percona-add-repo-key':
    command => 'gpg --keyserver  hkp://keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A',
    path    => "/usr/local/bin/:/bin/:/usr/bin/",
   
  }

  exec { 'percona-add-repo-key2':
    command => 'gpg -a --export CD2EFD2A | sudo apt-key add -',
    path    => "/usr/local/bin/:/bin/:/usr/bin/",
  }
  

  file {'percona-source':
    owner   => root,
    group   => root,
    mode    => 0644,
    path    =>  '/etc/apt/sources.list.d/percona-repo.list',
    source  =>  '/vagrant/puppet/files/percona-repo.list',
  }



  exec { 'apt-get update':
   command => '/usr/bin/apt-get update --fix-missing'
  }

  # RESOURCES RUN ORDER
  EXEC['percona-add-repo-key'] -> EXEC['percona-add-repo-key2'] -> File['percona-source'] -> EXEC['apt-get update'] 



}



# Percona MySQL 5.5 Server + Client
# ---------------------------------

class percona {


  package {
    ["percona-server-server-5.5" , "percona-server-client-5.5"]: 
      ensure => installed, 
  }

  service { "mysql":
    ensure => running,
    require => Package["percona-server-server-5.5"],
  }

  
  exec { "set-mysql-password":
    unless  => "mysql -uroot -proot",
    path    => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password root",
    require => Service["mysql"],
 
  }
 

  file {'my.cnf':
    owner   => root,
    group   => root,
    mode    => 0644,
    path    =>  '/etc/mysql/my.cnf',
    source  =>  '/vagrant/puppet/files/my.cnf',
  }

  
  exec { "database-create":
    unless  => "/usr/bin/mysql -uroot -proot drupal",
    #command => "/usr/bin/mysql -uroot -proot -e \"create database ; grant all on my_website.* to vagrant@localhost identified by 'vagrant';\"",
    command => "/usr/bin/mysql -uroot -proot -e \"create database my_website; \"",
    require => Service["mysql"],
  }


  exec { "database-import":

    onlyif => '/usr/bin/test -f /vagrant/www/database.sql',
    command     => "/usr/bin/mysql -uroot -proot my_website < /vagrant/www/database.sql",
    logoutput   => true,
    
  }


  exec { "database-perms":
    command => "/usr/bin/mysql -uroot -proot -e \"GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'root';flush privileges;\"",
    require => Service["mysql"],
 
  }


  # RESOURCES RUN ORDER

  SERVICE['mysql'] -> EXEC['set-mysql-password'] -> EXEC['database-create'] -> EXEC['database-import'] -> EXEC['database-perms']->File['my.cnf']



}


include percona-apt-repo
include percona



Class['percona-apt-repo']->Class['percona']

