# frozen_string_literal: true

require_relative "../pipeline"
require_relative "../filters"
require_relative "../formatters"
require_relative "../concerns/renderable"
require_relative "../errors"

module Rokujo
  module Extractor
    module Parsers
      # The base class of Extractors
      class Base
        include Rokujo::Extractor::Concerns::Renderable

        attr_reader :location, :opts

        DEFAULT_SPACY_MODEL_NAME = "ja_ginza"

        def initialize(location, opts = {})
          @location = Pathname.new(location)
          @opts = opts
          @nlp = @opts.fetch(:model) do |key|
            warn "#{key} is not passed. Using #{DEFAULT_SPACY_MODEL_NAME}"
            Spacy::Language.new(DEFAULT_SPACY_MODEL_NAME)
          end
          self.widget_enable = @opts.fetch(:widget_enable, true)
        end

        def extract_sentences
          content = raw_text
          return [] if content.nil? || content.empty?

          pipeline = Pipeline.new(*pipeline_filters, widget_enable: @widget_enable)
          pipeline.run(content).map.with_index do |s, i|
            {
              text: s.strip,
              meta: {
                line_number: i + 1,
                uuid: metadata.uuid
              }
            }
          end
        end

        # Extracts metadata from a resource.
        #
        # @return [Object] Metadata object.
        def extract_metadata
          raise Rokujo::Extractor::Errors::NotImplementedError, "#{self.class} must implement #{__method__}"
        end

        def metadata
          @metadata ||= extract_metadata
        end

        protected

        def raw_text
          raise Rokujo::Extractor::Errors::NotImplementedError, "#{self.class} must implement #{__method__}"
        end

        private

        def pipeline_filters
          [
            Filters::Normalizer.new,
            Filters::LineReconstructor.new,
            Filters::Segmenter.new,
            Filters::VerblessRejector.new(model: @nlp),
            Filters::BulletRemover.new,
            Filters::UrlRemover.new,
            Filters::JapaneseSelector.new,
            Filters::ShortSentenceRejector.new,
            Filters::StringCleaner.new
          ]
        end
      end
    end
  end
end
