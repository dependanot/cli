# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:all) do
    allowed = ["spdx.org", "rubygems.org"]
    WebMock.disable_net_connect!(
      allow: ->(uri) { allowed.include?(uri.host) }
    )
  end
end
