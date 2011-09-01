package :ruby do
  description "Ruby (RVM)"

  requires :ruby_core, :rvm, :rvm_ruby_19, :bundler
end

package :ruby_core do
  requires :ruby_dependencies

  apt 'ruby-full rubygems'

  verify do
    has_executable 'ruby'
    has_executable 'irb'
    has_executable 'rdoc'
    has_executable 'ri'
    has_executable 'gem'
  end
end

package :ruby_dependencies do
  requires :build_essential
  apt 'build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev autoconf'
end

package :rvm_sourcing_for_root do
  push_text "[[ -s \"/usr/local/rvm/scripts/rvm\" ]] && . \"/usr/local/rvm/scripts/rvm\"", "/root/.bashrc", :sudo => true
  #runner "source /root/.bashrc"
end

# == RVM: References
#   - http://blog.ninjahideout.com/posts/a-guide-to-a-nginx-passenger-and-rvm-server
#   - http://blog.ninjahideout.com/posts/the-path-to-better-rvm-and-passenger-integration
#   - http://rvm.beginrescueend.com/integration/passenger
#   - http://rvm.beginrescueend.com/deployment/best-practices/
#   - http://rvm.beginrescueend.com/workflow/scripting

package :rvm do
  description "RVM - Ruby Version Manager"

  requires :ruby_core, :git, :rvm_sourcing_for_root

  apt 'ruby-full' do
    # Install RVM.
    post :install, 'curl -s https://rvm.beginrescueend.com/install/rvm -o rvm-installer'
    post :install, 'chmod +x rvm-installer'
    post :install, './rvm-installer --version latest'
    post :install, '/usr/local/rvm/bin/rvm reload'

    # Add user to rvm group (root added already by RVM installer).
    post :install, %Q{adduser beechfork rvm}
  end
  
  verify do
    # Ensure RVM binary was setup properly: should be a function, not a executable.
    logger.info "has_file"
    has_file '/usr/local/rvm/bin/rvm'

    logger.info "insure sourced in ~/.profile"
    # Ensure RVM is sourced in ~/.profile.
    ['/etc/skel', '/root', "/home/beechfork"].each do |path|
      has_file "#{path}/.profile"
    end
  end
end

package :rvm_ruby_19 do
  description "Ruby 1.9.2"
  version '1.9.2-p180'

  requires :rvm

  noop do
    # Install Ruby 1.9.
    pre :install, '/usr/local/rvm/bin/rvm install 1.9.2-p180'
    post :install, '/usr/local/rvm/bin/rvm default 1.9.2-p180'
  end

  verify do
    has_executable '/usr/local/rvm/rubies/ruby-1.9.2-p180/bin/ruby'
  end
end


package :rvm_rubygems do
  description "Rubygems for Ruby 1.9.2"

  requires :rvm_ruby_19

  noop do
    pre :install, '/usr/local/rvm/bin/rvm rubygems latest'
  end

  verify do
    has_executable '/usr/local/rvm/rubies/ruby-1.9.2-p180/bin/gem'
  end
end

package :bundler do
  description "Bundler - Ruby dependency manager"
  requires :rvm_rubygems
  noop { pre :install, '/usr/local/rvm/bin/rvm gem install bundler' }
  verify { has_executable '/usr/local/rvm/gems/ruby-1.9.2-p180/bin/bundle' }
end

