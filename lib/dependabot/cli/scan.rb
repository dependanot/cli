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
        Dir.chdir(dependency.path.parent) do |path|
          puts "Updating #{dependency.name}..."
          branch_name = "dependanot/#{dependency.package_manager}/#{dependency.name}"

          repo = Rugged::Repository.discover(dependency.path.parent)
          branch = repo.create_branch(branch_name, repo.head.name)

          ::Spandx::Core::Plugin.enhance(dependency)

          repo.status do |file, status|
            puts "#{file} has status: #{status.inspect}"
          end
          puts repo.index.diff.patch
          puts

          repo.branches.delete(branch_name)
          repo.checkout_head(strategy: :force)
        end
      end
    end
  end
end
