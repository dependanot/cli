# frozen_string_literal: true

module Dependabot
  class Publish
    attr_reader :dependency, :git, :pull_request

    def initialize(dependency, git: Dependabot::Git.for(dependency))
      @dependency = dependency
      @git = git
      @pull_request = PullRequest.new(
        nwo: GitHub.name_with_owner_from(git.repo.remotes["origin"].url),
        base: git.repo.head.name,
        head: "dependanot/#{dependency.package_manager}/#{dependency.name}",
        dependency: dependency
      )
    end

    def update!(push: false)
      transaction(push: push) do |after_commit|
        ::Spandx::Core::Plugin.enhance(dependency)
        after_commit.new do
          Dependabot.logger.debug(git.patch)
          Dependabot.github.create(pull_request)
        end
      end
    end

    private

    def transaction(push:)
      git.checkout(branch: pull_request.head)
      callback = yield Callback
      return if no_changes?

      git.commit(all: true, message: pull_request.commit_message)
      return unless push

      git.push(remote: "origin", branch: pull_request.head)
      callback.call
    ensure
      reset
    end

    def reset
      git.repo.checkout_head(strategy: :force)
      git.repo.checkout(pull_request.base)
    end

    def no_changes?
      git.patch.empty?
    end
  end
end
