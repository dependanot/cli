# frozen_string_literal: true

module Dependabot
  class Publish
    include ::Straw::Memoizable

    attr_reader :dependency, :git, :head, :base

    def initialize(dependency, git: Dependabot::Git.for(dependency))
      @dependency = dependency
      @git = git
      @head = "dependanot/#{dependency.package_manager}/#{dependency.name}"
      @base = git.repo.head.name
    end

    def update!(push: false)
      transaction(push: push) do |after_commit|
        ::Spandx::Core::Plugin.enhance(dependency)
        after_commit.new do
          Dependabot.logger.debug(git.patch)
          Dependabot.github.create_pull_request_from(git.repo, base, head, title, description)
        end
      end
    end

    private

    def transaction(push:)
      git.checkout(branch: head)
      callback = yield Callback
      return if git.patch.empty? || !push

      git.commit(all: true, message: commit_message)
      git.push(remote: "origin", branch: head)
      callback.call
    ensure
      reset
    end

    def reset
      git.repo.checkout_head(strategy: :force)
      git.repo.checkout(base)
    end

    def title
      memoize(:title) do
        "chore(deps): bump #{dependency.name} from #{dependency.version}"
      end
    end

    def commit_message
      memoize(:commit_message) do
        <<~COMMIT
          #{title}

          #{description}
        COMMIT
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
