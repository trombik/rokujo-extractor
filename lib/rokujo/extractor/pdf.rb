# frozen_string_literal: true

require "shellwords"
require "pdf-reader"
require_relative "helpers"

module Rokujo
  module Extractor
    # Extracts PDF files.
    class PDF < Base
      protected

      def reader
        @reader ||= ::PDF::Reader.new(@location)
      rescue StandardError => e
        raise Error, "failed to read #{@location}: #{e.message}"
      end

      def raw_text
        @raw_text ||= reader.pages.map(&:text).join("\n")
      end

      def extract_metadata
        Rokujo::Extractor::Metadata::PDF.new(@location)
      end
    end
  end
end
