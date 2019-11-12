class WithElements < ActionView::Component::Base
  include Spark::Component

  element :simple_block
  element :with_config do
    attribute :foo

    def method_test
      "success"
    end
  end

  def initialize(*)
    super
  end
end
