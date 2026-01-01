# frozen_string_literal: true

require_relative "helpers"
require_relative "pipeline"
require_relative "filters"
require_relative "formatters"
require_relative "concerns"

module Rokujo
  module Extractor
    # The base class of Extractors
    class Base
      include Rokujo::Extractor::Helpers
      include Rokujo::Extractor::Errors

      attr_reader :location

      DEFAULT_SPACY_MODEL_NAME = "ja_ginza"

      def initialize(location, opts = {})
        @location = Pathname.new(location)
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
            uuid: metadata.uuid
          }
        end
      end

      # Extracts metadata from a resource.
      #
      # @return [Object] Metadata object.
      def extract_metadata
        raise NotImplementedError, "#{self.class} must implement #{__method__}"
      end

      def metadata
        @metadata ||= extract_metadata
      end

      protected

      def raw_text
        raise NotImplementedError, "#{self.class} must implement #{__method__}"
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
