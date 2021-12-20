# frozen_string_literal: true

require "thor"
require "dependabot"
require "dependabot/cli/scan"

module Dependabot
  module CLI
    class Application < Thor
      desc "scan [DIRECTORY | FILE]", "Scan a directory or file for dependencies to update"
      method_option :push, aliases: "-p", type: :boolean, desc: "Push the update as a pull request. Default: --no-push", default: false
      method_option :recursive, aliases: "-r", type: :boolean, desc: "Perform a recursive. Default: --no-recursive", default: false
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
