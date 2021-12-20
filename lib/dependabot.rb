# frozen_string_literal: true

require "bundler"
require "github"
require "logger"
require "octokit"
require "rugged"
require "spandx"

require_relative "dependabot/bundler/update"
require_relative "dependabot/git"
require_relative "dependabot/publish"
require_relative "dependabot/tracer"
require_relative "dependabot/version"

module Dependabot
  class Error < StandardError; end

  def self.logger
    @logger ||= Logger.new($stderr, level: ENV.fetch("LOG_LEVEL", Logger::WARN)).tap do |x|
      x.formatter = proc do |_severity, _datetime, _progname, message|
        "[v#{VERSION}] #{message}\n"
      end
    end
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
