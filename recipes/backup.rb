#
# Cookbook Name:: backup
# Recipe:: default
#
# Copyright 2013, Brian Bianco <brian.bianco@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
template "#{node[:cassandra][:cassandra_backup][:backup_path]}/cassandra_backup.sh" do
  source "cassandra_backup.sh.erb"
  mode 0755
end

cron "cassandra_nightly_users_backup" do
	minute "0"
	hour "2"
  command "#{node[:cassandra][:cassandra_backup][:backup_path]}/cassandra_backup.sh users"
  action :create
end

cron "cassandra_nightly_events_backup" do
	minute "0"
	hour "2"
  command "#{node[:cassandra][:cassandra_backup][:backup_path]}/cassandra_backup.sh events"
  action :create
end
