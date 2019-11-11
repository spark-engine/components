# frozen_string_literal: true

require "test_helper"

module Spark
  class ElementIntegrationTest < ActionDispatch::IntegrationTest

    def test_render_element
      get "/element/block"
      assert_response :success
      assert_equal %(<div class="block"><span>content</span></div>), get_html(response.body, css: "#test-1 .block")
    end

    def test_render_without_element
      get "/element/block"
      assert_response :success
      assert_equal %(<div></div>), get_html(response.body, css: "#test-2 div")
    end

    def test_render_without_element
      get "/element/block"
      assert_response :success
      assert_equal %(<div class="attr">bar</div>), get_html(response.body, css: "#test-3 .attr")
      assert_equal %(<div class="method">success</div>), get_html(response.body, css: "#test-3 .method")
    end
  end
end
