# frozen_string_literal: true

require_relative "base"

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
      end
    end
  end
end
