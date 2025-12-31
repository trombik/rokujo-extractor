# frozen_string_literal: true

require "securerandom"
require "digest"

module Rokujo
  module Extractor
    module Concerns
      # A concern for classes to generate unique IDs
      module Identifiable
        # Generates UUID v7
        def uuid
          ::SecureRandom.uuid_v7
        end

        # Generates a SHA256 hex digest from `content`.
        #
        # @param content [String]
        # @example
        #   hexdigest(File.read(path))
        #
        def hexdigest(content)
          ::Digest::SHA256.hexdigest(content)
        end
      end
    end
  end
end
