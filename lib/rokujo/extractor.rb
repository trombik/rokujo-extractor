# frozen_string_literal: true

require "marcel"

require_relative "extractor/version"
require_relative "extractor/base"
require_relative "extractor/text"
require_relative "extractor/docx"
require_relative "extractor/pdf"
require_relative "extractor/jsonl"
require_relative "extractor/helpers"

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
    # Factory method to return appropriate extractor instance
    def self.create(file_path, **opts)
      extractor = extractor_by_extention(file_path, **opts) || extractor_by_mime(file_path, **opts)
      raise UnsupportedFileTypeError, "Unsupported file type: #{file_path}" unless extractor

      extractor
    end

    def self.extractor_by_extention(file_path, **opts)
      case File.extname(file_path).downcase
      when ".pdf"
        PDF.new(file_path, **opts)
      when ".docx"
        Docx.new(file_path, **opts)
      when ".txt"
        Text.new(file_path, **opts)
      end
    end

    def self.extractor_by_mime(file_path, **opts)
      # see /usr/local/etc/mime.types for available MIME types
      case Marcel::MimeType.for Pathname.new(file_path), name: Pathname.new(file_path).basename.to_s
      when "application/pdf"
        PDF.new(file_path, **opts)
      when "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        Docx.new(file_path, **opts)
      when "text/plain"
        Text.new(file_path, **opts)
      end
    end

    private_class_method :extractor_by_mime, :extractor_by_extention

    class Error < StandardError; end
    class UnsupportedFileTypeError < Error; end
  end
end
