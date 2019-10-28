# frozen_string_literal: true

require_relative "element"
require_relative "attribute"
require_relative "tag/attrs"
require_relative "action_view/component"

module Spark
  module Component
    def self.included(base)
      base.include Spark::Attribute
      base.include Spark::Element

      return unless defined?(::ActionView::Component::Base)

      base.include(Spark::ActionView::Component) if base < ::ActionView::Component::Base
    end

    # Setup attributes and elements.
    def initialize(attributes = nil, &block)
      initialize_attributes(attributes)
      initialize_elements
      super
    end
  end
end
