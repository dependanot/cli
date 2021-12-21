# frozen_string_literal: true

module Dependabot
  class Git
    attr_reader :repo

    def initialize(path)
      @path = path
      @repo = Rugged::Repository.discover(path)
    end

    def checkout(branch:)
      repo.create_branch(branch, repo.head.name)
      repo.checkout(branch)
    end

    def push(remote: "origin", branch: "HEAD")
      repo.push(remote, ["refs/heads/#{branch}"], credentials: credentials_for(remote))
    end

    def patch
      repo.index.diff.patch
    end

    def commit(message:, all: false)
      repo.status { |path, status| stage(path) if status.include?(:worktree_modified) } if all

      Rugged::Commit.create(repo, {
        message: message,
        parents: repo.empty? ? [] : [repo.head.target].compact,
        tree: repo.index.write_tree(repo),
        update_ref: "HEAD",
        author: { email: "dependabot[bot]@users.noreply.github.com", name: "dependabot[bot]" },
        committer: { email: "dependabot[bot]@users.noreply.github.com", name: "dependabot[bot]" },
      })
    end

    private

    def stage(path)
      repo.index.add(path)
    end

    def credentials_for(remote)
      Dependabot.logger.debug(repo.remotes[remote].url)
      if ssh?(repo.remotes[remote].url)
        Rugged::Credentials::SshKeyFromAgent.new(username: "git")
      else
        Rugged::Credentials::UserPassword.new(username: "x-access-token", password: Dependabot.github.token)
      end
    end

    def ssh?(url)
      url.include?("git@github.com:")
    end
  end
end
