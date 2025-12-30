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
        def call(sentences, bar = nil)
          bar&.configure do |config|
            config.total = sentences.count
          end
          selected = sentences.select do |sentence|
            result = include_verb?(sentence)
            bar&.advance
            result
          end
          bar&.finish
          selected
        end

        def widget
          ::TTY::ProgressBar.new("#{base_class_name} [:bar]")
        end

        private

        def include_verb?(sentence)
          doc = @nlp.read(sentence)
          # does the sentence have a verb?
          return true if doc.tokens.any? { |token| token.pos == "VERB" }

          # does the sentence have predicate (述語)?
          return true if doc_include_predicate?(doc)

          false
        end

        # True if tokens include predicate. Predicate is not labled as VERB but
        # as NOUN (日本人) + AUX (です) + PUNCT (。)
        def doc_include_predicate?(doc)
          tokens_without_punct = doc.tokens.reject { |token| token&.pos&.match?(/PUNCT|SYM/) }
          return true if tokens_include_predicate?(tokens_without_punct)

          false
        end

        # Returns bool if the given tokens end with a predicate.
        #
        # As this menthod determins if the tokens include predicate by using
        # the last two tokens, the tokens must not include PUNCT or SYM, such
        # as `。`.
        def tokens_include_predicate?(tokens)
          # does the sentence have 述語? such as "述語です"?
          last_token = tokens.last
          prev_token = tokens[-2]
          last_token&.pos == "AUX" && prev_token&.pos&.match?(/NOUN|PROPN|PRON/)
        end

        def base_class_name
          self.class.name.split("::").last
        end
      end
    end
  end
end
