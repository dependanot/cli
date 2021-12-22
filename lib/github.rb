# frozen_string_literal: true

# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
class GitHub
  attr_reader :api_url, :repository, :server_url, :token, :workspace

  def initialize(
    api_url: default_api_url,
    repository: ENV["GITHUB_REPOSITORY"],
    server_url: ENV.fetch("GITHUB_SERVER_URL", "https://github.com"),
    token: default_token,
    workspace: ENV.fetch("GITHUB_WORKSPACE", Dir.pwd)
  )
    @api_url = api_url
    @repository = repository
    @server_url = server_url
    @token = token
    @workspace = workspace
  end

  def create_pull_request_from(repo, base, head, title, description)
    Dependabot.octokit.create_pull_request(
      GitHub.name_with_owner_from(repo.remotes["origin"].url),
      base,
      head,
      title,
      description
    )
  end

  class << self
    def name_with_owner_from(url)
      regex = %r{(?<x>(?<scheme>https|ssh)://)?(?<username>git@)?github.com[:|/](?<nwo>\w+/\w+)(?<extension>\.git)?}
      match = url.match(regex)
      match && match["nwo"]
    end
  end

  private

  def default_api_url
    ENV.fetch("GITHUB_API_URL", "https://api.github.com")
  end

  def default_token
    ENV.fetch("GITHUB_TOKEN") do |_name|
      file = Pathname.new(Dir.home).join(".config/gh/hosts.yml")
      if file.exist?
        YAML
          .safe_load(file.read)
          &.fetch("github.com")
          &.fetch("oauth_token")
      end
    end
  end
end
