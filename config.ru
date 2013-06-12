require 'action_controller/railtie'
require 'jasminerice'
require 'sprockets/railtie'
require 'jquery-rails'

class JasmineTest < Rails::Application
  routes.append do
    mount Jasminerice::Engine => '/jasmine'
  end

  config.cache_classes = true
  config.active_support.deprecation = :log
  config.assets.enabled = true
  config.assets.version = '1.0'
  config.secret_token = '9696be98e32a5f213730cb7ed6161c79'
  config.assets.paths << "#{ Rails.root }/tests"
  config.assets.paths << "#{ Rails.root }/source"
  config.assets.paths << "#{ Rails.root }/vendor"
end

JasmineTest.initialize!
run JasmineTest