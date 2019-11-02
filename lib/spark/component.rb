# frozen_string_literal: true

require_relative "element"

module Spark
  module Component
    def self.included(base)
      base.include Spark::Element unless base < Spark::Element

      # If an Integration is defeind include its modules if the component extends
      # the defined base class
      return unless defined?(Spark::Integration)

      base.include(Spark::Integration::Component) if base < Spark::Integration.base_class
    end
  end
end
