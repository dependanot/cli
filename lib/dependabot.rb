# frozen_string_literal: true

require "github"
require "logger"
require "octokit"
require "rugged"
require "spandx"

require_relative "dependabot/bundler/update"
require_relative "dependabot/tracer"
require_relative "dependabot/version"

module Dependabot
  class Error < StandardError; end

  def self.logger
    @logger ||= Logger.new($stderr)
  end

  def self.tracer
    @tracer ||= Tracer.new(logger)
  end

  def self.octokit
    @octokit ||= Octokit::Client.new.tap do |client|
      client.access_token = github.token
      client.api_endpoint = github.api_url
      client.auto_paginate = true
      client.connection_options = { request: { open_timeout: 5, timeout: 5 } }
      client.web_endpoint = github.server_url
    end
  end

  def self.github
    @github ||= GitHub.new
  end
end
