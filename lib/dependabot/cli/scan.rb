# frozen_string_literal: true

module Dependabot
  module CLI
    class Scan
      def initialize(path)
        @path = path
      end

      def run(options)
        puts [@path, options].inspect
      end
    end
  end
end
