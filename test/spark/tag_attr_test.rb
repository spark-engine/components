# frozen_string_literal: true

require "test_helper"
require "spark/component/tag_attr"

module Spark
  module Component
    class TagAttrTest < Minitest::Test
      parallelize_me!

      def test_handles_aria_attributes
        tag_attr = TagAttr.new

        tag_attr.aria.add(foo: "bar")
        assert_equal %(aria-foo="bar"), tag_attr.aria.to_s
        assert_equal %(aria-foo="bar"), tag_attr.to_s
      end

      def test_handles_class_attributes
        tag_attr = TagAttr.new

        tag_attr.classname.add("foo")
        tag_attr.classname.base = "base"
        assert_equal %(class="base foo"), tag_attr.to_s
        assert_equal %(base-bar), tag_attr.classname.join_base("bar")
      end

      def test_handles_data_attributes
        tag_attr = TagAttr.new

        tag_attr.data.add(foo: "bar")
        assert_equal %(data-foo="bar"), tag_attr.data.to_s
        assert_equal "bar", tag_attr.data[:foo]
        assert_equal %(data-foo="bar"), tag_attr.to_s
      end

      def test_adding_an_empty_attribute_is_a_noop
        tag_attr = TagAttr.new
        tag_attr.add(data: {})
        tag_attr.add(aria: {})
        tag_attr.add(html: {})

        assert_equal({}, tag_attr)
      end

      def test_merges_html_attributes_with_data_and_aria
        tag_attr = TagAttr.new

        data = { a: 1, b: 2 }
        aria = { c: 1, d: 2 }
        html = {
          data: { a: "from-html" },
          aria: { c: "from-html" }
        }

        tag_attr.add(data: data, aria: aria, html: html)

        assert_equal({ a: "from-html", b: 2 }, tag_attr.data)
        assert_equal({ c: "from-html", d: 2 }, tag_attr.aria)
      end

      def test_converts_properly_to_s
        tag_attr = TagAttr.new

        aria = { a: 1 }
        data = { b: 2 }
        html = { id: "some_id", class: "there" }

        tag_attr.add(data: data, aria: aria, class: "hi", html: html)

        assert_equal %(aria-a="1" class="hi there" data-b="2" id="some_id"), tag_attr.to_s
      end
    end
  end
end
