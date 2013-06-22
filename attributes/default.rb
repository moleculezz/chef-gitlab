#
# Cookbook Name:: gitlab
# Attributes:: default
#
# Copyright 2013, G. Arends
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Set attributes for the git user
default['gitlab']['user'] = "git"
default['gitlab']['group'] = "git"
default['gitlab']['home'] = "/home/git"
default['gitlab']['app_home'] = "#{node['gitlab']['home']}/gitlab"

# Set github URL for gitlab
default['gitlab']['gitlab_url'] = "git://github.com/gitlabhq/gitlabhq.git"
default['gitlab']['gitlab_branch'] = "5-2-stable"

# Set github URL for gitlab shell
default['gitlab']['gitlab_shell_url'] = "https://github.com/gitlabhq/gitlab-shell.git"
default['gitlab']['gitlab_shell_version'] = "v1.5.0"



default['gitlab']['repos_path'] = "#{node['gitlab']['home']}/repositories"
default['gitlab']['ssh_path'] = "#{node['gitlab']['home']}/.ssh"
default['gitlab']['satellites_path'] = "#{node['gitlab']['home']}/gitlab-satellites"
default['gitlab']['hooks_path'] = "#{node['gitlab']['home']}/gitlab-shell/hooks"

# Database setup
default['gitlab']['database']['host'] = "localhost"
default['gitlab']['database']['database'] = "gitlab"
default['gitlab']['database']['username'] = "gitlab"

#default['gitlab']['database']['type'] = "mysql"
default['gitlab']['database']['adapter'] = "mysql2"
default['gitlab']['database']['encoding'] = "utf8"
default['gitlab']['database']['collation'] = "utf8_unicode_ci"
default['gitlab']['database']['pool'] = 5

default['gitlab']['email'] = "gitlab@localhost"
default['gitlab']['fqdn'] = "localhost"
