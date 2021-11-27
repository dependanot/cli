# frozen_string_literal: true

require "bundler/setup"
require "dependabot/cli"

require "securerandom"
require "tmpdir"

Dir["./spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  Kernel.srand config.seed

  config.disable_monkey_patching!
  config.example_status_persistence_file_path = ".rspec_status"
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.mock_with(:rspec) { |c| c.verify_partial_doubles = true }
  config.order = :random
  config.profile_examples = 10 unless config.files_to_run.one?
  config.warnings = false
end
