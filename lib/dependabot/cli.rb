# frozen_string_literal: true

require "thor"
require "dependabot"

module Dependabot
  class CLI < Thor
    desc "scan [DIRECTORY]", "Scan a directory"
    def scan(path = Dir.pwd)
      Pathname(path).glob("Gemfile.lock").each do |pathname|
        puts pathname.inspect
      end
    end

    desc "version", "Print the current version"
    def version
      $stdout.puts "v#{Dependabot::VERSION}"
    end
  end
end
