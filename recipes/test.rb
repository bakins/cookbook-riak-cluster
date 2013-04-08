# simple test recipe for vagrant
include_recipe "riak-cluster::default"

riak_cluster node['riak-cluster']['cluster']['name'] do
  members node['riak-cluster']['cluster']['members']
  node_name node['riak-cluster']['cluster']['node_name']
end
