# frozen_string_literal: true

require "test_helper"
require "spark/component"

module Spark
  class ComponentTest < Minitest::Test
    include ActionView::Component::TestHelpers

    def test_attribute_attribute_nil
      component = AttributeComponent.new
      assert_nil component.attribute_a
    end

    def test_attribute_default_set
      component = AttributeComponent.new
      assert component.attribute_b
    end

    def test_attribute_default_overridden
      component = AttributeComponent.new(b: :foo)
      assert_equal :foo, component.attribute_b
    end

    def test_attribute_validation_fails
      component = AttributeComponent.new
      exception = assert_raises(ActiveModel::ValidationError) do
        component.validate!
      end

      assert_includes exception.message, %(Validation failed: Attribute a can't be blank)
    end

    def test_attribute_validation_choice_fails
      component = AttributeComponent.new(a: true, size: :xlarge)
      exception = assert_raises(ActiveModel::ValidationError) do
        component.validate!
      end

      assert_includes exception.message, %(Attribute size "xlarge" is not valid.)
      assert_includes exception.message, %(Options include: :small, :medium, or :large)
    end

    def test_attribute_validation_passes
      component = AttributeComponent.new(a: true, size: :medium, theme: :primary)
      assert component.valid?
    end

    def test_attribute_access_in_template
      result = render_inline(AttributeComponent, a: "present")
      assert_equal "<div>present</div>", get_html(result)
    end

    def test_attribute_tags_in_template
      attrs = {
        id: "foo", class: "bar",
        data: { foo: "bar" },
        aria: { label: "test" },
        html: { role: "button" }
      }
      result = render_inline(AttributeComponent, a: "present", **attrs)
      expected = %(<div aria-label="test" class="bar" data-foo="bar" id="foo" role="button">present</div>)
      assert_equal expected, get_html(result)
    end

    def test_extends_other_component
      component = AttributeComponentExtended.new
      assert !component.valid?

      component = AttributeComponentExtended.new(a: true, size: :medium, theme: :primary)
      assert component.valid?

      result = render_inline(AttributeComponentExtended, a: "present")
      assert_equal "<div>present</div>", get_html(result)
    end
  end
end
