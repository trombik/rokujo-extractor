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
          @uuid ||= if ::SecureRandom.respond_to?(:uuid_v7)
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
        def hexdigest(content)
          @hexdigest ||= ::Digest::SHA256.hexdigest(content)
        end
      end
    end
  end
end
