class ElementComponent < ActionView::Component::Base
  include Spark::Component

  element :simple_block
  element :block_with_attrs do
    attribute :foo

    def method_test
      "success"
    end
  end

  def initialize(*)
    super
  end
end
