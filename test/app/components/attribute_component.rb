class AttributeComponent < ActionView::Component::Base
  include Spark::Component

  SIZES = %i[small medium large]
  THEMES = %i[primary secondary alternate]

  attribute :a, b: true
  attribute :theme, size: :medium

  validates_attr :a, presence: true
  validates_attr :theme, choices: THEMES, allow_nil: true
  validates_attr :size, choices: SIZES

  def initialize(*)
    super
  end
end
