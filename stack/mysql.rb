require "yaml"
package :mysql, :provides => :database do
  description 'MySQL Database'
  apt %w( mysql-server mysql-client libmysqlclient-dev ) do
    CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), "..", "/database.yml"))["production"]
    #DB_PASSWORD = CONFIG["password"]
    #ROOT_PASSWORD = CONFIG["rootpassword"]
    DB_PASSWORD = "!geylang!"
    ROOT_PASSWORD = "!geylang!"
    post :install, "service mysql stop; true"
    post :install, "service mysql start"
    post :install, "mysqladmin -u root password #{ROOT_PASSWORD}"
    #post :install, "echo 'CREATE DATABASE IF NOT EXISTS beechfork; GRANT ALL PRIVILEGES ON beechfork.* TO beechfork@localhost IDENTIFIED BY \"#{DB_PASSWORD}\";'|mysql -u root -p#{ROOT_PASSWORD}"
  end

  verify do
    has_executable 'mysql'
    has_executable 'mysqld'
    has_process 'mysqld'
    # check that both users were created and have the correct passwords
    @commands << "mysqladmin -u root -p#{ROOT_PASSWORD} ping"
    @commands << "mysqladmin -u beechfork -p#{DB_PASSWORD} ping"
  end

end
