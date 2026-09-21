ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "devise"
require "devise/test/integration_helpers"

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end

module ActiveSupport
  class TestCase
    # SQLite + スレッド並列だと接続エラーになる環境があるため、並列実行はしない
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
