# frozen_string_literal: true

require_relative "helpers"
require_relative "pipeline"
require_relative "filters"
require_relative "formatters"

module Rokujo
  module Extractor
    # The base class of Extractors
    class Base
      include Rokujo::Extractor::Helpers

      attr_reader :file_path, :metadata

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

        pipeline = Pipeline.new(*pipeline_filters, widget_enable: @widget_enable)
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

      private

      def pipeline_filters
        [
          Filters::LineReconstructor.new,
          Filters::Segmenter.new,
          Filters::VerblessRejector.new(model: @nlp),
          Filters::BulletRemover.new,
          Filters::UrlRemover.new,
          Filters::JapaneseSelector.new,
          Filters::ShortSentenceRejector.new
        ]
      end
    end
  end
end
