# frozen_string_literal: true

require "logger"

require_relative "dependabot/tracer"
require_relative "dependabot/version"

module Dependabot
  class Error < StandardError; end

  def self.logger
    @logger ||= Logger.new(&stdout)
  end

  def self.tracer
    @tracer ||= Tracer.new(logger)
  end
end
