# frozen_string_literal: true

module Rokujo
  module Extractor
    # Extracts plain text files.
    class Text < Base
      protected

      def raw_text
        File.read(@file_path, encoding: "UTF-8")
      rescue StandardError => e
        raise Error, "failed to read #{@file_path}: #{e.message}"
      end
    end
  end
end
