# Basic Puppet Load Balancer manifest


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


  $sysPackages = [ "build-essential" , "vim" , "libpcre3-dev" , "libssl-dev"]

  exec { 'apt-get update':
   command => '/usr/bin/apt-get update --fix-missing'
  }

  package { $sysPackages:
    ensure => "installed",

  }

  exec { 'Hosts IP':
   command => "sudo sed -i '1i 33.33.33.30  lb' /etc/hosts",
   path    => "/usr/local/bin/:/bin/:/usr/bin/",
  }

}




# NGINX
# --------------------------

class nginx {

  package { "nginx":
    ensure => latest,
  }


  service { "nginx":
    ensure => running,
    hasrestart => true
  }

  file { "/etc/nginx/sites-enabled/default":
      ensure => absent,
      require => Package["nginx"],
      notify => Service["nginx"]
  }


  file { "/etc/nginx/sites-available/vagrantsite":
      owner  => root,
      group  => root,
      mode   => 644,
      source => "puppet:////vagrant/puppet/files/nginx.conf"
  }

  file { "/etc/nginx/sites-enabled/vagrantsite":
    ensure => symlink,
    target => "/etc/nginx/sites-available/vagrantsite",
    require => Package["nginx"],
    notify => Service["nginx"]
  }




}


# VARNISH
# --------------------------

class varnish {

  package { "varnish":
    ensure => latest,
  }

  file {'varnish.vcl':
    owner   => root,
    group   => root,
    mode    => 0640,
    path    =>  '/etc/varnish/default.vcl',
    source  =>  '/vagrant/puppet/files/varnish.vcl',
  }






}

# AVAHI
# --------------------------

class avahi {

  package { "avahi-daemon":
    ensure => present,
  }

}

# --------------------------


include groups
include system-update
include nginx
include varnish
include avahi

