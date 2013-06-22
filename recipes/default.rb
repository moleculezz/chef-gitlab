#
# Cookbook Name:: gitlab
# Recipe:: default
#
# Copyright (C) 2013 G. Arends
# 
# All rights reserved - Do Not Redistribute
#

# 1. Packages / Dependencies
%w{ build-essential zlib1g-dev libyaml-dev libssl-dev 
        libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl 
        checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev
        python postfix redis-server ruby ruby-dev }.each do |pkg|
  package pkg
end

# 3. System Users
include_recipe "gitlab::user"

# 2. Ruby
gem_package "bundler"
gem_package "rake"
gem_package "charlock_holmes" do
  version "0.6.9.4"
end

if Chef::VERSION == '11.4.4'
  ENV['HOME'] = node['gitlab']['home']
end

# 4. GitLab shell
# Clone Gitlab shell repo from github
git "#{node['gitlab']['home']}/gitlab-shell" do
  repository node['gitlab']['gitlab_shell_url']
  reference node['gitlab']['gitlab_shell_version']
  action :checkout
  user node['gitlab']['user']
  group node['gitlab']['group']
end

# Render gitlab shell config file
template "#{node['gitlab']['home']}/gitlab-shell/config.yml" do
  source "gitlab-shell-config.yml.erb"
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 00644
  notifies :restart, "service[gitlab]", :delayed
end

# Do setup 'gitlab-shell/bin/install'
directory node['gitlab']['repos_path'] do
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 02770
end

directory node['gitlab']['ssh_path'] do
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 00700
end

file "#{node['gitlab']['ssh_path']}/authorized_keys" do
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 00600
end
# End setup 'gitlab-shell/bin/install'

# 5. Database
include_recipe "gitlab::database"


# 6. GitLab
# Clone the Source
git node['gitlab']['app_home'] do
  repository node['gitlab']['gitlab_url']
  reference node['gitlab']['gitlab_branch']
  action :checkout
  user node['gitlab']['user']
  group node['gitlab']['group']
end

# Configure it
template "#{node['gitlab']['app_home']}/config/gitlab.yml" do
  source "gitlab.yml.erb"
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 00644
  notifies :restart, "service[gitlab]", :delayed
end

directory node['gitlab']['satellites_path'] do
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 00755
end

%w{ pids sockets }.each do |dir|
  directory "#{node['gitlab']['app_home']}/tmp/#{dir}" do
    owner node['gitlab']['user']
    group node['gitlab']['group']
    mode 00755
  end
end

directory "#{node['gitlab']['app_home']}/uploads" do
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 00755
end

template "#{node['gitlab']['app_home']}/config/puma.rb" do
  source "puma.rb.erb"
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 00644
  notifies :restart, "service[gitlab]", :delayed
end

template "#{node['gitlab']['home']}/.gitconfig" do
  source "gitconfig.erb"
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 00664
  notifies :restart, "service[gitlab]", :delayed
end

# Configure GitLab DB settings
template "#{node['gitlab']['app_home']}/config/database.yml" do
  source "database.yml.mysql.erb"
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 00644
  notifies :restart, "service[gitlab]", :delayed
end

# Install Gems
execute "gitlab-bundle-install" do
  command "bundle install --deployment --verbose --without development test postgres"
  cwd node['gitlab']['app_home']
  user node['gitlab']['user']
  group node['gitlab']['group']
  environment({ 'LANG' => "en_US.UTF-8", 'LC_ALL' => "en_US.UTF-8" })
  not_if { File.exists?("#{node['gitlab']['app_home']}/vendor/bundle") }
end

# Initialize Database and Activate Advanced Features
execute "gitlab-bundle-rake" do
  command "bundle exec rake gitlab:setup RAILS_ENV=production force=yes && touch .gitlab-setup"
  cwd node['gitlab']['app_home']
  user node['gitlab']['user']
  group node['gitlab']['group']
  not_if { File.exists?("#{node['gitlab']['app_home']}/.gitlab-setup") }
end

# Install Init Script
template "/etc/init.d/gitlab" do
  source "gitlab.init.erb"
  owner "root"
  group "root"
  mode 00755
end

execute "gitlab-autostart-service" do
  command "update-rc.d gitlab defaults 21 && touch .gitlab-service"
  cwd node['gitlab']['app_home']
  user "root"
  group "root"
  not_if { File.exists?("#{node['gitlab']['app_home']}/.gitlab-service") }
  notifies :start, "service[gitlab]", :delayed
end

# Start Your GitLab Instance
service "gitlab" do
  action :nothing
end


# 7. Nginx
# node.default["nginx"]["default_site_enabled"] = false
include_recipe "nginx"

template "#{node['nginx']['dir']}/sites-available/gitlab" do
  source "nginx-site.erb"
  owner "root"
  group "root"
  mode 00644
  notifies :reload, 'service[nginx]'
end

nginx_site 'gitlab' do
  enable true
end
