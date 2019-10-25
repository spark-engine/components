# frozen_string_literal: true

require_relative "element/methods"
require_relative "element/class_methods"

module Spark
  module Element
    class Error < StandardError; end

    def self.included(base)
      base.extend(ClassMethods)
    end

    private

    # Create instance variables for each element
    def initialize_elements
      self.class.elements.each do |name, options|
        if (plural_name = options[:multiple])

          # Setting an empty array allows us to enumerate
          # without needing to check for presence first.
          set_instance_variable(plural_name, [])
        else
          set_instance_variable(name, nil)
        end
      end
    end

    # Simplify accessing namespaced element instance variables
    def set_instance_variable(name, value)
      instance_variable_set(:"@element_#{name}", value)
    end

    # Simplify accessing namespaced element instance variables
    def get_instance_variable(name)
      instance_variable_get(:"@element_#{name}")
    end
  end
end

