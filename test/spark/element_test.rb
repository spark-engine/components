# frozen_string_literal: true

require "test_helper"

module Spark
  class ElementIntegrationTest < ActionDispatch::IntegrationTest

    def test_render_element
      get "/element/block"
      assert_response :success
      assert_equal trim_result(response.body), "<div><span>content</span></div>"
    end
  end
end
