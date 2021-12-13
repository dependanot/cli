# frozen_string_literal: true

module Dependabot
  class BundleUpdatePlugin < Spandx::Core::Plugin
    def enhance(dependency)
      if dependency.package_manager == :rubygems
        Dir.chdir(dependency.path.parent) do
          Bundler.with_unbundled_env do
            puts "Updating... #{dependency.name}"
            system "bundle update #{dependency.name} --conservative --quiet --full-index"
            system "git diff --patch --no-color"
            system "git checkout ."
          end
        end
      end

      dependency
    end
  end

  module CLI
    class Scan
      attr_reader :path

      def initialize(path, options)
        @path = ::Pathname.new(path)
        @options = options
      end

      def run
        each_dependency do |dependency|
          ::Spandx::Core::Plugin.enhance(dependency)
        end
      end

      private

      def each_file
        ::Spandx::Core::PathTraversal
          .new(path, recursive: false)
          .each { |file| yield file }
      end

      def each_dependency
        each_file do |file|
          ::Spandx::Core::Parser.parse(file).each do |dependency|
            yield dependency
          end
        end
      end
    end
  end
end
