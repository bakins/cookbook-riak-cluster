#!/bin/sh
if [ ! -x /usr/bin/git ]; then
    sudo apt-get install -y git
fi

if [ ! -x /opt/chef/embedded/bin/berks ]; then
    echo "Installing berkshelf"
    sudo /opt/chef/embedded/bin/gem install berkshelf --no-ri --no-rdoc
fi

echo "Berkshelf: Installing cookbooks"
sudo /opt/chef/embedded/bin/berks install --path=/tmp/vagrant-chef-1/chef-solo-1/cookbooks --berksfile=/vagrant/Berksfile

