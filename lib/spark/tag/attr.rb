# frozen_string_literal: true

require_relative "hash"
require_relative "classname"

module Spark
  module Tag
    class Attr < Tag::Hash
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
        self[:aria] ||= Tag::Hash.new(*args, prefix: :aria)
      end

      def data(*args)
        self[:data] ||= Tag::Hash.new(*args, prefix: :data)
      end

      def classname(*args, base: nil)
        self[:class] ||= Tag::Classname.new(*args, base: base)
      end
    end
  end
end
