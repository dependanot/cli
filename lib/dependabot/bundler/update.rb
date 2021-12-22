# frozen_string_literal: true

module Dependabot
  module Bundler
    class Update < ::Spandx::Core::Plugin
      def enhance(dependency)
        return dependency unless dependency.package_manager == :rubygems

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
