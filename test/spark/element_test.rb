# frozen_string_literal: true

require "test_helper"

module Spark
  class ElementIntegrationTest < ActionDispatch::IntegrationTest
    parallelize_me!

    def test_render_element
      get "/element/block"
      assert_response :success
      assert_equal trim_result(response.body), "<div>content</div>"
    end
  end
end
