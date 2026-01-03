# frozen_string_literal: true

require "shellwords"
require "pdf-reader"

module Rokujo
  module Extractor
    # Extracts PDF files.
    class PDF < Base
      def initialize(location, opts = {})
        super
      end

      protected

      def reader
        @reader ||= ::PDF::Reader.new(@location)
      rescue StandardError => e
        raise Error, "failed to read #{@location}: #{e.message}"
      end

      def raw_text
        return @raw_text if @raw_text

        with_spinner(file: location.basename) do
          @raw_text = reader.pages.map(&:text).join("\n")
        end
      end

      def extract_metadata
        Rokujo::Extractor::Metadata::PDF.new(@location)
      end
    end
  end
end
