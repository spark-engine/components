# frozen_string_literal: true

module SparkComponents
  module Attributes
    class Hash < Hash
      def prefix; end

      def add(*args)
        args.each do |arg|
          arg.is_a?(::Hash) ? self.merge!(arg) : self[arg.to_sym] = nil
        end
        self
      end

      # Output all attributes as [prefix-]name="value"
      def to_s
        each_with_object([]) do |(name, value), array|
          if value.is_a?(self.class)
            array << value.to_s
          else
            name = [prefix, name].compact.join("-").gsub(/[\W_]+/, '-')
            array << %(#{name}="#{value}") unless value.nil?
          end
        end.sort.join(" ")
      end

      # Easy assess to create a new Attributes::Hash
      def new(*args)
        new_obj = self.class.new
        new_obj.add(*args)
      end
    end

    class Data < Hash
      def prefix
        :data
      end
    end

    class Aria < Hash
      def prefix
        :aria
      end
    end

    class Classname < Array
      def initialize(*args, &block)
        super(*args, &block)
        @base_set = false
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

      # Returns clasess which are not defined as a base class
      def modifiers
        @base_set ? self[1..size] : self
      end

      def add(*args)
        push(*args.flatten.uniq.reject { |a| a.nil? || include?(a) })
        self
      end

      # Easy assess to create a new Attributes::Classname
      def new(*args)
        new_arr = self.class.new

        unless args.empty?
          new_arr.base = args.shift
          new_arr.add(*args)
        end

        new_arr
      end

      def to_s
        join(" ")
      end
    end

    class Tag
      attr_reader :attrs

      def initialize(obj={})
        @attrs = Hash.new
        merge!(obj)
      end

      def data
        attrs[:data] ||= Data.new
      end

      def aria
        attrs[:aria] ||= Aria.new
      end

      def classnames
        attrs[:class] ||= Classname.new
      end

      def root
        attrs[:root] ||= Hash.new
      end

      def new(obj={})
        self.class.new(obj)
      end

      # Ensure each attribute is distinct
      def dup
        new(attrs.each_with_object(Hash.new) do |(k, v), obj|
          obj[k] = v.dup
        end)
      end

      def merge!(obj={})
        merge_obj(self, obj)
      end

      def merge(obj={})
        merge_obj(dup, obj)
      end

      def merge_obj(tag, obj={})
        # If merging another Tag, extract attrs to merge
        obj = obj.attrs if obj.is_a?(Tag)

        obj.each do |key, val|
          if val.is_a?(Classname)
            # preserve object state
            tag.attrs[:class] = val;
          else
            case key.to_sym
            when :class; tag.classnames.add(val)
            when :data, :aria, :root; tag.send(key).add(val)
            else; tag.root[key] = val
            end
          end
        end
        tag
      end

      def to_s
        attrs.to_s
      end
    end
  end
end
