# frozen_string_literal: true

module Dependabot
  module Bundler
    class Update < ::Spandx::Core::Plugin
      def match?(dependency)
        dependency.package_manager == :rubygems
      end

      def enhance(dependency)
        return dependency unless match?(dependency)

        Dir.chdir(dependency.path.parent) do
          ::Bundler.with_unbundled_env do
            system({ "RUBYOPT" => "-W0" }, "bundle update #{dependency.name} --conservative --quiet")
          end
        end
        dependency
      end
    end
  end
end
