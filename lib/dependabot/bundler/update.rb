# frozen_string_literal: true

module Dependabot
  module Bundler
    class Update < ::Spandx::Core::Plugin
      def enhance(dependency)
        return unless dependency.package_manager == :rubygems

        Dir.chdir(dependency.path.parent) do
          ::Bundler.with_unbundled_env do
            system "bundle update #{dependency.name} --conservative --verbose"
          end
        end
      end
    end
  end
end
