# frozen_string_literal: true

require "spark/component/tag_attr"

# Allows components to easily manage their attributes
#
#  # Example component usage:
#
#    class SomeClass
#      include Spark::Component::Attribute
#
#      # Set a :label attribute, and a :size attribute with default value :large
#      attribute :label, { size: :large }
#
#      def inialize(attributes = nil)
#        initialize_attributes(attributes)
#      end
#    end
#
#  # When initialized like:
#
#    some_instance = SomeClass.new(label: "Test")
#
#  The Class's instance will now have access to
#
#    @label => "Test"
#    @size  => :large
#
#  And will define access methods:
#
#    some_instance.attribute_label
#    some_instance.attribute_size
#
#  Attributes can also be accessed with a helper method
#
#    some_instance.attr(:label)
#    some_instance.attr(:size)
#
#  Extending a class will extend its attributes and their defaults.
#
#  This supports a common set of base attributes such as id, class, data, aria, and html.
#  The html attribute is meant to allow for passing along unaccounted for tag attributes.
#
module Spark
  module Component
    BASE_ATTRIBUTES = {
      id: nil,
      class: nil,
      data: {},
      aria: {},
      html: {}
    }.freeze

    module Attribute
      # All components and elements will support these attributes

      def self.included(base)
        base.extend(ClassMethods)
      end

      # Assign instance variables for attributes defined by the class
      def initialize_attributes(attrs = nil)
        attrs ||= {}

        self.class.attributes.each do |name, default|
          value = attrs[name] || (!default.nil? ? default : nil)
          if set?(value)
            instance_variable_set(:"@#{name}", value)
            attributes[name] = value
          end
        end
      end

      def attr(name)
        instance_variable_get(:"@#{name}")
      end

      def attributes
        @attributes ||= {}
      end

      # Accepts an array of instance variables and returns
      # a hash of variables with their values, if they are set.
      #
      # Example:
      #   @a = 1
      #   @b = nil
      #
      #   attr_hash(:a, :b, :c) => { a: 1 }
      #
      # Example use case:
      #
      # tag.div(data: attr_hash(:remote, :method)) { ... }
      #
      def attr_hash(*args)
        args.each_with_object({}) do |name, obj|
          val = instance_variable_get(:"@#{name}")
          obj[name] = val unless val.nil?
        end
      end

      # Initialize tag attributes from BASE_ATTRIBUTES
      #
      # If a component or element has arguments defined as base attributes
      # they will automatically be added to the tag_attrs
      def tag_attrs
        @tag_attrs ||= TagAttr.new.add attr_hash(*BASE_ATTRIBUTES.keys)
      end

      # Easy reference a tag's classname
      def classname
        tag_attrs.classname
      end

      # Easy reference a tag's data attributes
      def data
        tag_attrs.data
      end

      # Easy reference a tag's aria attributes
      def aria
        tag_attrs.aria
      end

      private

      # Help filter out attributes with blank values.
      # Not using `blank?` to avoid Rails requirement
      # and because `false` is a valid value.
      def set?(value)
        !(value.nil? || value.respond_to?(:empty?) && value.empty?)
      end

      module ClassMethods
        def attributes
          @attributes ||= Spark::Component::BASE_ATTRIBUTES.dup
        end

        # Sets attributes, accepts an array of keys, pass a hash to set default values
        #
        # Examples:
        #   - attribute(:foo, :bar, :baz)               => { foo: nil, bar: nil, baz: nil }
        #   - attribute(:foo, :bar, { baz: true })      => { foo: nil, bar: nil, baz: true }
        #   - attribute(foo: true, bar: true, baz: nil) => { foo: true, bar: true, baz: nil }
        #
        def attribute(*args)
          args.each do |arg|
            if arg.is_a?(::Hash)
              arg.each do |key, value|
                set_attribute(key.to_sym, default: value)
              end
            else
              set_attribute(arg.to_sym)
            end
          end
        end

        # A namespaced passthrough for validating attributes
        #
        # Option: `choices` - easily validate against an array
        #   Essentially a simplification of `inclusion` for attributes.
        #
        # Examples:
        #   - validates_attr(:size, choices: %i[small medium large])
        #   - validates_attr(:size, choices: SIZES, allow_blank: true)
        #
        def validates_attr(name, options = {})
          name = :"attribute_#{name}"

          if (choices = options.delete(:choices))
            supported_choices = choices.map { |c| c.is_a?(String) ? c.to_sym : c.to_s }.concat(choices)

            choices = choices.map(&:inspect).to_sentence(last_word_connector: ", or ")
            message = "\"%<value>s\" is not valid. Options include: #{choices}."

            options.merge!(inclusion: { in: supported_choices, message: message })
          end

          validates(name, options)
        end

        private

        # Store attributes and define methods for validation
        def set_attribute(name, default: nil)
          attributes[name] = default

          # Define a method to access attribute to support validation
          # Namespace attribute methods to prevent collision with methods or elements
          define_method(:"attribute_#{name}") do
            instance_variable_get(:"@#{name}")
          end
        end
      end
    end
  end
end
