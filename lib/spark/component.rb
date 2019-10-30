# frozen_string_literal: true

require_relative "element"
require_relative "attribute"
require_relative "tag/attrs"

module Spark
  module Component
    def self.included(base)
      base.include Spark::Attribute unless base < Spark::Attribute
      base.include Spark::Element   unless base < Spark::Element
      base.extend(ClassMethods)     unless base < ClassMethods
      integrate(base)

      # If an ActionView Component, inject overrides for ActionView::Spark::Component
      return unless defined?(ActionView::Component::Base) && base < ActionView::Component::Base

      base.include(ActionView::Spark::Component)
    end

    # Platform integrations can override this to modify class when included
    def self.integrate(base); end

    # Setup attributes and elements.
    def initialize(attributes = nil, &block)
      initialize_attributes(attributes)
      initialize_elements
      super
    end

    def attributes
      @attributes ||= attr_hash(*self.class.attributes.keys)
    end
  end

  module ClassMethods
    def model_name
      klass = self.class
      klass = superclass if klass == Class
      klass = Spark::Component if klass == Class
      ActiveModel::Name.new(klass)
    end
  end
end
