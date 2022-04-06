class EirbConnection < ActiveRecord::Base
  path = File.join(Rails.root, "config", "eirb_db.yml") # == config/eirb_db.yml
  EIRB_DB = 
    if File.exists?(path)
      yaml = Pathname.new(path)
      YAML.load(ERB.new(yaml.read).result)[Rails.env.to_s] # select which environment (test, dev etc)
    else
      nil
    end

  establish_connection(EIRB_DB)

end
