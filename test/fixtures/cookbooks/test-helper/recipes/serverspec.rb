chef_gem 'activesupport' do
  compile_time false if respond_to?(:compile_time)
end

require 'pathname'
require 'active_support/core_ext/hash/deep_merge'

directory '/tmp/serverspec' do
  recursive true
end

file '/tmp/serverspec/node.json' do
  owner "root"
  mode "0400"
end

log "Dumping attributes to '/tmp/serverspec/node.json."

ruby_block "dump_node_attributes" do
  block do
    require 'json'

    attrs = { 'ipaddress' => node['ipaddress'] }

    attrs = attrs.deep_merge(node.default_attrs) unless node.default_attrs.empty?
    attrs = attrs.deep_merge(node.normal_attrs) unless node.normal_attrs.empty?
    attrs = attrs.deep_merge(node.override_attrs) unless node.override_attrs.empty?

    recipe_json = "{ \"run_list\": \[ "
    recipe_json << node.run_list.expand(node.chef_environment).recipes.map! { |k| "\"#{k}\"" }.join(",")
    recipe_json << " \] }"
    attrs = attrs.deep_merge(JSON.parse(recipe_json))

    File.open('/tmp/serverspec/node.json', 'w') { |file| file.write(JSON.pretty_generate(attrs)) }
  end
end
