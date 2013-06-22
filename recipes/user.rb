#
# Cookbook Name:: gitlab
# Recipe:: user
#
# Copyright (C) 2013 G. Arends
# 
# All rights reserved - Do Not Redistribute
#

# Add the gitlab user
user node['gitlab']['user'] do
  comment "Gitlab User"
  home node['gitlab']['home']
  shell "/bin/bash"
  supports :manage_home => true
end