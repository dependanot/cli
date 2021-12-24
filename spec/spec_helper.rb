# frozen_string_literal: true

require "bundler/setup"
require "dependabot/cli"
require "securerandom"
require "debug"
require "tmpdir"
require "webmock/rspec"

Dir["./spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  Kernel.srand config.seed
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.mock_with(:rspec) { |c| c.verify_partial_doubles = true }
  config.order = :random
  config.warnings = false
end
