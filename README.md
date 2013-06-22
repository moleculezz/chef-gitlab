# gitlab cookbook

Installs and configures Gitlab v5.x

# Requirements
 - `database` cookbook
 - `nginx` cookbook

Has only been tested on Ubuntu 13.04

# Usage

Change the default attribute values `node["gitlab"]["email"]` and `node["gitlab"]["fqdn"]`.
Then run `recipe[gitlab]`.

# Attributes

# Recipes
## user
Sets up the system user for Gitlab.

## database
Installs and configures the database for Gitlab.

## default
The default recipe includes the `user` and `database` recipes and configures the rest of gitlab.

# Author

Author:: G. Arends (<gdarends@gmail.com>)

# Thanks

Also thanks to Eric G. Wolfe (atomic-penguin) and his [gitlab cookbook](https://github.com/atomic-penguin/cookbook-gitlab) for inspiration.
