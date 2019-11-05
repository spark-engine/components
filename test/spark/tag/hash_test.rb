# frozen_string_literal: true

require "test_helper"
require "spark/tag/hash"

module Spark
  module Tag
    class HashTest < Minitest::Test
      parallelize_me!

      def test_html_attrbute_format_on_to_s
        hash = {}
        hash.add foo: :bar

        assert_equal %(foo="bar"), hash.to_s
      end

      def test_prefix_prepends_keys_on_to_s
        data = Hash.new(prefix: :data)
        data.add foo_bar: :baz

        assert_equal %(data-foo-bar="baz"), data.to_s

        aria = Hash.new(prefix: :aria)
        aria.add foo_bar: :baz

        assert_equal %(aria-foo-bar="baz"), aria.to_s
      end

      def test_dasherize_keys
        hash = {}

        hash.add(foo_bar: :baz)

        assert_equal "foo-bar", hash.keys.first
      end
    end
  end
end
