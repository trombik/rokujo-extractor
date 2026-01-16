# frozen_string_literal: true

require_relative "base"
require_relative "../metadata/text"

module Rokujo
  module Extractor
    module Parsers
      # Extracts plain text files.
      class Text < Base
        protected

        def raw_text
          File.read(@location, encoding: "UTF-8")
        rescue StandardError => e
          raise Error, "failed to read #{@location}: #{e.message}"
        end

        def extract_metadata
          Rokujo::Extractor::Metadata::Text.new(@location)
        end
      end
    end
  end
end
