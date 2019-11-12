class WithElements < ActionView::Component::Base
  include Spark::Component

  element :simple_block
  element :multi, multiple: true
  element :with_config do
    attribute :foo

    def method_test
      "success"
    end
  end

  element :with_validation do
    attribute :foo
    validates_attr :foo, presence: true
  end

  def initialize(*)
    super
  end
end
