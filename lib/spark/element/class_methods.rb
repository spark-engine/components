# frozen_string_literal: true

module Spark
  module Element
    module ClassMethods
      def elements
        @elements ||= {}
      end

      # Class method for adding elements
      #
      # Options:
      #
      #   name: Symbol
      #
      #     Create a method for interacting with an elemnt
      #     This name cannot be the same as another instance method
      #
      #   multiple: Boolean (default: false)
      #
      #     Defining `multiple: true` causes elements to be injected
      #     into an array. A pluralized method is created to access
      #     each element instance.
      #
      #     For example, `element(:item, multiple: true)` will create
      #     an `:items` method and each time an item is executed, its
      #     instance will be added to items.
      #
      #   component: Class
      #
      #     By default all elements extend Element::Base. Passing a
      #     class like `component: Nav::Item` will extend that component
      #     adding Element, Attributes, TagAttributes and render methods.
      #
      #   &config: Block
      #
      #     When defining a method, you may pass an optional block to
      #     configure attributes, nested elements, or even define methods.
      #
      def element(name, multiple: false, component: nil, &config)
        plural_name = name.to_s.pluralize.to_sym if multiple

        element_class = extend_class(component, &config)
        element_class.define_singleton_method(:component?) { component.present? }

        elements[name] = { multiple: plural_name }

        define_element_method(name: name, plural: plural_name, multiple: multiple, klass: element_class)
      end

      # Element method will create a new element instance, or if no
      # attributes or block is passed it will return the instance
      # defined for that element.
      #
      # For example when rendering a component, passing attributes or a
      # block will create a new instance of that element.
      #
      #   # Some view (Slim)
      #   = render(Nav) do |nav|
      #     - nav.item(href: "#url") { "link text" }
      #
      # Then when referencing the element in the component's template it
      # the method will return the instance. Call yield to output an
      # elemnet's block
      #
      #   # Nav template (Slim)
      #   nav
      #     - items.each do |item|
      #       a href=item.href
      #         = item.yield
      #
      def define_element_method(name:, plural:, multiple:, klass:)
        define_method_if_able(name) do |attributes = nil, &block|
          return get_instance_variable(multiple ? plural : name) unless attributes || block

          element = klass.new(attributes)
          element._parent = self
          element._block = block if block
          element.view_context = view_context
          element.render_self
          element.validate!

          # If element supports multiple instances, inject instance
          # into array for later enumeration
          if multiple
            get_instance_variable(plural) << element
          else
            set_instance_variable(name, element)
          end
        end

        return if !multiple || name == plural

        # If suitable define a pluralized method name to access
        # enumerable element instances.
        #
        define_method_if_able(plural) do
          get_instance_variable(plural)
        end
      end

      private

      # If an element extends a component, extend that component's class and include the necessary modules
      def extend_class(component, &config)
        base = base_class(component, &config)
        base.include(Spark::Element::Methods) unless base < Spark::Element::Methods
        base.include(Spark::Component)        unless base < Spark::Component

        if component && defined?(ActionView::Component::Base)
          base.include(Integration::ActionViewComponent::ElementMethods)
          base.extend(Integration::ActionViewComponent::OverrideClassMethods)
        end

        base
      end

      def base_class(component, &config)
        if component
          base = Class.new(component, &config)
          base.define_singleton_method(:source_component) { component }
          base
        elsif defined?(ActionView::Component::Base)
          Class.new(ActionView::Component::Base, &config)
        else
          Class.new(&config)
        end
      end

      # Prevent an element method from overwriting an existing method
      def define_method_if_able(method_name, &block)
        # Select instance methods but not those which are intance methods received by extending a class
        methods = (instance_methods - superclass.instance_methods(false))

        if methods.include?(method_name.to_sym)
          raise(Element::Error, "Method '#{method_name}' already exists.")
        end

        define_method(method_name, &block)
      end
    end
  end
end
