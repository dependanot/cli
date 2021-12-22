# frozen_string_literal: true

module Dependabot
  class PullRequest
    include ::Straw::Memoizable

    attr_reader :base, :head

    def initialize(nwo:, base:, head:, dependency:)
      @nwo = nwo
      @base = base
      @head = head
      @dependency = dependency
    end

    def commit_message
      memoize(:commit_message) do
        <<~COMMIT
          #{title}

          #{description}
        COMMIT
      end
    end

    def run_against(api)
      api.create_pull_request(nwo, base, head, title, description)
    end

    private

    attr_reader :nwo, :dependency

    def title
      memoize(:title) do
        "chore(deps): bump #{dependency.name} from #{dependency.version}"
      end
    end

    def description
      memoize(:description) do
        ERB
          .new(File.read(File.join(__dir__, "templates/pull.md.erb")))
          .result(binding)
      end
    end
  end
end
