# frozen_string_literal: true

module Spark
  module Element
    module Methods
      def self.included(base)
        %i[_parent _block view_context].each do |name|
          base.define_method(:"#{name}=") { |val| instance_variable_set(:"@#{name}", val) }
          base.define_method(:"#{name}")  { instance_variable_get(:"@#{name}") }
        end
      end

      def render_self
        return @content if @content.present?

        @content = render_block(view_context, &_block)
      end

      # Override this method to adapt block rendering for different platforms
      def render_block(view, &block)
        view.capture(self, &block)
      end

      def yield
        render_self
      end

      def initialize(attributes = nil)
        initialize_attributes(attributes)
        initialize_elements
        super
      end
    end
  end
end
