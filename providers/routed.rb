#
# Cookbook Name:: osrm
# Provider:: routed
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

action :create do
  # Set default variables, as overridden node attributes are not available in resource
  service_name = new_resource.service_name || node['osrm']['routed']['service_name']
  map_dir      = new_resource.map_dir      || node['osrm']['map_dir']
  user         = new_resource.user         || node['osrm']['routed']['user']
  daemon       = new_resource.daemon       || "#{node['osrm']['target']}/build/osrm-routed"
  threads      = new_resource.threads      || node['osrm']['threads']
  map_base     = new_resource.map_base     || [
    # Concatinate path, remove .osm.bpf/.osm.bz2 file extention
    map_dir,
    new_resource.region,
    new_resource.profile,
    ::File.basename(node['osrm']['map_data'][new_resource.region]['url']),
  ].join('/').split('.')[0..-3].join('.')

  service_name = service_name % "#{new_resource.region}-#{new_resource.profile}"
  map_file = "#{map_base}.osrm"

  # Deploy upstart script on older machines
  template "/etc/init/#{service_name}.conf" do
    mode      0o644
    source    'upstart.conf.erb'
    cookbook  'osrm'
    variables description: 'OSRM route daemon',
              user:        user,
              daemon:      "#{daemon} " \
                           "--ip #{new_resource.listen} " \
                           "--port #{new_resource.port} " \
                           "--threads #{threads} " \
                           "#{new_resource.shared_memory ? '--shared-memory true' : map_file}"

    only_if { node['platform_version'].to_f < 15.04 }
  end

  link "/etc/init.d/#{service_name}" do
    to '/lib/init/upstart-job'
    only_if { node['platform_version'].to_f < 15.04 }
  end

  # Deploy systemd service on recent machines
  template "/etc/systemd/system/#{service_name}.service" do
    mode      0o644
    source    'systemd.service.erb'
    cookbook  'osrm'
    variables description: 'OSRM route daemon',
              user:        user,
              daemon:      "#{daemon} " \
                           "--ip #{new_resource.listen} " \
                           "--port #{new_resource.port} " \
                           "--threads #{threads} " \
                           "#{new_resource.shared_memory ? '--shared-memory true' : map_file}"

    not_if { node['platform_version'].to_f < 15.04 }
  end

  service service_name do
    supports   restart: true, status: true
    subscribes :restart, "template[/etc/init/#{service_name}.conf]"

    action [:enable, :start]
  end
end

action :delete do
  # Set default variables, as overridden node attributes are not available in resource
  service_name = new_resource.service_name || node['osrm']['routed']['service_name']

  service_name = service_name % "#{new_resource.region}-#{new_resource.profile}"

  service(service_name) { action :stop }

  file("/etc/init/#{service_name}.conf") { action :delete }
  file("/etc/init.d/#{service_name}") { action :delete }
end
