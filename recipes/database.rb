#
# Cookbook Name:: gitlab
# Recipe:: database
#
# Copyright (C) 2013 G. Arends
# 
# All rights reserved - Do Not Redistribute
#

include_recipe "database::mysql"
include_recipe "mysql::server"

# Enable secure password generation
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
node.set_unless['gitlab']['database']['password'] = secure_password
ruby_block "save node data" do
  block do
    node.save
  end
  not_if { Chef::Config[:solo] }
end

# Helper variables
database = node['gitlab']['database']['database']
database_user = node['gitlab']['database']['username']
database_password = node['gitlab']['database']['password']
database_host = node['gitlab']['database']['host']
database_connection = {
  :host => database_host,
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

mysql_database database do
  connection database_connection
  encoding node['gitlab']['database']['encoding']
  collation node['gitlab']['database']['collation']
  action :create
end

mysql_database_user database_user do
  connection database_connection
  password database_password
  database_name database
  host database_host
  privileges [:select,:'lock tables',:insert,:update,:delete,:create,:drop,:index,:alter]
  action :grant
end