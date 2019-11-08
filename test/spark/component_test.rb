# frozen_string_literal: true

require "test_helper"
require "action_view/component/test_helpers"

require "rails/test_help"
require "spark/component"

module Spark
  class ElementTest < Minitest::Test
    include ActionView::Component::TestHelpers

    def test_render_it
      result = render_inline(TestComponent)
      assert_equal "<div>test</div>", get_html(result)
    end
  end
end
