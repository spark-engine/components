# frozen_string_literal: true

module Spark
  module Element
    module Methods
      def self.included(base)
        %i[_parent _component view_context].each do |name|
          base.define_method(:"#{name}=") { |val| instance_variable_set(:"@#{name}", val) }
          base.define_method(:"#{name}")  { instance_variable_get(:"@#{name}") }
        end
      end

      def render_self
        return @content if @content.present? || !@_block

        @content = view_context.capture(self, &@_block)
      end

      def yield
        render_self
      end

      def initialize(attributes = nil, &block)
        @_block = block
        initialize_attributes(attributes)
        initialize_elements
        super
      end
    end
  end
end

