require 'spec_helper'

describe 'puppet::passenger', :type => :class do

    context 'on Debian' do
        let (:params) do
            {
                :puppet_passenger_port => '8140',
                :puppet_docroot        => '/etc/puppet/rack/public/',
                :apache_serveradmin    => 'root', 
                :puppet_site           => 'test.test.com',
                :puppet_conf           => '/etc/puppet/puppet.conf',
                :puppet_ssldir         => '/var/lib/puppet/ssl',
                :certname              => 'test.test.com',
                :conf_dir              => '/etc/puppet'
        }
        end

        let(:facts) do
            { 
                :osfamily        => 'Debian',
                :operatingsystem => 'Debian',
            }
        end
         it {
                should include_class('apache')
                should include_class('puppet::params')
                should contain_package('libapache2-mod-passenger').with(
                    :before => 'File[/etc/puppet/rack]')
                should contain_package('rails').with(
                    :before => 'File[/etc/puppet/rack]'
                )
                should contain_package('librack-ruby').with(
                    :before => 'File[/etc/puppet/rack]'
                )
                should contain_exec('Certificate_Check').with(
                    :command => "puppet cert --generate #{params[:certname]} --trace",
                    :unless  => "/bin/ls #{params[:puppet_ssldir]}/certs/#{params[:certname]}.pem",
                    :path    => '/usr/bin:/usr/local/bin',
                    :require  => "File[#{params[:puppet_conf]}]"
                )
                should contain_file(params[:puppet_docroot]).with(
                    :ensure => 'directory',
                    :owner  => 'puppet',
                    :group  => 'puppet',
                    :mode   => '0755'
                )
                should contain_file('/etc/puppet/rack').with(
                    :ensure => 'directory',
                    :owner  => 'puppet',
                    :group  => 'puppet',
                    :mode   => '0755'
                )
                 should contain_file('/etc/puppet/rack/config.ru').with(
                    :ensure => 'present',
                    :owner  => 'puppet',
                    :group  => 'puppet',
                    :mode   => '0644'
                )
                should contain_ini_setting('puppetmastersslclient').with(
                    :ensure  => 'present',
                    :section => 'master',
                    :setting => 'ssl_client_header',
                    :path    => params[:puppet_conf],
                    :value   =>'SSL_CLIENT_S_DN',
                    :require => "File[#{params[:puppet_conf]}]"
                )
                should contain_ini_setting('puppetmastersslclientverify').with(
                    :ensure  => 'present',
                    :section => 'master',
                    :setting => 'ssl_client_verify_header',
                    :path    => params[:puppet_conf],
                    :value   =>'SSL_CLIENT_VERIFY',
                    :require => "File[#{params[:puppet_conf]}]"
                )
        }
    end
end
