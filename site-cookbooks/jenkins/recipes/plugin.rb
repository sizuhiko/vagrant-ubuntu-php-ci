#
# Cookbook Name:: jenkins
# Recipe:: default
#
# Copyright 2014, Ryutaro YOSHIBA
#
# This software is released under the MIT License.
# http://opensource.org/licenses/mit-license.php

remote_file "/var/lib/jenkins/jenkins-cli.jar" do
  source "http://localhost:8080/jnlpJars/jenkins-cli.jar"
  retries 30
  retry_delay 10
end

cmd = <<"EOS"
  sudo wget -O default.js http://updates.jenkins-ci.org/update-center.json && sed '1d;$d' default.js > default.json && curl -X POST -H "Accept: application/json" -d @default.json http://localhost:8080/updateCenter/byId/default/postBack
EOS
execute cmd do
  action :run
end

%w{checkstyle cloverphp dry htmlpublisher jdepend plot pmd violations xunit phing Locale}.each do |plugin_name|
  e = execute "sudo /usr/bin/java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 install-plugin ".concat(plugin_name) do
    action :run
  end
end

service "jenkins" do
  action :restart
end
