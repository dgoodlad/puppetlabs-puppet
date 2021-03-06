# Class: puppet::storeconfigs
#
# This class installs and configures the puppetdb terminus pacakge
#
# Parameters:
#   ['puppet_confdir']         - The config directory of puppet
#   ['puppet_service']         - The service needing to be notified of the change puppetmasterd or httpd
#   ['puppet_master_package']  - The name of the puppetmaster pacakge
#   ['dbport']                 - The port of the puppetdb
#   ['dbserver']               - The dns name of the puppetdb server
#   ['puppet_conf']            - The puppet config file
#
# Actions:
# - Configures the puppet to use stored configs
#
# Requires:
# - Inifile
# - Class['puppet::storeconfigs']
#
# Sample Usage:
#   class { 'puppet::storeconfigs':
#       puppet_service             => Service['httpd'],
#       dbport                     => 8081,
#       dbserver                   => 'localhost'
#       puppet_master_package      => 'puppetmaster'
#   }
#
class puppet::storeconfigs(
    $dbserver,
    $dbport,
    $puppet_service,
    $puppet_master_package,
    $puppet_confdir =  $::puppet::params::confdir,
    $puppet_conf    =  $::puppet::params::puppet_conf,
)inherits puppet::params {

if ! defined(Class['puppetdb::master::config']) {
      class{ 'puppetdb::master::config':
        puppetdb_server => $dbserver,
        puppetdb_port   => $dbport,
        puppet_confdir  => $puppet_confdir,
        puppet_conf     => $puppet_conf,
        restart_puppet  => false,
        notify          => $puppet_service,
      }
  }  
    
  exec { "createkeypuppetdb":
    command => "puppetdb-ssl-setup",
    path    => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
    creates => "/etc/puppetdb/ssl/keystore.jks",
    before  => Class['puppetdb::master::config'],
    require => [Package['puppetdb'],Package[$puppet_master_package]],
    notify  => Service['puppetdb'],
  }
}
