### Install Ruby  

> install rvm http://rvm.io/  

Tips: reload your shell or open a new terminal window  

> rvm install 2.3.1  

~/.rvm/archives/  

Tips: enter your os password  

### Config Gemfile source  

    gem install bundler  
    bundle config mirror.https://rubygems.org https://gems.ruby-china.com  
    bundle install  

### Run  

    bundle exec ruby main.rb  

### Remote Debug  

    gem install ruby-debug-ide  
    bundle exec rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 12345 main.rb  

you must configure "remoteHost" and "remoteWorkspaceRoot"  

or

    gem 'pry'  
    gem 'pry-byebug'  

then  

    require 'pry'  
    binding.pry  

https://github.com/deivid-rodriguez/pry-byebug  


  

