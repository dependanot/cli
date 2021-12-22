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
          update(dependency) if match?(dependency)
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

      def update(dependency)
        ::Dependabot.logger.info("Updating #{dependency.name}…")
        ::Dependabot::Publish.new(dependency).update!(push: options[:push])
      rescue StandardError => boom
        Dependabot.logger.error(boom)
        boom.backtrace.each { |x| Dependabot.logger.debug(x) }
      end

      def match?(dependency)
        options[:dependency].nil? || options[:dependency] == dependency.name
      end
    end
  end
end
