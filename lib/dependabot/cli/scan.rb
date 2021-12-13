# frozen_string_literal: true

module Dependabot
  module CLI
    class Scan
      attr_reader :path

      def initialize(path)
        @path = Pathname.new(path)
      end

      def run(options)
        puts [path, options].inspect
      end
    end
  end
end
