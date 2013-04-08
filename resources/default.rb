#based on basho's version

actions :join
default_action :join

attribute :cluster_name, :kind_of => String, :name_attribute => true
attribute :members, :kind_of => Array, :required => true
attribute :node_name, :kind_of => String
