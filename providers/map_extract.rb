#
# Cookbook Name:: osrm
# Provider:: map_extract
#
# Copyright 2012, Chris Aumann
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

use_inline_resources

action :extract do
  # Set default variables, as overridden node attributes are not available in resource
  map_dir     = new_resource.map_dir     || node['osrm']['map_dir']
  profile_dir = new_resource.profile_dir || "#{node['osrm']['target']}/profiles"
  command     = new_resource.command     || "#{node['osrm']['target']}/build/osrm-extract"
  cwd         = new_resource.cwd         || "#{node['osrm']['target']}/build"
  threads     = new_resource.threads     || node['osrm']['threads']
  map         = new_resource.map         || [
    map_dir,
    new_resource.region,
    ::File.basename(node['osrm']['map_data'][new_resource.region]['url']),
  ].join('/')

  linked_map = [map_dir, new_resource.region, new_resource.profile, ::File.basename(map)].join('/')

  # Set preferences for stxxl
  file "#{cwd}/.stxxl" do
    mode    0o644
    owner   new_resource.user if new_resource.user
    content "disk=#{new_resource.stxxl_file},#{new_resource.stxxl_size},syscall\n"
    only_if { new_resource.stxxl_size }
  end

  directory ::File.dirname(linked_map) do
    mode  0o755
    owner new_resource.user if new_resource.user
  end

  # Symlink region map to profile
  link linked_map do
    to map
  end

  # Remove .osm.bpf/.osm.bz2
  map_stripped_path = linked_map.split('.')[0..-3].join('.')

  execute "osrm-#{new_resource.region}-#{new_resource.profile}-extract" do
    user    new_resource.user if new_resource.user
    cwd     cwd
    timeout new_resource.timeout
    command "#{command} #{linked_map} -t #{threads} -p #{profile_dir}/#{new_resource.profile}.lua"
    not_if  { ::File.exist?("#{map_stripped_path}.osrm.names") }
  end

  # Remove temporary file.
  # Using rm -f, as file provider is really slow when deleting big files
  execute "rm -f #{new_resource.stxxl_file}"
end
