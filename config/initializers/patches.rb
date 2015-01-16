Dir[Rails.root.join('lib', "*_patch.rb").to_s].each { |x| require x }
