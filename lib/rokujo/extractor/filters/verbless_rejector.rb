# frozen_string_literal: true

require "ruby-spacy"
require "parallel"
require "etc"

module Rokujo
  module Extractor
    module Filters
      # A filter that rejects sentences without verb.
      class VerblessRejector < Base
        # The default model name
        DEFAULT_SPACY_MODEL_NAME = "ja_ginza"
        DEFAULT_NCPU = Etc.nprocessors # number of physical processors exceluding HT
        DEFAULT_CHUNK_SIZE = 50
        PLATFORM_DOES_NOT_SUPPORTS_FORK = Etc.uname[:sysname] =~ /Windows|MSYS|MINGW/ ? true : false

        # @param model [Object] A language model created with Spacy::Language.new.
        #                       The default model is DEFAULT_SPACY_MODEL_NAME
        def initialize(model: nil)
          # request the GC to start before creating a new instance of Spacy
          # model. this resovles a possible deadlock.
          GC.start
          @nlp = model || Spacy::Language.new(DEFAULT_SPACY_MODEL_NAME)
          super()
        end

        # @param sentences [Array<String>]
        # @return [Array<String>] Array of filtered sentences.
        def call(sentences, widget_enable: true, ncpu: DEFAULT_NCPU, chunk_size: DEFAULT_CHUNK_SIZE)
          # disable parallelism when the patform does not support fork
          if ncpu <= 1 || PLATFORM_DOES_NOT_SUPPORTS_FORK
            call_iterator(sentences, widget_enable: widget_enable)
          else
            call_parallel(sentences, widget_enable: widget_enable, ncpu: ncpu, chunk_size: chunk_size)
          end
        end

        private

        # Parallel version. process chunks of sentences with ncpu cores
        def call_parallel(sentences, widget_enable:, ncpu:, chunk_size:)
          progress = widget_enable ? { title: "VerblessRejector", output: $stderr } : nil
          Parallel.map(sentences.each_slice(chunk_size), progress: progress, in_processes: ncpu) do |chunk|
            chunk.select do |sentence|
              sentence_include_predicate?(sentence)
            end
          end.flatten
        end

        # Iterator version. Does not store all the sentences in memory.
        def call_iterator(sentences, widget_enable:)
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
