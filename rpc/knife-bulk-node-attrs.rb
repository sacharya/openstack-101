#!ruby

=begin
This is a skeleton script that talks to a chef server and 
sets the give attrubutes on a given list of nodes. Esp handy
while setting some node attribute across all compute nodes withan 
an availability zone in a nova cluster.
=end

require 'rubygems'
require 'chef/knife'

AZ = ['compute1', 'compute2', 'compute3']

Chef::Config.from_file(File.expand_path("~/.chef/knife.rb"))
query = "chef_environment:openstack"
nodes, _, _ = Chef::Search::Query.new.search('node', query)

puts nodes

AZ.each do | x |
    nodes.each do | node |
    if node[:hostname] == x:
        puts "Processing #{x}"
        node["attribute_name0"] = "attribute_value0"
        node["attribute_name1"] = "attribute_value1"
        begin
            node.save
        rescue ==> e
            puts "Failed to modify node #{node['name']}: #{e.inspect}"
        end
    end
end

