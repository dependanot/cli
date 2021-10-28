# frozen_string_literal: true

require_relative "dependabot/version"

module Dependabot
  class Error < StandardError; end

  class CLI
    def to_s
      "Dependabot"
    end
  end
end
