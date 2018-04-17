require 'open3'
require 'pp'

def current_ip
  ip = `netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}'`.strip
  ip.size > 0 ? ip : 'host.docker.internal'
end