# frozen_string_literal: true

require "test_helper"
require "spark/attribute"

module Spark
  class AttributeTest < Minitest::Test
    parallelize_me!

    def test_has_default_attributes
      klass = Class.new do
        include Attribute
      end

      assert_equal({ id: nil, class: nil, data: {}, aria: {}, html: {}}, klass::BASE_ATTRIBUTES)
    end

    def test_can_add_to_attributes
      klass = Class.new do
        include Attribute
        attribute :foo
      end

      assert_equal({ foo: nil }, klass.attributes)
    end
    
    def test_can_attributes_with_defaults
      klass = Class.new do
        include Attribute
        attribute :foo, bar: :baz
      end

      assert_equal({ foo: nil, bar: :baz }, klass.attributes)
    end
  end
end
