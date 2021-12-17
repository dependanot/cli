# frozen_string_literal: true

module Dependabot
  module CLI
    class Scan
      attr_reader :path

      def initialize(path, options)
        @path = ::Pathname.new(path)
        @options = options
      end

      def run
        each_dependency do |dependency|
          Dir.chdir(dependency.path.parent) do
            puts "Updating... #{dependency.name}"
            ::Spandx::Core::Plugin.enhance(dependency)
            system "git diff --patch --no-color"
            system "git checkout ."
          end
        end
      end

      private

      def each_file(&block)
        ::Spandx::Core::PathTraversal
          .new(path, recursive: false)
          .each(&block)
      end

      def each_dependency(&block)
        each_file do |file|
          ::Spandx::Core::Parser.parse(file).each(&block)
        end
      end
    end
  end
end
