# =========
# = Notes =
# =========

# The phusion guys have made it so that you can install nginx and passenger in one
# fell swoop, it is for this reason and cleanliness that I haven't decided to install
# nginx and passenger separately, otherwise nginx ends up being dependent on passenger
# so that it can call --add-module within its configure statement - That in itself would
# be strange.

package :nginx, :provides => :webserver do
  puts "** Nginx installed by passenger gem **"
  requires :passenger
  initscript = File.join(File.dirname(__FILE__), 'nginx', 'nginx')
  nginxconf = File.join(File.dirname(__FILE__), 'nginx', 'nginx.conf')

  transfer initscript, "/etc/init.d/nginx", :sudo => true
  transfer nginxconf, "/usr/local/nginx/conf/nginx.conf", :sudo => true

  noop do
    post :install, "sudo chmod +x /etc/init.d/nginx"
    post :install, "sudo /usr/sbin/update-rc.d -f nginx defaults"
    #post :install, "sudo /etc/init.d/apache2 stop"
    post :install, "sudo /etc/init.d/nginx start; true"
    post :install, "sudo /etc/init.d/nginx reload"
  end

  verify do
    has_file "/etc/init.d/nginx"
    has_process "nginx"
    matches_local initscript, "/etc/init.d/nginx"
    matches_local nginxconf, "/usr/local/nginx/conf/nginx.conf"
  end
end

package :passenger do
  description 'Phusion Passenger (mod_rails)'

  requires :libcurl4

  noop do
    pre :install, "/usr/local/rvm/bin/rvm exec gem install passenger --no-rdoc --no-ri"
    post :install, "/usr/local/rvm/bin/rvm exec passenger-install-nginx-module --auto --auto-download --prefix=/usr/local/nginx"
  end

  requires :ruby

  verify do
    has_executable "/usr/local/rvm/gems/ruby-1.9.2-p180/bin/passenger"
    has_executable "/usr/local/nginx/sbin/nginx"
  end
end

package :libcurl4 do
  description "libcurl4-openssl-dev"

  apt "libcurl4-openssl-dev"

  verify do
    has_file "/usr/lib/libcurl.so"
  end
end
