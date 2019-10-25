# frozen_string_literal: true

require_relative "element"
require_relative "attribute"
require_relative "tag/attrs"

module Spark
  module Component
    def self.included(base)
      base.include Spark::Attribute
      base.include Spark::Element
    end

    # Override ActionView::Components::Base `render_in`
    # This is only necessary in order to pass `self` as a block parameter
    #
    def render_in(view_context, &block)
      self.class.compile
      @view_context = view_context
      @view_renderer ||= view_context.view_renderer
      @lookup_context ||= view_context.lookup_context
      @view_flow ||= view_context.view_flow
      @virtual_path ||= virtual_path

      # Pass self as a block parameter
      @content = view_context.capture(self, &block) if block_given?
      validate!
      call
    end

    # Setup attributes and elements.
    #
    # While an ActionView Component doesn't receive a block, if it
    # is extended as an element of another component, it will receive
    # its own block for rendering.
    #
    def initialize(attributes = nil, &block)
      initialize_attributes(attributes)
      initialize_elements
      super(attributes, &block)
    end
  end
end
