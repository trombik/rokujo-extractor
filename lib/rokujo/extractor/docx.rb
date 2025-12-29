# frozen_string_literal: true

require "docx"

module Rokujo
  module Extractor
    # Extracts docx file.
    class Docx < Base
      protected

      def raw_text
        doc = ::Docx::Document.open(@file_path)
        doc.paragraphs.map(&:text).join("\n")
      rescue StandardError => e
        raise Error, "failed to read #{@file_path}: #{e.message}"
      end
    end
  end
end
