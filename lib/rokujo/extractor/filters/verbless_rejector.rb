# frozen_string_literal: true

require "ruby-spacy"

module Rokujo
  module Extractor
    module Filters
      # A filter that rejects sentences without verb.
      class VerblessRejector < Base
        # The default model name
        DEFAULT_SPACY_MODEL_NAME = "ja_ginza"

        # @param model [Object] A language model created with Spacy::Language.new.
        #                       The default model is DEFAULT_SPACY_MODEL_NAME
        def initialize(model: nil)
          @nlp = model || Spacy::Language.new(DEFAULT_SPACY_MODEL_NAME)
          super()
        end

        # @param sentences [Array<String>]
        # @return [Array<String>] Array of filtered sentences.
        def call(sentences, widget_enable: true)
          self.widget_enable = widget_enable
          with_progress(total: sentences.count * 512) do |bar|
            selected = sentences.select do |sentence|
              result = sentence_include_predicate?(sentence)
              bar&.advance(512)
              result
            end
            bar&.finish
            selected
          end
        end

        private

        def sentence_include_predicate?(sentence)
          doc = @nlp.read(sentence)
          tokens_include_predicate?(doc.tokens)
        end

        # Returns true or false if the given tokens has a predicate.
        #
        # rubocop:disable Metrics/CyclomaticComplexity
        # The logic here is complecated and it does no improve readability
        # even if the logic is refactored into multiple methods.
        def tokens_include_predicate?(tokens)
          # if nsubj is found, there should be 述語
          return true if tokens.any? { |t| t.dep_ == "nsubj" }

          # find the ROOT token and, if found, see if Part-of-Speech (pos) either:
          # * indicates an action or process (VERB)
          # * indicates a state or quality (ADJ)
          # * indicates a copula or auxiliary state (AUX, e.g., "だ" or "です")
          root_token = tokens.find { |t| t.dep_ == "ROOT" }
          return true if root_token && %w[VERB ADJ AUX].include?(root_token.pos)

          return true if tokens.any? { |t| t.tag_.start_with?("動詞", "形容詞") }

          false
        end
        # rubocop:enable Metrics/CyclomaticComplexity
      end
    end
  end
end
