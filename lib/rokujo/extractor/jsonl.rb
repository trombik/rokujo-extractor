# frozen_string_literal: true

require "json"

module Rokujo
  module Extractor
    # Extract sentences from .jsonl file
    #
    # It assumes that the text is the value of "text" key.
    class JSONL < Base

      include Rokujo::Extractor::Concerns::Identifiable

      def extract_sentences
        sentences = []
        file_content.with_index(1) do |line, index|
          content = raw_text(line, index)
          return [] if content.nil? || content.empty?

          pipeline = Pipeline.new(*pipeline_filters, widget_enable: @widget_enable)
          results = pipeline.run(content).map.with_index do |s, i|
            {
              text: s.strip,
              meta: {
                line_number: i + 1,
                uuid: uuid
              }
            }
          end
          sentences.concat results
        end
        sentences
      end

      def raw_text(line, index)
        JSON.parse(line)["text"]
      rescue e
        raise e, "Failed to parse JSON at:\n" \
                 "#{location.realpath}:#{index}\n" \
                 "#{line.inspect}"
      end

      def file_content
        File.foreach(location)
      end

      def extract_metadata
        Rokujo::Extractor::Metadata::JSONL.new(location)
      end
    end
  end
end
