# frozen_string_literal: true

require_relative "helpers"
require_relative "pipeline"
require_relative "filters"

module Rokujo
  module Extractor
    # The base class of Extractors
    class Base
      include Rokujo::Extractor::Helpers

      attr_reader :file_path, :metadata

      MIN_CHAR_LEN_BREAK = 10
      MIN_CHAR_LEN_SELECT = 10
      DEFAULT_SPACY_MODEL_NAME = "ja_ginza"

      def initialize(file_path, **opts)
        @file_path = file_path
        @metadata = opts.fetch(:metadata, {})
        @nlp = opts.fetch(:model) do |key|
          warn "#{key} is not passed. Using #{DEFAULT_SPACY_MODEL_NAME}"
          Spacy::Language.new(DEFAULT_SPACY_MODEL_NAME)
        end
        @widget_enable = opts.fetch(:widget_enable, true)
      end

      def extract_sentences
        content = with_spinner(message: "[:spinner] Parsing ...") { raw_text }
        return [] if content.nil? || content.empty?

        pipeline = Pipeline.new(
          Filters::LineReconstructor.new,
          Filters::Segmenter.new,
          Filters::VerblessRejector.new(model: @nlp),
          Filters::JapaneseSelector.new,
          Filters::ShortSentenceRejector.new,
          widget_enable: @widget_enable
        )

        pipeline.run(content).map.with_index do |s, i|
          {
            content: s.strip,
            line_number: i + 1,
            meta_info: @metadata
          }
        end
      end

      protected

      def raw_text
        raise NotImplementedError, "Subclasses must implement raw_text"
      end
    end
  end
end
