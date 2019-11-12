# frozen_string_literal: true

module Spark
  module Component
    module Integration
      def self.base_class
        ActionView::Component::Base
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      # Override ActionView::Components::Base `render_in`
      # This is only necessary in order to pass `self` as a block parameter
      def render_in(view_context, &block)
        self.class.compile
        @view_context = view_context
        @view_renderer ||= view_context.view_renderer
        @lookup_context ||= view_context.lookup_context
        @view_flow ||= view_context.view_flow
        @virtual_path ||= virtual_path

        # Pass self as a block parameter
        @content = render_block(view_context, &block) if block_given?
        validate!
        call
      end

      def render_self
        render_in(view_context, &_block)
      end

      # Override class methods for components
      module ClassMethods
        # Override source_location to allow a component to uses the superclass's template
        def inherit_template
          define_singleton_method(:source_location) { superclass.source_location }
        end

        # Use a template from a specific class
        def use_template(klass)
          define_singleton_method(:source_location) { klass.source_location }
        end
      end

      module Element
        def self.included(base)
          base.extend(ClassMethods)
        end

        # Override class methods when component is used as an element
        module ClassMethods
          # This is used to force components to define an initialize method
          # Overriding it means elements can defer to the original component's initialize method
          def ensure_initializer_defined; end

          # Allows elements to use component's original tempalte file.
          def source_location
            source_component.source_location
          end
        end
      end
    end
  end
end
