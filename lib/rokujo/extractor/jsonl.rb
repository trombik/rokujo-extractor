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
        file_content.each_line do |line|
          texts << JSON.parse(line)["text"]
        end
        texts.join("\n")
      end

      def file_content
        File.read(@file_path)
      end

      def extract_metadata
        Rokujo::Extractor::Metadata::JSONL.new(@location)
      end
    end
  end
end
