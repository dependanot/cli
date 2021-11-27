# frozen_string_literal: true

module Dependabot
  class Tracer
    def initialize(logger)
      @logger = logger
    end

    def trace(defaults = {})
      tracer = TracePoint.new(:call) do |x|
        @logger.debug(defaults.merge({ path: x.path, lineno: x.lineno, clazz: x.defined_class, method: x.method_id, args: args_from(x), locals: locals_from(x) }))
      rescue => error
        @logger.error(defaults.merge({ message: error.message, stacktrace: error.backtrace }))
      end
      tracer.enable
      yield
    ensure
      tracer.disable
    end

    private

    def args_from(trace)
      trace.parameters.map(&:last).map { |x| [x, trace.binding.eval(x.to_s)] }.to_h
    end

    def locals_from(trace)
      trace.binding.local_variables.map { |x| [x, trace.binding.local_variable_get(x)] }.to_h
    end
  end
end
