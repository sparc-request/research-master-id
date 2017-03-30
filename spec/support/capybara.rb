require 'capybara/rails'
require 'capybara/rspec'

Capybara.javascript_driver = :webkit

Capybara::Webkit.configure do |config|
  config.allow_unknown_urls
end
