name             "gitlab"
maintainer       "G. Arends"
maintainer_email "gdarends@gmail.com"
license          "All rights reserved"
description      "Installs/Configures gitlab"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

depends "database"
depends "nginx"

supports "ubuntu"