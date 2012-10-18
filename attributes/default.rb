#
# Cookbook Name:: whenever
# Attributes:: whenever
#

default[:whenever][:configs_dir] = "/etc/whenever/jobs"

default[:whenever][:jobs] = {}

default[:whenever][:defaults][:at] = "4:30am"
default[:whenever][:defaults][:every] = "1 day"
default[:whenever][:defaults][:user] = "root"
default[:whenever][:defaults][:command] = ""

