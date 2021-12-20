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
        git_for(dependency) do |git|
          ::Spandx::Core::Plugin.enhance(dependency)
          puts git.patch
          git.commit(all: true, message: "Updating #{dependency.name}")
        end
      end

      def branch_name_for(dependency)
        "dependanot/#{dependency.package_manager}/#{dependency.name}"
      end

      def git_for(dependency, branch_name: branch_name_for(dependency))
        git = ::Dependabot::Git.new(dependency.path.parent)
        default_branch = git.repo.head.name
        git.checkout(branch: branch_name)
        yield git
      ensure
        git.repo.checkout_head(strategy: :force)
        git.repo.checkout(default_branch)
      end
    end
  end
end
