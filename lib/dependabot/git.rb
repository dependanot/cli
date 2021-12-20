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
      repo.index.read_tree(repo.head.target.tree)
      repo.index.add(
        path: path,
        oid: repo.write(File.binread(path), :blob),
        mode: File.stat(path).mode
      )
    end
  end
end
