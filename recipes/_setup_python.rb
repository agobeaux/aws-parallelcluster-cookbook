# frozen_string_literal: true

#
# Cookbook Name:: aws-parallelcluster
# Recipe:: _setup_python
#
# Copyright 2013-2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.
install_pyenv node['cfncluster']['python-version'] do
  prefix node['cfncluster']['system_pyenv_root']
end

activate_virtual_env node['cfncluster']['cookbook_virtualenv'] do
  pyenv_path node['cfncluster']['cookbook_virtualenv_path']
  python_version node['cfncluster']['python-version']
  requirements_path "requirements.txt"
  not_if { ::File.exist?("#{node['cfncluster']['cookbook_virtualenv_path']}/bin/activate") }
end

activate_virtual_env node['cfncluster']['node_virtualenv'] do
  pyenv_path node['cfncluster']['node_virtualenv_path']
  python_version node['cfncluster']['python-version']
  not_if { ::File.exist?("#{node['cfncluster']['node_virtualenv_path']}/bin/activate") }
end

if node['platform'] == 'centos' && node['platform_version'].to_i < 7
  # CentOS 6 - install a newer version of Python using pyenv and make it globally available
  install_pyenv node['cfncluster']['python-version-centos6'] do
    prefix node['cfncluster']['system_pyenv_root_centos6']
  end

  template "/etc/profile.d/pyenv.sh" do
    source 'pyenv.sh.erb'
    owner 'root'
    group 'root'
    mode '0755'
  end

  pyenv_global node['cfncluster']['python-version-centos6']
end