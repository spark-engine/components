# frozen_string_literal: true

module Spark
  module Tag
    class Attrs < Tag::Hash
      def add(hash)
        hash ||= {}

        # Extract keys for special properties
        aria.add(hash.delete(:aria))       if hash[:aria].present?
        data.add(hash.delete(:data))       if hash[:data].present?
        classname.add(hash.delete(:class)) if hash[:class].present?
        merge!(hash.delete(:html))         if hash[:html].present?

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

