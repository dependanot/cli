# frozen_string_literal: true

module Dependabot
  module CLI
    class Scan
      attr_reader :path

      def initialize(path)
        @path = Pathname.new(path)
      end

      def run(options)
        path.glob("Gemfile.lock").each do |pathname|
          puts pathname.inspect
        end
      end
    end
  end
end
