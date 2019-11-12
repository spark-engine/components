# frozen_string_literal: true

module Spark
  module Component
    class Classname < Array
      def initialize(*args, base: nil, &block)
        super(args, &block)
        self.base = base unless base.nil?
        @base_set = !base.nil?
      end

      # Many elements have a base class which defines core utlitiy
      # This classname may serve as a root for other element classnames
      # and should be distincly accessible
      #
      # For example:
      #   classes = Classname.new
      #   classes.base = 'nav__item'
      #   now generate a wrapper: "#{classes.base}__wrapper"
      #
      # Ensure base class is the first element in the classes array.
      #
      def base=(klass)
        return if klass.nil? || klass.empty?

        if @base_set
          self[0] = klass
        else
          unshift klass
          @base_set = true
        end

        uniq!
      end

      def base
        first if @base_set
      end

      def add(*args)
        push(*args.flatten.uniq.reject { |a| a.nil? || include?(a) })
        self
      end

      def join_base(name, separator = "-")
        raise(StandardError, "Base class not defined for `join_base(#{name}, …)`") if base.nil?

        [base, name].join(separator)
      end

      def to_s
        join(" ")
      end
    end
  end
end
