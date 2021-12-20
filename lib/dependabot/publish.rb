# frozen_string_literal: true

module Dependabot
  class Publish
    attr_reader :dependency

    def initialize(dependency)
      @dependency = dependency
    end

    def update!(push: false)
      git_for(dependency, push: push) do |git|
        ::Spandx::Core::Plugin.enhance(dependency)
        Dependabot.logger.debug(git.patch) unless git.patch.empty?
      end
    end

    private

    def branch_name_for(dependency)
      "dependanot/#{dependency.package_manager}/#{dependency.name}"
    end

    def git_for(dependency, branch_name: branch_name_for(dependency), push: false)
      git = ::Dependabot::Git.new(dependency.path.parent)
      default_branch = git.repo.head.name
      git.checkout(branch: branch_name)
      yield git
      publish_pull_request_for(dependency, default_branch, branch_name, git, push) unless git.patch.empty?
    ensure
      git.repo.checkout_head(strategy: :force)
      git.repo.checkout(default_branch)
    end

    def description_for(dependency)
      <<~MARKDOWN
        Bumps [#{dependency.name}](#)

        <details>
        <summary>Changelog</summary>
        </details>

        <details>
        <summary>Commits</summary>
        </details>

        <br />

        Dependabot will resolve any conflicts with this PR as long as you don't alter it yourself. You can also trigger a rebase manually by commenting `@dependabot rebase`.
        ---

        <details>
        <summary>Dependabot commands and options</summary>
        <br />

        You can trigger Dependabot actions by commenting on this PR:
        - `@dependabot rebase` will rebase this PR
        - `@dependabot recreate` will recreate this PR, overwriting any edits that have been made to it
        - `@dependabot merge` will merge this PR after your CI passes on it
        - `@dependabot squash and merge` will squash and merge this PR after your CI passes on it
        - `@dependabot cancel merge` will cancel a previously requested merge and block automerging
        - `@dependabot reopen` will reopen this PR if it is closed
        - `@dependabot close` will close this PR and stop Dependabot recreating it. You can achieve the same result by closing it manually
        - `@dependabot ignore this major version` will close this PR and stop Dependabot creating any more for this major version (unless you reopen the PR or upgrade to it yourself)
        - `@dependabot ignore this minor version` will close this PR and stop Dependabot creating any more for this minor version (unless you reopen the PR or upgrade to it yourself)
        - `@dependabot ignore this dependency` will close this PR and stop Dependabot creating any more for this dependency (unless you reopen the PR or upgrade to it yourself)
        </details>
      MARKDOWN
    end

    def publish_pull_request_for(dependency, default_branch, branch_name, git, push)
      git.commit(all: true, message: "chore: Update #{dependency.name}")
      return unless push

      git.push(remote: "origin", branch: branch_name)
      Dependabot.octokit.create_pull_request(
        GitHub.name_with_owner_from(git.repo.remotes["origin"].url),
        default_branch,
        branch_name,
        "chore(deps): bump #{dependency}",
        description_for(dependency)
      )
    end
  end
end
