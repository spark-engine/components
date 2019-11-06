# frozen_string_literal: true

require "test_helper"
require "spark/attribute"

module Spark
  class AttributeTest < Minitest::Test
    parallelize_me!

    def base_class
      Class.new do
        include Attribute

        def initialize(attributes = nil)
          initialize_attributes(attributes)
        end
      end.dup
    end

    def test_has_default_attributes
      klass = base_class

      assert_equal({ id: nil, class: nil, data: {}, aria: {}, html: {} }, klass::BASE_ATTRIBUTES)
    end

    def test_can_add_to_attributes
      klass = base_class
      klass.attribute :foo

      assert_equal({ foo: nil }, klass.attributes)
    end

    def test_can_attributes_with_defaults
      klass = base_class
      klass.attribute :foo, bar: :baz

      assert_equal({ foo: nil, bar: :baz }, klass.attributes)
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
      klass = base_class

      attrs = {
        id: "foo", class: "bar",
        data: { baz: true },
        aria: { boof: "test" },
        html: { role: "button" }
      }

      klass_instance = klass.new(**attrs)
      assert_equal(attrs, klass_instance.attributes)
    end
  end
end
