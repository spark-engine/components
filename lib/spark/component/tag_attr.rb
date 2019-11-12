# frozen_string_literal: true

require "spark/component/attr"
require "spark/component/classname"

module Spark
  module Component
    class TagAttr < Component::Attr
      def add(hash)
        return self if hash.nil? || hash.keys.empty?

        # Extract keys for special properties
        extracted = {
          aria: hash.delete(:aria),
          data: hash.delete(:data),
          classname: hash.delete(:class)
        }

        # If extracted values exist, add to tag
        extracted.each do |method, val|
          send(method).add(val) unless val.nil? || val.empty?
        end

        # Add html using recursion, this ensures that nested data, aria, or class
        # attributes are properly merged as the right data types
        add(hash.delete(:html))

        super(hash)
      end

      def aria(*args)
        self[:aria] ||= Attr.new(*args, prefix: :aria)
      end

      def data(*args)
        self[:data] ||= Attr.new(*args, prefix: :data)
      end

      def classname(*args, base: nil)
        self[:class] ||= Classname.new(*args, base: base)
      end
    end
  end
end
