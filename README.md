# riak-cluster cookbook

# Requirements

Riak - this cookbook makes no assumption as to how riak is installed.
There are several cookbooks floating around that do that.  This merely
sets up clustering

# Usage

This provides an LWRP:

    riak_cluster "name" do
       members arry_of_riak_node_names
    end
    
Members should be an array like:
`[ "riak@33.33.33.10", "riak@33.33.33.20" ]`

It is assumed that riak is installed and running on the node.

# Recipes

default 

# Author

Author:: YOUR_NAME (<YOUR_EMAIL>)
