#mostly copied from "stock" riak cookbook
require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut
include Timeout

def node_name
  new_resource.node_name || "riak@#{node['ipaddress']}"
end

def ringready
  cmd = shell_out("riak-admin ringready")
  {
    :ready => cmd.stdout =~ /TRUE/,
    :members => cmd.stdout.scan(/'([^',]+)'/).flatten,
    :running => cmd.stdout !~ /Node is not running/
  }
end

def wait_for_ring(tries=5)
  ready = false
  (1..tries).each do
    if ready = ringready[:ready]
      break
    else
      sleep 1
    end
  end
  return ready
end

def join(peer)
  cmd = shell_out("riak ping #{peer}")
  unless cmd.exitstatus == 0 
    Chef::Log.info "Riak: Failed to ping #{peer}: #{cmd.stdout}"
    return false
  end
  cmd = shell_out("riak-admin cluster join #{peer}")
  unless rc = cmd.exitstatus == 0 
    Chef::Log.info "Riak: Failed to join #{new_resource.cluster_name} on #{peer}: #{cmd.stdout}"
  else
    # riak will not commit until you show the change
    shell_out("riak-admin cluster plan")
    sleep(5)
    cmd = shell_out("riak-admin cluster commit")
    unless rc = cmd.exitstatus == 0 
      Chef::Log.info "Riak: Failed to commit #{new_resource.cluster_name}: #{cmd.stdout}"
    end
  end
  rc
end

def wait_for_riak
  shell_out!("riak-admin wait-for-service riak_kv #{node_name}", { :timeout => 30 })
end

def joined?
  ring_ready = ringready
  ring_ready[:members].size > 1
end

action :join do
  wait_for_riak
  ring_ready = ringready
  Chef::Application.fatal!("Can't join a Riak cluster if the local node is not running.") unless ring_ready[:running]
  peers = new_resource.members.uniq.reject{|member| member == node_name}.shuffle
  unless peers.any?
    Chef::Log.info "#{new_resource} no peers, doing nothing"
  else
    if joined?
      Chef::Log.info "#{new_resource} Already joined cluster"
    else
      peers.each do |peer|
        Chef::Log.info "Riak: Attempting to join #{new_resource.cluster_name} on #{peer}"
        if join(peer)
          if wait_for_ring
            new_resource.updated_by_last_action(true)
            break 
          end
        end
      end
      # check to make sure we joined
      unless joined?
        Chef::Application.fatal!("#{new_resource} failed to join cluster")
      end
    end
  end
end

