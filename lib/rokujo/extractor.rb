# frozen_string_literal: true

require_relative "extractor/version"
require_relative "extractor/base"
require_relative "extractor/text"
require_relative "extractor/docx"
require_relative "extractor/pdf"

module Rokujo
  # A factory to extratc texts from files.
  #
  # supported file types:
  #
  # * `pdf`
  # * `docx`
  # * `txt`
  #
  module Extractor
    class Error < StandardError; end

    # Factory method to return appropriate extractor instance
    def self.create(file_path, metadata = {})
      extension = File.extname(file_path).downcase
      case extension
      when ".pdf"
        PDF.new(file_path, metadata)
      when ".docx"
        Docx.new(file_path, metadata)
      else
        Text.new(file_path, metadata)
      end
    end
  end
end
