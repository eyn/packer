define unicorn::app (
  $approot,
  $pidfile,
  $socket,
  $config_file,
  $config_template = 'unicorn/unicorn.conf.rb.erb',
  $log_dir         = undef,
  $backlog         = '2048',
  $workers         = $::processorcount,
  $user            = 'www-data',
  $group           = 'www-data',
  $timeout         = 30,
  $rack_env        = 'production',
  $preload_app     = false,
) {


  $cmd = "unicorn -D -E ${rack_env} -c ${config_file}"

  service { "unicorn_${name}":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    start      => "/etc/init.d/unicorn_${name} start",
    stop       => "/etc/init.d/unicorn_${name} stop",
    restart    => "/etc/init.d/unicorn_${name} reload",
    status     => "/etc/init.d/unicorn_${name} status",
    require    => [File["/etc/init.d/unicorn_${name}"], File[$config_file]]
  }

  file { "/etc/init.d/unicorn_${name}":
    owner   => 'root',
    group   => '0',
    mode    => '0755',
    content => template('unicorn/unicorn-init.erb'),
    notify  => Service["unicorn_${name}"],
  }

  file { $config_file:
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template($config_template),
    notify  => Service["unicorn_${name}"];
  }
}