# frozen_string_literal: true

require_relative "element"

module Spark
  module Component
    def self.included(base)
      base.include Spark::Element unless base < Spark::Element

      # If an ActionView Component, inject overrides for Integration::ActionViewComponent
      return unless defined?(Spark::Integration)

      base.include(Spark::Integration::Component) if base < Spark::Integration.base_class
    end
  end
end
