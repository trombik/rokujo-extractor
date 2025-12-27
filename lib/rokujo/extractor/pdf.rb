# frozen_string_literal: true

require "shellwords"
require "pdf-reader"

module Rokujo
  module Extractor
    # Extracts PDF files.
    class PDF < Base
      protected

      def reader
        ::PDF::Reader.new(@file_path)
      rescue StandardError => e
        raise Error, "failed to read #{@file_path}: #{e.message}"
      end

      def raw_text
        reader.pages.map(&:text).join("\n")
      end
    end
  end
end
