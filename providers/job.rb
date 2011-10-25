# Helper function to santize the 'every' parameter.
def _whenever_job_sanitize_every(every)
  if every.include? " "
    every.split.join('.') 
  else
    ":#{every}"
  end
end

# Helper function to get name of job file.
# Note: filename convention is '_job_job_name-_user_username'.  We use this convention
# in order to detect changes in job user attributes.
def _whenever_job_get_job_file_name(job_name,user)
  return "#{node['whenever']['configs_dir']}/__job:#{job_name}__user:#{user}"
end

# Build whenever job object and set node attributes.
action :create do

  # Initialize backup job object.
  job = {}

  # Set 'every', 'at', 'user', and 'command'
  job["description"] = new_resource.description
  job["every"] = new_resource.every
  job["at"] = new_resource.at
  job["user"] = new_resource.user
  job["command"] = new_resource.command

  # Add job to node's backup attributes, keyed by name.
  node.set['whenever']['jobs'][new_resource.name] = job

  # Get 'every' or use defaults.
  every = job['every'] || node['whenever']['defaults']['every']
  every = _whenever_job_sanitize_every(every)
  
  # Get 'at'.
  at = job['at'] || node['whenever']['defaults']['at']

  # Get 'user'.
  user = job['user'] || node['whenever']['defaults']['user']

  # Path to whenever schedule file that will be written or updated.
  job_file = _whenever_job_get_job_file_name(new_resource.name, user)

  # Update crontab from whenever job files, triggered by update of job file template below.
  execute "update whenever job '#{job_file}'" do
    command "echo `date --iso-8601=s` > /tmp/blork.txt; whenever -u #{user} -i -f '#{job_file}'"
    action :nothing
  end

  # Write job file and notify execution of whenever update command.
  template "#{job_file}" do
    cookbook "whenever"
    source "whenever_job.erb"
    group "root"
    owner "root"
    variables(:command => job['command'], :every => every, :at => at)
    mode 0644
    # NOTE: looks like LWRP are still using the old syntax for notifies (pre 0.9.8).
    # Annoying!
    notifies :run, resources(:execute => "update whenever job '#{job_file}'"), :immediately
  end

end


# Delete whenever job.
action :delete do

  # Get user.
  user = new_resource.user || node['whenever']['defaults']['user']

  # Get job file
  job_file = _whenever_job_get_job_file_name(new_resource.name, user)

  # Remove job file.
  execute "remove defunct whenever job '#{job_file}'" do
    command "whenever -u '#{user}' -c -f '#{job_file}'; rm -f '#{job_file}'"
  end    

  # Remove attribute.
  if ! node['whenever']['jobs'][new_resource.name].nil?
    node['whenever']['jobs'].delete(new_resource.name)
  end

end

