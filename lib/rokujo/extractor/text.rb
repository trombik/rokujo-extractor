# frozen_string_literal: true

module Rokujo
  module Extractor
    # Extracts plain text files.
    class Text < Base
      protected

      def raw_text
        spinner = TTY::Spinner.new("[:spinner] Parsing Text...", format: :dots)
        spinner.auto_spin
        result = File.read(@file_path, encoding: "UTF-8")
        spinner.stop("Done")
        result
      rescue StandardError => e
        raise Error, "failed to read #{@file_path}: #{e.message}"
      end
    end
  end
end
