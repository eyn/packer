node default
{
  include nginx

  nginx::resource::vhost { 'localhost':
    www_root => '/tmp/www'
  }
	
}