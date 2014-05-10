node default
{
  include nginx

  file { ["/var/www",
          "/var/www/pids",
          "/var/www/myapp",
          "/var/www/myapp/current",
          "/var/www/sockets",
          "/var/www/config",
          "/var/www/logs"]:
    ensure => 'directory',
    owner => 'www-data',
    group => 'www-data',
    mode => 0775
  }

  file { '/var/www/myapp/current/config.ru':
    ensure => 'present',
    owner => 'www-data',
    group => 'www-data',
    mode => 0775,
    content => 'run Proc.new {|env| [200, {"Content-Type" => "text/html"}, StringIO.new("Hello Rack!\n")]}'
        
  }

  unicorn::app { 'myapp':
    approot => '/var/www/myapp/current',
    pidfile => '/var/www/pids/myapp.pid',
    socket => '/var/www/sockets/myapp.socket',
    config_file => '/var/www/config/myapp_unicorn.conf.rb',
    log_dir => '/var/www/logs',
    require => [Rbenv::Gem["unicorn"], Rbenv::Gem["rack"]]
  }

  rbenv::install { "www-data":
    home => '/var/www'
  }

  rbenv::compile { "www-data/1.9.3":
    user => "www-data",
    ruby => '1.9.3-p327',
    home => '/var/www',
    global => true
  }

  rbenv::gem { "unicorn":
    user => "www-data",
    ruby => "1.9.3-p327",
    home => '/var/www'
  }

  rbenv::gem { "rack":
    user => "www-data",
    ruby => "1.9.3-p327",
    home => '/var/www'
  }

  nginx::resource::upstream { 'myapp_unicorn':
    ensure => 'present',
    members => [
      'unix:/var/www/sockets/myapp.socket fail_timeout=0'
    ],
  }

  nginx::resource::vhost { 'localhost':
    ensure => 'present',
    proxy => 'http://myapp_unicorn'

  }



}