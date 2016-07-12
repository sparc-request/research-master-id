class Study < ActiveRecord::Base
  octopus_establish_connection(Octopus.config[Rails.env][:eirb])
  allow_shard :eirb
end
