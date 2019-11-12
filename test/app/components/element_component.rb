class ElementComponent < ActionView::Component::Base
  include Spark::Component

  element :component_el, component: AttributeComponent
  element :with_elements, component: WithElements
  element :multi, component: AttributeComponent, multiple: true

  element :component_config, component: AttributeComponent do
    attribute a: :config_default

    def test_method
      :success
    end
  end

  element :component_config_validation, component: AttributeComponent do
    validates_attr :a, numericality: { only_integer: true }
  end

  def initialize(*)
    super
  end
end
