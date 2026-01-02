# frozen_string_literal: true

require "json"

module Rokujo
  module Extractor
    # Extracts sentences from a JSON Lines (.jsonl) file.
    #
    # This extractor processes each line of the JSONL file as a separate JSON object,
    # assuming the text content is stored under the top-level "text" key. It provides
    # flexibility in UUID generation (per-element or per-resource).
    #
    # Some dataset store multiple lines of text. For example:
    #
    # @example Multiple sentences in an element.
    #   {"text": "First sentence. Second sentence.", "other": "metadata"}
    #   {"text": "Another sentence. Yet another sentence. Possibly the entire sentences of a book", "other": "metadata"}
    #
    # In that case, specify `uuid_per_jsonl_element` to `true`. Each sentence
    # in an element will have a UUID.
    #
    # Other dataset store a single sentence in `text` attribute.
    #
    # @example A single sentence in an eleemnt.
    #   {"text": "First sentence.", "other": "metadata"}
    #   {"text": "Second sentence.", "other": "metadata"}
    #
    # In that case, specify `uuid_per_jsonl_element` to `false`. Each sentence
    # in the file will have a UUID.
    class JSONL < Base
      include Rokujo::Extractor::Concerns::Identifiable

      # Initializes a new JSONL extractor instance.
      #
      # @param location [String, Pathname] The path to the JSONL file to process
      # @param opts [Hash] Configuration options
      # @option opts [Boolean] :uuid_per_jsonl_element (true) When true, generates a unique UUID
      #                  for each element in the JSONL file. When false, uses the UUID of the
      #                  entire resource for all elements.
      def initialize(location, opts = {})
        super
        # when true, generates UUID per element in JSONL file.
        # when false, use the UUID of the resource.
        @opts[:uuid_per_jsonl_element] = @opts.fetch(:uuid_per_jsonl_element, true)
      end

      # Extracts sentences from the JSONL file.
      #
      # Processes each line through the sentence processing pipeline and collects
      # the results with associated metadata.
      #
      # @return [Array<Hash>] Array of sentence hashes, each containing:
      #   - :text [String] The extracted sentence text
      #   - :meta [Hash] Metadata including line number and UUID
      def extract_sentences
        sentences = []
        file_content.with_index(1) do |line, index|
          content = raw_text(line, index)
          return [] if content.nil? || content.empty?

          results = pipeline.run(content).map.with_index do |sentence, index|
            sentence_to_h(sentence, index)
          end
          sentences.concat results
        end
        sentences
      end

      # Creates the sentence processing pipeline.
      #
      # @return [Rokujo::Pipeline] Configured pipeline instance with all filters
      def pipeline
        Pipeline.new(*pipeline_filters, widget_enable: @widget_enable)
      end

      # Converts a sentence string into a structured hash with metadata.
      #
      # @param sentence [String] The sentence text to convert
      # @param index [Integer] The zero-based index of the sentence
      # @return [Hash] Structured sentence data with text and metadata
      def sentence_to_h(sentence, index)
        {
          text: sentence.strip,
          meta: {
            line_number: index + 1,
            uuid: uuid_per_jsonl_element? ? uuid : metadata.uuid
          }
        }
      end

      # Determines whether to generate UUIDs per JSONL element.
      #
      # @return [Boolean] True if UUIDs should be generated per element, false to use resource UUID
      def uuid_per_jsonl_element?
        opts[:uuid_per_jsonl_element]
      end

      # Extracts raw text content from a JSONL line.
      #
      # @param line [String] The JSONL line to parse
      # @param index [Integer] The one-based line number (for error reporting)
      # @return [String] The text content
      # @raise [JSON::ParserError] If the line contains invalid JSON
      def raw_text(line, index)
        JSON.parse(line)["text"]
      rescue e
        raise e, "Failed to parse JSON at:\n" \
                 "#{location.realpath}:#{index}\n" \
                 "#{line.inspect}"
      end

      # Reads the JSONL file content line by line.
      def file_content
        File.foreach(location)
      end

      # Extracts metadata from the JSONL file.
      #
      # @return [Rokujo::Extractor::Metadata::JSONL] Metadata object for this JSONL file
      def extract_metadata
        Rokujo::Extractor::Metadata::JSONL.new(location)
      end
    end
  end
end
