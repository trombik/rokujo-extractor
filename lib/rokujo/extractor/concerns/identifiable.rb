# frozen_string_literal: true

require "securerandom"
require "digest"

module Rokujo
  module Extractor
    module Concerns
      # A concern for classes to generate unique IDs
      module Identifiable
        # Generates UUID v7.
        #
        # @note The method does not memomize the result because an Extractor may
        #       call this method multiple times for different values, e.g., JSONL.
        def uuid_v7
          if ::SecureRandom.respond_to?(:uuid_v7)
            ::SecureRandom.uuid_v7
          else
            require "uuid7"
            ::UUID7.generate
          end
        end

        # Generates a SHA256 hex digest from `content`.
        #
        # @param content [String]
        # @example
        #   hexdigest(File.read(path))
        #
        # @note The method does not memomize the result because an Extractor may
        #       call this method multiple times for different values, e.g., JSONL.
        def hexdigest(content)
          ::Digest::SHA256.hexdigest(content)
        end
      end
    end
  end
end
