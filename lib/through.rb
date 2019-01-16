require "through/version"

module Through
  class Pipe
    def initialize(object, context = {})
      @object = object
      @context = context
    end

    def self.pipes_with
      @pipes_with ||= {}
    end

    def self.pipes_without
      @pipes_without ||= {}
    end

    def self.pipes
      @pipes ||= []
    end

    def self.pipe_with(name, options = {})
      pipes_with[name] = options.merge({
        scope: -> (query, arg, context) { yield(query, arg, context) }
      })
    end

    def self.pipe_without(name, options = {})
      pipes_without[name] = options.merge({
        scope: -> (query, arg, context) { yield(query, arg, context) }
      })
    end

    def self.pipe(options = {})
      pipes << options.merge({
        scope: -> (query, context) { yield(query, context) }
      })
    end

    def should_filter_pipe?(filter)
      if (filter.has_key?(:if))
        filter[:if].call(@context)
      else
        true
      end
    end

    def should_filter?(filter, params)
      if (filter.has_key?(:if))
        filter[:if].call(params, @context)
      else
        true
      end
    end

    def through_pipe
      self.class.pipes.each do |context_filter|
        if (self.should_filter_pipe?(context_filter))
          @object = context_filter[:scope].call(@object, @context)
        end
      end
    end

    def through_with(params)
      self.class.pipes_with.each do |without|
        key, value = without
        if (params.has_key?(key) && self.should_filter?(value, params[key]))
          @object = value[:scope].call(@object, params[key], @context)
        end
      end
    end

    def through_without(params)
      self.class.pipes_without.each do |without|
        key, value = without
        if (!params.has_key?(key) && self.should_filter?(value, params))
          @object = value[:scope].call(@object, params, @context)
        end
      end
    end

    def through(params = {})
      self.through_pipe
      self.through_without(params)
      self.through_with(params)
      @object
    end
  end
end
