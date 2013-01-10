maintainer       "adorsk-whoi"
maintainer_email "adorsk@whoi.edu"
license          "All rights reserved"
description      "Cron Whenever.  Based on original version written by agoddard."
version          "0.1.1"

%w{ debian ubuntu }.each do |os|
  supports os
end

depends 'rvm'

