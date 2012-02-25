DUO_CONFIG = File.file?("#{Rails.root}/config/duo.yml") ? YAML.load_file("#{Rails.root}/config/duo.yml")[Rails.env] : Hash.new
