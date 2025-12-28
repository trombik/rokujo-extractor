# frozen_string_literal: true

require "shellwords"
require "pdf-reader"
require "tty-spinner"

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
        spinner = TTY::Spinner.new("[:spinner] Parsing PDF...", format: :dots)
        spinner.auto_spin
        result = reader.pages.map(&:text).join("\n")
        spinner.stop("Done")
        result
      end
    end
  end
end
