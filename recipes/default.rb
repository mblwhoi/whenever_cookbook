#
# Cookbook Name:: whenever
# Recipe:: default
#
# Author: Anthony Goddard (<agoddard@mbl.edu>), modified by adorsk-whoi.
# Copyright 2011, Woods Hole Marine Biological Laboratory.
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

# Install gem dependencies.
gem_package "i18n" do
  action :install
end

gem_package "whenever" do
  action :install
end

# Make sure directory exists for whenever config files.
directory "#{node['whenever']['configs_dir']}" do
  owner "root"
  group "root"
  mode 0755
  recursive true
  action :create
end

# Get list of existing old whenever job files.
# Note that we extract both the job name and the user name from the file name to
# use as the job key.
old_jobs = `find #{node['whenever']['configs_dir']} -type f`.map do |job_file|
  if File.basename(job_file) =~ /^__job:(.*)__user:(.*)$/
    [$1,$2]
  end
end

# Initialize hash of current job files (current per node's attributes).
current_jobs = {}

# Process each job attribute.
node["whenever"]["jobs"].each do |job_name, job|
  
  # Create or update whenever job.
  whenever_job "#{job_name}" do
    description job["description"]
    every job["every"]
    at job["at"]
    user job["user"]
    command job["command"]
  end

  # Get default user.
  # Note: this is a bit kludgy...is there a cleaner way to do this so that we don't have
  # the same code in a buncha places?
  user = job["user"] || node['whenever']['defaults']['user']

  # Save job info to hash of new job files.
  current_jobs[[job_name,user]] = true

end


# Remove old jobs which are not in current jobs.
old_jobs.each do |job_key|

  if ! current_jobs[job_key]

    job_name = job_key[0]
    user = job_key[1]
    whenever_job "#{job_name}" do
      user user
      action :delete
    end

  end

end
