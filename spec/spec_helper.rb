$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH << File.expand_path("../support", __FILE__)

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__)
require "bundler"
Bundler.setup

ENV["RAILS_ENV"] = "test"

# Ensure the Active Admin load path is happy
require "rails"
ENV["RAILS"] = Rails.version
ENV["RAILS_ROOT"] = File.expand_path("../rails/rails-#{ENV['RAILS']}", __FILE__)

# Create the test app if it doesn't exists
system "rake setup" unless File.exist?(ENV["RAILS_ROOT"])

# require ActiveRecord to ensure that Ransack loads correctly
require "active_record"
require "action_view/railtie"
require "active_admin"
ActiveAdmin.application.load_paths = [ENV["RAILS_ROOT"] + "/app/admin"]

# load test app
require ENV["RAILS_ROOT"] + "/config/environment.rb"

# Disabling authentication in specs so that we don't have to worry about
# it allover the place
ActiveAdmin.application.authentication_method = false
ActiveAdmin.application.current_user_method = false

require "rspec/rails"
require "capybara/rails"
require "capybara/rspec"
require "capybara/poltergeist"

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: true,
                                         timeout: 80,
                                         debug: true,
                                         phantomjs_options: ["--debug=no", "--load-images=no"])
end

Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = [:should, :expect]
  end

  config.order = :random

  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
