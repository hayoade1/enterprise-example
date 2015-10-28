version = "v2"

employees = group "employees"

# Grant all top-level groups to the employees group
# Grant groups to admin groups
api.groups.each do |group|
  next if group.resource.annotations[:'ldap-sync/source'].nil?
  employees.add_member group
  if group.id =~ /(.*)-admin$/
    api.group($1).add_member group, admin_option: true
  end
end

api.group("#{version}/hr/admins").add_member api.group('hr')

api.group("#{version}/app-1/admins").add_member api.group('developers')

[
  host('hr1.myorg.com'),
  host('hr2.myorg.com'),
  host('hr3.myorg.com')
].each do |host|
  host.resource.annotations['host_type'] = 'SOX'
    
  api.layer("#{version}/hr").add_host host
end

[
  host('app-1-db.dev.myorg.com'),
  host('app-1-frontend.dev.myorg.com'),
  host('app-1-ws.dev.myorg.com')
].each do |host|
  api.layer("#{version}/app-1").add_host host
end

[
  host('modeling1.myorg.com'),
  host('modeling2.myorg.com'),
  host('modeling3.myorg.com'),
  host('modeling4.myorg.com'),
  host('scope.myorg.com')
].each do |host|
  api.layer("#{version}/research").add_host host
end

qa_hosts = (1..10).map { |i| host("qa#{i}.myorg.com") }

api.variable("#{version}/qa/ci_tool/report-api-key").permit %w(execute), api.group('developers')

%w(team-a team-b).each do |team|
  api.host("#{version}/jenkins/#{team}").role.grant_to layer("#{version}/jenkins")
end

resource "webservice", "authn-tv"

api.layer("#{version}/jenkins").add_host host("jenkins-master")
api.resource("webservice:authn-tv").permit "execute", api.layer("#{version}/jenkins")
