require 'resque/status_server'
Resque::Plugins::Status::Hash.expire_in = (24 * 60 * 60) # 24hrs in seconds
