# frozen_string_literal: true

require_relative "component/element"

if defined?(ActionView::Component::Base)
  require_relative "component/integration/action_view_component"
end

module Spark
  module Component
    def self.included(base)
      base.include Spark::Component::Element unless base < Spark::Component::Element

      # If an Integration is defeind include its modules if the component extends
      # the defined base class
      return unless defined?(Spark::Component::Integration)

      base.include(Spark::Component::Integration) if base < Spark::Component::Integration.base_class
    end
  end
end
