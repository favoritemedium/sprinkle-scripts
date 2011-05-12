Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'stack', '*.rb')].each do |package|
  require package
end

policy :stack, :roles => :app do
  requires :init
  requires :nginx
  requires :passenger
  requires :ruby
  requires :mysql
  requires :git
end

deployment do
  delivery :capistrano do
    begin
      recipes 'Capfile'
    rescue LoadError
      recipes 'deploy'
    end
  end

  # source based package installer defaults
  source do
    prefix   '/usr/local'
    archives '/usr/local/sources'
    builds   '/usr/local/build'
  end
end

# Depend on a specific version of sprinkle
begin
  gem 'sprinkle', ">= 0.2.3"
rescue Gem::LoadError
  puts "sprinkle 0.2.3 required.\n Run: `sudo gem install sprinkle`"
  exit
end
