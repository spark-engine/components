# frozen_string_literal: true

require_relative "element"
require_relative "attribute"
require_relative "tag/attrs"

module Spark
  module Component
    def self.included(base)
      base.include Spark::Attribute
      base.include Spark::Element
      integrate(base)
    end

    # Platform integrations can override this to modify class when included
    def self.integrate(base); end

    # Setup attributes and elements.
    def initialize(attributes = nil, &block)
      initialize_attributes(attributes)
      initialize_elements
      super
    end
  end
end
