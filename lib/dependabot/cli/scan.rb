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
          update!(dependency)
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

      def update!(dependency)
        puts "Updating #{dependency.name}..."
        git = ::Dependabot::Git.new(dependency.path.parent)
        git.checkout(branch: branch_name_for(dependency))

        ::Spandx::Core::Plugin.enhance(dependency)

        puts git.patch
        git.commit(all: true, message: "Updating #{dependency.name}")

        git.repo.branches.delete(branch_name_for(dependency))
        git.repo.checkout_head(strategy: :force)
      end

      def branch_name_for(dependency)
        "dependanot/#{dependency.package_manager}/#{dependency.name}"
      end
    end
  end
end
