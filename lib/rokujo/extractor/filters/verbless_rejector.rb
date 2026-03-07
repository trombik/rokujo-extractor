# frozen_string_literal: true

require "net/http"

# A service to fetch tokens analysis from remote spacy API
class TextAnalysisService
  attr_reader :text

  API_URL = "http://localhost:8000/analyze_tokens"

  def initialize(text)
    @text = text
    super()
  end

  def call
    fetch(text)
  end

  private

  def uri
    @uri ||= URI(API_URL)
  end

  def request(text)
    request = Net::HTTP::Post.new(uri, { "Content-Type" => "application/json" })
    request.body = { text: text }.to_json
    request
  end

  def fetch(text)
    res = Net::HTTP.start(uri.hostname, uri.port, read_timeout: 60) do |http|
      http.request(request(text))
    end
    case res
    when Net::HTTPSuccess
      JSON.parse(res.body)["tokens"]
    else
      raise "Analysis API HTTP Error: #{res.code} #{res.message}"
    end
  end
end

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
          model = nil
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
          tokens = TextAnalysisService.new(sentence).call
          tokens_include_predicate?(tokens)
        end

        # Returns true or false if the given tokens has a predicate.
        #
        # rubocop:disable Metrics/CyclomaticComplexity
        # The logic here is complecated and it does no improve readability
        # even if the logic is refactored into multiple methods.
        def tokens_include_predicate?(tokens)
          # if nsubj is found, there should be 述語
          return true if tokens.any? { |t| t["dep"] == "nsubj" }

          # find the ROOT token and, if found, see if Part-of-Speech (pos) either:
          # * indicates an action or process (VERB)
          # * indicates a state or quality (ADJ)
          # * indicates a copula or auxiliary state (AUX, e.g., "だ" or "です")
          root_token = tokens.find { |t| t["dep"] == "ROOT" }
          return true if root_token && %w[VERB ADJ AUX].include?(root_token["pos"])

          return true if tokens.any? { |t| t["tag"].start_with?("動詞", "形容詞") }

          false
        end
        # rubocop:enable Metrics/CyclomaticComplexity
      end
    end
  end
end
