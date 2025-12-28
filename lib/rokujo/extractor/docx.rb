# frozen_string_literal: true

require "docx"

module Rokujo
  module Extractor
    # Extracts docx file.
    class Docx < Base
      protected

      def raw_text
        spinner = TTY::Spinner.new("[:spinner] Parsing Docx...", format: :dots)
        spinner.auto_spin
        doc = ::Docx::Document.open(@file_path)
        result = doc.paragraphs.map(&:text).join("\n")
        spinner.stop("Done")
        result
      rescue StandardError => e
        raise Error, "failed to read #{@file_path}: #{e.message}"
      end
    end
  end
end
