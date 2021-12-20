# frozen_string_literal: true

module Dependabot
  module CLI
    class Scan
      attr_reader :path, :options

      def initialize(path, options)
        @path = ::Pathname.new(path)
        @options = options
      end

      def run
        each_dependency do |dependency|
          publish_update_for(dependency)
        end
      end

      private

      def each_file(&block)
        ::Spandx::Core::PathTraversal
          .new(path, recursive: options[:recursive])
          .each(&block)
      end

      def each_dependency(&block)
        each_file do |file|
          ::Spandx::Core::Parser.parse(file).each(&block)
        end
      end

      def publish_update_for(dependency)
        ::Dependabot.logger.debug("Updating #{dependency.name}…")
        ::Dependabot::Publish.new(dependency).update!(push: options[:push])
      end
    end
  end
end
