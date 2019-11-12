# frozen_string_literal: true

require "test_helper"
require "spark/component/classname"

module Spark
  module Component
    class ClassnameTest < Minitest::Test
      parallelize_me!

      def test_classname_to_s
        classes = Classname.new
        classes.add :foo, :bar, :baz

        assert_equal("foo bar baz", classes.to_s)
      end

      def test_classnames_are_unique
        classes = Classname.new
        classes.add :foo, :bar, :baz, :bar
        classes.add :foo
        assert_equal "foo bar baz", classes.to_s

        classes.base = :bar
        assert_equal "bar foo baz", classes.to_s
      end

      def test_classnames_track_base_class_separately
        classes = Classname.new

        classes.add :foo, :bar
        assert_nil classes.base
        assert_equal "foo bar", classes.to_s

        classes.base = :baz
        assert_equal "baz", classes.base.to_s
        assert_equal "baz foo bar", classes.to_s

        classes.base = :blast
        assert_equal "blast", classes.base.to_s
        assert_equal "blast foo bar", classes.to_s
      end
    end
  end
end
