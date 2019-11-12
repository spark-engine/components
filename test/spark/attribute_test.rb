# frozen_string_literal: true

require "test_helper"
require "spark/component/attribute"

module Spark
  module Component
    class AttributeTest < Minitest::Test
      parallelize_me!

      def base_class
        Class.new do
          include ActiveModel::Validations
          include Attribute

          def initialize(attributes = nil)
            initialize_attributes(attributes)
          end

          # To ensure activemodel tests class
          def self.name
            "TestClass"
          end
        end.dup
      end

      def test_has_default_attributes
        assert_equal({ id: nil, class: nil, data: {}, aria: {}, html: {} }, base_class.attributes)
      end

      def test_can_add_to_attributes
        klass = base_class
        klass.attribute :foo

        assert_includes klass.attributes.keys, :foo
      end

      def test_can_attributes_with_defaults
        klass = base_class
        klass.attribute :foo, bar: :baz

        assert_includes klass.attributes.keys, :foo
        assert_equal :baz, klass.attributes[:bar]
      end

      def test_can_set_initialize_attributes
        klass = base_class
        klass.attribute :foo, bar: :baz

        klass_instance = klass.new(foo: "filled")
        assert_equal({ foo: "filled", bar: :baz }, klass_instance.attributes)
      end

      def test_ignores_undefined_attributes
        klass = base_class
        klass.attribute foo: :bar

        klass_instance = klass.new(test: true)
        assert_equal({ foo: :bar }, klass_instance.attributes)
      end

      def test_includes_base_attributes
        attrs = {
          id: "foo", class: "bar",
          data: { baz: true },
          aria: { label: "test" },
          html: { role: "button" }
        }

        klass_instance = base_class.new(**attrs)
        assert_equal(attrs, klass_instance.attributes)
      end

      # Ensure that attr_hash returns values for present attributes
      # and does not return keys with nil or empty values
      def test_attr_hash
        klass = base_class
        klass.attribute :a, b: true

        klass_instance = klass.new(a: 1)
        assert_equal({ a: 1, b: true }, klass_instance.attr_hash(:a, :b, :c, :id, :data))
      end

      def test_tag_attrs_assignable_by_attributes
        klass = base_class

        attrs = {
          aria: { label: "test" },
          data: { some_data: true },
          id: "foo", class: %w[bar baz],
          html: { role: "button" }
        }

        klass_instance = klass.new(**attrs)
        assert_equal({ "some-data" => true }, klass_instance.data)
        assert_equal({ label: "test" }, klass_instance.aria)
        assert_equal(%w[bar baz], klass_instance.classname)

        tag_attrs = {
          aria: { label: "test" },
          data: { "some-data" => true },
          class: %w[bar baz],
          id: "foo", role: "button"
        }

        assert_equal(tag_attrs, klass_instance.tag_attrs)
      end

      def test_validates_attrs_raises_exception
        klass = base_class
        klass.attribute :foo
        klass.validates_attr :foo, presence: true

        exception = assert_raises(ActiveModel::ValidationError) do
          klass_instance = klass.new
          klass_instance.validate!
        end
        assert_includes exception.message, "Attribute foo can't be blank"
      end

      def test_validates_attrs_passes
        klass = base_class
        klass.attribute :foo
        klass.validates_attr :foo, presence: true

        klass_instance = klass.new(foo: true)
        assert klass_instance.valid?
      end

      def test_validates_attrs_with_choices_option_raises_exception
        klass = base_class
        klass.attribute :size
        klass.validates_attr :size, choices: %w[small medium large]

        exception = assert_raises(ActiveModel::ValidationError) do
          klass_instance = klass.new(size: "xlarge")
          klass_instance.validate!
        end
        assert_includes exception.message, %(Attribute size "xlarge" is not valid.)
        assert_includes exception.message, %(Options include: "small", "medium", or "large")
      end

      def test_validates_attrs_with_choices_option_passes
        klass = base_class
        klass.attribute :size
        klass.validates_attr :size, choices: %w[small medium large]

        klass_instance = klass.new(size: "small")
        assert klass_instance.valid?

        # Equally validates symbols and strings
        klass_instance = klass.new(size: :small)
        assert klass_instance.valid?
      end
    end
  end
end
