# frozen_string_literal: true

module Dependabot
  module Npm
    class Update < ::Spandx::Core::Plugin
      def match?(dependency)
        dependency.package_manager == :npm
      end

      def enhance(dependency)
        return dependency unless match?(dependency)

        Dir.chdir(dependency.path.parent) do
          system("rm -fr node_modules/#{dependency.name}")
          system("npm update #{dependency.name}")
        end
        dependency
      end
    end
  end
end
