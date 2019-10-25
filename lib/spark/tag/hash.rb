# frozen_string_literal: true

module Spark
  module Tag
    class Hash < Hash
      def initialize(*args, prefix: nil)
        super(*args)
        @prefix = prefix
      end

      def add(hash)
        merge!(hash) unless hash.blank?
        self
      end

      # Output all attributes as [prefix-]name="value"
      def to_s
        each_with_object([]) do |(name, value), array|
          if value.is_a?(Spark::Tag::Hash)
            # Flatten nested hashs and inject them unless empty
            value = value.to_s
            array << value unless value.empty?
          else
            name = [@prefix, name].compact.join("-").gsub(/[\W_]+/, "-")
            array << %(#{name}="#{value}") unless value.nil?
          end
        end.sort.join(" ")
      end
    end
  end
end

