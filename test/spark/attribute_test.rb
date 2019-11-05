# frozen_string_literal: true

require "test_helper"
require "spark/attribute"

module Spark
  class AttributeTest < Minitest::Test
    parallelize_me!

    def base_class
      Class.new.include Attribute
    end

    def test_has_default_attributes
      assert_equal({ id: nil, class: nil, data: {}, aria: {}, html: {} }, base_class::BASE_ATTRIBUTES)
    end
  end
end
