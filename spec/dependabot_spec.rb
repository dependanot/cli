# frozen_string_literal: true

RSpec.describe Dependabot do
  specify { expect(Dependabot::VERSION).not_to be_nil }
end
