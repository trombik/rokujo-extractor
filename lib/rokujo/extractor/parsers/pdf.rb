# frozen_string_literal: true

require "shellwords"
require "pdf-reader"
require_relative "base"
require_relative "../metadata"
require_relative "../items/pdf_item"

module Rokujo
  module Extractor
    module Parsers
      # Extracts PDF files.
      class PDF < Base
        def initialize(location, opts = {})
          super
        end

        def item
          return @item if @item

          @item = Rokujo::Extractor::Items::PdfItem.new(location)
          @item.body = extract_sentences
          @item.uuid = uuid
          @item
        end

        protected

        def reader
          @reader ||= ::PDF::Reader.new(location.to_s)
        rescue StandardError => e
          raise e, "failed to read #{@location}: #{e.message}"
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
end
