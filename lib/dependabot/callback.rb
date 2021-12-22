# frozen_string_literal: true

module Dependabot
  class Callback
    def initialize(&block)
      @block = block
    end

    def call
      @block.call
    end
  end
end
