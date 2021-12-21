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
        "chore(deps): bump #{dependency.name} from #{dependency.version}",
        description_for(dependency)
      )
    end
  end
end
