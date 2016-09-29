module Assist
  module ParamsHelper
    def self.included(base)
      base.extend(ClassMethods)
    end

    private

    def normalize_keys(hash)
      new_hash = {}
      hash.each { |key, val| new_hash[normalize(key)] = val }
      new_hash
    end

    def normalize(value)
      self.class.normalize(value)
    end

    module ClassMethods
      def normalize(value)
        value.downcase.to_sym
      end

      def normalize_block
        proc { |value| normalize(value) }
      end
    end
  end
end
