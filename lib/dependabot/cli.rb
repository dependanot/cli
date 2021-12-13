# frozen_string_literal: true

require "thor"
require "spandx"
require "dependabot"
require "dependabot/cli/scan"

module Dependabot
  module CLI
    class Application < Thor
      desc "scan [DIRECTORY]", "Scan a directory"
      def scan(path = Pathname.pwd)
        ::Dependabot::CLI::Scan.new(path, options).run
      end

      desc "version", "Print the current version"
      def version
        $stdout.puts "v#{Dependabot::VERSION}"
      end
    end
  end
end
