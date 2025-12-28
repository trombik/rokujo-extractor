# frozen_string_literal: true

require "json"

module Rokujo
  module Extractor
    # Extract sentences from .jsonl file
    #
    # It assumes that the text is the value of "text" key.
    class JSONL < Base
      protected

      def raw_text
        texts = []
        spinner = TTY::Spinner.new("[:spinner] Parsing JSONL...", format: :dots)
        spinner.auto_spin
        file_content.each_line do |line|
          texts << JSON.parse(line)["text"]
        end
        result = texts.join("\n")
        spinner.stop("Done")
        result
      end

      def file_content
        File.read(@file_path)
      end
    end
  end
end
