# -*- mode: ruby -*-
# vi: set ft=ruby :

require "berkshelf/hobo"

NODES         = 2
BASE_IP       = "33.33.33."
IP_INCREMENT  = 10

Vagrant::Config.run do |cluster|
  (1..NODES).each do |index|
    ipaddress = BASE_IP + (index * IP_INCREMENT).to_s
    
    cluster.vm.define "riak#{index}".to_sym do |config|
      
      config.vm.box = "opscode-ubuntu-12.04"
      config.vm.box_url = "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_chef-11.2.0.box"
      
      config.ssh.max_tries = 40
      config.ssh.timeout   = 120
      config.vm.host_name = "riak#{index}"
      config.vm.network :hostonly, ipaddress

      config.vm.provision :chef_solo do |chef|
        chef.json = {
          'riak-cluster' => {
            'cluster' => {
              'name' => 'test',
              'members' => (1..NODES).map{|i| "riak@#{BASE_IP + (i * IP_INCREMENT).to_s}"},
              'node_name' => "riak@#{ipaddress}"
            }
          },
          'riak-turner' => {
            'erlang_node_name' => "riak@#{ipaddress}"
          },
          'turner' => {
            'artifacts_url' => 'http://artifacts.lax.vgtf.net'
          }
        }
        chef.run_list = [
                         "recipe[riak-turner]",
                         "recipe[riak-cluster::test]"
                        ]
      end
    end
  end
end
