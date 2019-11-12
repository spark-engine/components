class ElementComponent < ActionView::Component::Base
  include Spark::Component

  element :component_el, component: AttributeComponent
  element :component_config, component: AttributeComponent do
    attribute a: :config_default
  end
  element :component_config_validation, component: AttributeComponent do
    validates_attr :a, numericality: { only_integer: true }
  end
  element :multi, component: AttributeComponent, multiple: true

  def initialize(*)
    super
  end
end
