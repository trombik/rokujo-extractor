# frozen_string_literal: true

require "docx"
require_relative "base"
require_relative "../metadata"

module Rokujo
  module Extractor
    module Parsers
      # Extracts docx file.
      class Docx < Base
        protected

        def raw_text
          doc = ::Docx::Document.open(@file_path)
          doc.paragraphs.map(&:text).join("\n")
        rescue StandardError => e
          raise Error, "failed to read #{@file_path}: #{e.message}"
        end

        def extract_metadata
          Rokujo::Extractor::Metadata::Docx.new(@location)
        end
      end
    end
  end
end
