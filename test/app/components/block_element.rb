class BlockElement < ActionView::Component::Base
  include Spark::Component

  element :foo

  def initialize(*)
    super
  end
end
