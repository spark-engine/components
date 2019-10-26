# frozen_string_literal: true

require "test_helper"

class TagAttrsTest < ActiveSupport::TestCase
  test "Hash attribute generates html attribute format on to_s" do
    attr = Spark::Tag::Hash.new
    attr.add foo: :bar

    assert_equal %(foo="bar"), attr.to_s
  end

  test "Data attribute hash generates html data- format on to_s" do
    attr = Spark::Tag::Hash.new(prefix: :data)
    attr.add foo_bar: :baz

    assert_equal %(data-foo-bar="baz"), attr.to_s
  end

  test "Aria attribute hash generates html aria- format on to_s" do
    attr = Spark::Tag::Hash.new(prefix: :aria)
    attr.add foo_bar: :baz

    assert_equal %(aria-foo-bar="baz"), attr.to_s
  end

  test "Classname attribute outputs space separated classnames on to_s" do
    attr = Spark::Tag::Classname.new
    attr.add :foo, :bar, :baz

    assert_equal "foo bar baz", attr.to_s
  end

  test "Classname are unique" do
    attr = Spark::Tag::Classname.new
    attr.add :foo, :bar, :baz, :bar
    attr.add :foo
    assert_equal "foo bar baz", attr.to_s

    attr.base = :bar
    assert_equal "bar foo baz", attr.to_s
  end

  test "Classname tracks base classes and modifiers separately" do
    attr = Spark::Tag::Classname.new

    attr.add :foo, :bar
    assert_nil attr.base
    assert_equal "foo bar", attr.to_s

    attr.base = :baz
    assert_equal "baz", attr.base.to_s
    assert_equal "baz foo bar", attr.to_s

    attr.base = :blast
    assert_equal "blast", attr.base.to_s
    assert_equal "blast foo bar", attr.to_s
  end

  test "Tag::Attrs manages aria, class, data, and root level attributes" do
    tag_attr = Spark::Tag::Attrs.new.add(foo: "bar")

    tag_attr.aria.add(foo: "bar")
    assert_equal %(aria-foo="bar"), tag_attr.aria.to_s
    assert_equal %(aria-foo="bar" foo="bar"), tag_attr.to_s

    tag_attr.data.add(foo: "bar")
    assert_equal %(data-foo="bar"), tag_attr.data.to_s
    assert_equal %(aria-foo="bar" data-foo="bar" foo="bar"), tag_attr.to_s

    tag_attr.classname.add("foo")
    tag_attr.classname.base = "base"
    assert_equal %(aria-foo="bar" class="base foo" data-foo="bar" foo="bar"), tag_attr.to_s
    assert_equal %(base-bar), tag_attr.classname.join_base("bar")
  end

  test "Tag::Attrs can handle adding aria, class, data, and root level attributes together" do
    args = { root: "val",
             data: nil,
             aria: { label: "test" },
             class: ["bar baz"],
             html: { test: "good", aria: { fun: true } } }

    tag_attr = Spark::Tag::Attrs.new.add(args)

    assert_equal({ label: "test", fun: true }, tag_attr.aria)
    assert_nil tag_attr[:data]
    assert_nil tag_attr.classname.base
    assert_equal "bar baz", tag_attr.classname.to_s

    assert_equal %(aria-fun="true" aria-label="test" class="bar baz" root="val" test="good"), tag_attr.to_s
  end
end
