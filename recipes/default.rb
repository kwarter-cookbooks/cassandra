include_recipe "cassandra::datastax"

[node[:cassandra][:data_root_dir], node[:cassandra][:commitlog_dir]].each do |dir|
  directory dir do
    owner node[:cassandra][:user]
    group node[:cassandra][:user]
  end
end

%w(cassandra.yaml cassandra-env.sh).each do |f|
  template File.join(node["cassandra"]["conf_dir"], f) do
    source "#{f}.erb"
    owner node["cassandra"]["user"]
    group node["cassandra"]["user"]
    mode 0644
    notifies :restart, "service[cassandra]"
  end
end

service "cassandra" do
  supports :restart => true, :status => true
  action [:enable, :start]
end
