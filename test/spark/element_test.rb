# frozen_string_literal: true

require "test_helper"

module Spark
  class ElementIntegrationTest < ActionDispatch::IntegrationTest
    def test_render_without_element
      get "/element/empty"
      assert_response :success
      assert_equal %(<div></div>), get_html(response.body)
    end

    def test_render_element
      get "/element/block"
      assert_response :success
      assert_equal %(<div class="block"><span>content</span></div>), get_html(response.body, css: ".block")
    end

    def test_render_element_multiple
      get "/element/multi"
      assert_response :success
      html = get_html(response.body, css: "ul")
      assert_includes html, %(<li>1</li>)
      assert_includes html, %(<li>2</li>)
      assert_includes html, %(<li>3</li>)
    end

    def test_render_element_with_config
      get "/element/config"
      assert_response :success
      assert_equal %(<div class="attr">bar</div>), get_html(response.body, css: ".attr")
      assert_equal %(<div class="method">success</div>), get_html(response.body, css: ".method")
    end

    def test_render_element_with_validation_exception
      exception = assert_raises(ActionView::Template::Error) do
        get "/element/with_validation_exception"
      end
      assert_includes exception.message, "Validation failed: Attribute foo can't be blank"
    end

    def test_render_element_with_validation_passes
      get "/element/with_validation"
      assert_response :success
      assert_equal %(<div>works</div>), get_html(response.body)
    end

    def test_render_element_extending_component
      get "/element/component"
      assert_response :success
      assert_equal %(<div class="el">component-element</div>), get_html(response.body, css: ".el")
    end

    def test_render_element_config_extending_component
      get "/element/component_config"
      assert_response :success
      assert_equal %(<div class="config">config_default</div>), get_html(response.body, css: ".config")
      assert_equal %(<div class="method">success</div>), get_html(response.body, css: ".method")
    end

    def test_render_element_config_extending_component_validation_exception
      exception = assert_raises(ActionView::Template::Error) do
        get "/element/component_config_validation_exception"
      end
      assert_includes exception.message, "Validation failed: Attribute a is not a number"
    end

    def test_render_element_config_extending_component_validation_override
      get "/element/component_config_validation"
      assert_response :success
      assert_equal %(<div class="validated">3</div>), get_html(response.body)
    end

    def test_render_element_extending_component_multiple
      get "/element/component_multi"
      assert_response :success
      html = get_html(response.body, css: "ul")
      assert_includes html, %(<li><div>1</div></li>)
      assert_includes html, %(<li><div>2</div></li>)
      assert_includes html, %(<li><div>3</div></li>)
    end
  end
end
