# frozen_string_literal: true

module SparkComponents
  class Element
    include ActiveModel::Validations

    attr_accessor :yield
    attr_reader :parents, :attr

    def self.model_name
      ActiveModel::Name.new(SparkComponents::Element)
    end

    def self.attributes
      @attributes ||= {}
    end

    def self.elements
      @elements ||= {}
    end

    def self.attribute(*args)
      args.each_with_object({}) do |arg, obj|
        if arg.is_a?(Hash)
          arg.each do |attr, default|
            obj[attr.to_sym] = default
            set_attribute(attr.to_sym, default: default)
          end
        else
          obj[arg.to_sym] = nil
          set_attribute(arg.to_sym)
        end
      end
    end

    def self.set_attribute(name, default: nil)
      attributes[name] = { default: default }

      define_method_or_raise(name) do
        get_instance_variable(name)
      end
    end

    def self.base_class(name)
      attrs.classnames.base = name
    end

    def self.add_class(*args)
      attrs.classnames.add(*args)
    end

    def self.data_attr(*args)
      attrs.data.add(attribute(*args))
    end

    def self.aria_attr(*args)
      attrs.aria.add(attribute(*args))
    end

    def self.root_attr(*args)
      attrs.root.add(attribute(*args))
    end

    def self.attrs
      @attrs ||= SparkComponents::Attributes::Tag.new
    end

    def self.validates_choice(name, choices)
      validates(name, inclusion: {
        presence: true,
        in: choices,
        message: "\"%{value}\" is not a valid option. Options include: #{choices.join(", ")}"
      })
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def self.element(name, multiple: false, component: nil, &config)
      plural_name = name.to_s.pluralize.to_sym if multiple

      # Extend components by string or class; e.g., "core/header" or Core::HeaderComponent
      component = "#{component}_component".classify.constantize if component.is_a?(String)

      elements[name] = {
        multiple: plural_name || false, class: Class.new(component || Element, &config)
      }

      define_method_or_raise(name) do |attributes = nil, &block|
        return get_instance_variable(multiple ? plural_name : name) unless attributes || block

        element = self.class.elements[name][:class].new(@view, attributes, &block)
        element.parent = self

        if multiple
          get_instance_variable(plural_name) << element
        else
          set_instance_variable(name, element)
        end

        if element.respond_to?(:render)
          element.before_render
          element.yield = element.render
        end
      end

      return if !multiple || name == plural_name

      define_method_or_raise(plural_name) do
        get_instance_variable(plural_name)
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity

    def self.define_method_or_raise(method_name, &block)
      # Select instance methods but not those which are intance methods received by extending a class
      methods = (instance_methods - superclass.instance_methods(false))
      raise(SparkComponents::Error, "Method '#{method_name}' already exists.") if methods.include?(method_name.to_sym)

      define_method(method_name, &block)
    end
    private_class_method :define_method_or_raise

    def self.inherited(subclass)
      attributes.each { |name, options| subclass.set_attribute(name, options.dup) }
      elements.each   { |name, options| subclass.elements[name] = options.dup }

      subclass.attrs.merge!(attrs.dup)
    end

    def initialize(view, attributes = nil, &block)
      @view = view
      attributes ||= {}
      initialize_attrs
      assign_attrs(attributes)
      initialize_attributes(attributes)
      initialize_elements
      extend_view_methods
      after_init
      @yield = block_given? ? @view.capture(self, &block) : nil
      validate!
    end

    def after_init; end

    def before_render; end

    def parent=(obj)
      @parents = [obj.parents, obj].flatten.compact
    end

    def parent
      @parents.last
    end

    def classnames
      @attrs.classnames
    end

    def base_class(name = nil)
      classnames.base = name unless name.nil?
      classnames.base
    end

    def add_class(*args)
      classnames.add(*args)
    end

    def join_class(name, separator: "-")
      [base_class, name].join(separator) unless base_class.nil?
    end

    def data_attr(*args)
      @attrs.data.add(*args)
    end

    def aria_attr(*args)
      @attrs.aria.add(*args)
    end

    def root_attr(*args)
      @attrs.root.add(*args)
    end

    def tag_attrs(add_class: true)
      atr = @attrs.attrs
      atr.delete(:class) unless add_class
      atr
    end

    def to_s
      @yield
    end

    # blank? is aliased to an element's content to easily determine if content is blank.
    # This is because template conditionals may render an element's content empty.

    def blank?
      @yield.blank?
    end

    protected

    # Set tag attribute values from from parameters
    def update_attr(name)
      %i[aria data root].each do |el|
        @attrs.send(el)[name] = get_instance_variable(name) if @attrs.send(el).key?(name)
      end
    end

    def render_partial(file)
      @view.render(partial: file, object: self)
    end

    def initialize_attrs
      @attrs = self.class.attrs.dup
    end

    # Assign tag attributes from arguments
    def assign_attrs(attributes)
      # support default data, class, and aria attribute names
      data_attr(attributes.delete(:data)) if attributes[:data]
      aria_attr(attributes.delete(:aria)) if attributes[:aria]
      add_class(*attributes.delete(:class)) if attributes[:class]
      root_attr(attributes.delete(:splat)) if attributes[:splat]
    end

    def initialize_attributes(attributes)
      self.class.attributes.each do |name, options|
        set_instance_variable(name, attributes[name] || (options[:default] && options[:default].dup))
        update_attr(name)
      end
    end

    def initialize_elements
      self.class.elements.each do |name, options|
        if (plural_name = options[:multiple])
          set_instance_variable(plural_name, [])
        else
          set_instance_variable(name, nil)
        end
      end
    end

    private

    # Define common view methods to "alias"
    def view_methods
      %i[tag content_tag image_tag concat content_for link_to component capture]
    end

    def extend_view_methods
      view_methods.each do |name|
        next if respond_to?(name) || !@view.respond_to?(name)

        self.class.define_method(name) do |*args, &block|
          @view.send(name, *args, &block)
        end
      end
    end

    def get_instance_variable(name)
      instance_variable_get(:"@#{name}")
    end

    def set_instance_variable(name, value)
      instance_variable_set(:"@#{name}", value)
    end
  end
end
