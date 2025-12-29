# frozen_string_literal: true

require "ruby-spacy"

module Rokujo
  module Extractor
    module Filters
      # A filter that rejects sentences without verb.
      class VerblessRejector
        # The default model name
        DEFAULT_SPACY_MODEL_NAME = "ja_ginza"

        # @param model [Object] A language model created with Spacy::Language.new.
        #                       The default model is DEFAULT_SPACY_MODEL_NAME
        def initialize(model: nil)
          @nlp = model || Spacy::Language.new(DEFAULT_SPACY_MODEL_NAME)
        end

        # @param sentences [Array<String>]
        # @return [Array<String>] Array of filtered sentences.
        def call(sentences)
          sentences.select do |sentence|
            include_verb?(sentence)
          end
        end

        private

        def include_verb?(sentence)
          doc = @nlp.read(sentence)
          # does the sentence have a verb?
          return true if doc.tokens.any? { |token| token.pos == "VERB" }

          # does the sentence have predicate (述語)?
          return true if tokens_include_predicate?(doc)

          false
        end

        # True if tokens include predicate. Predicate is not labled as VERB but
        # as NOUN (日本人) + AUX (です) + PUNCT (。)
        def tokens_include_predicate?(doc)
          # We need to know the last token but not PUNCT, such as `。`.
          tokens_without_punct = doc.tokens.reject { |token| token.pos.match?(/PUNCT|SYM/) }

          # does the sentence have 述語? such as "述語です"?
          last_token = tokens_without_punct.last
          prev_token = tokens_without_punct[-2]
          return true if last_token.pos == "AUX" && prev_token&.pos&.match?(/NOUN|PROPN|PRON/)

          false
        end
      end
    end
  end
end
