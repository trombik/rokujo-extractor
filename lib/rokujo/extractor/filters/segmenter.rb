# frozen_string_literal: true

require "pragmatic_segmenter"

module Rokujo
  module Extractor
    module Filters
      # A filter to detects sentence boundaries.
      #
      # Input:
      #
      # "Hello world. My name is Mr. Smith. I work for the U.S. Government and I live in the U.S. I live in New York."
      #
      # Output:
      #
      # ["Hello world.", "My name is Mr. Smith.", "I work for the U.S. Government and I live in the U.S.",
      # "I live in New York."]
      class Segmenter
        def initialize; end

        # @param input_string [String] The text string to analyze.
        # @return [Array<String>] Array of segmented sentences.
        def call(input_string)
          PragmaticSegmenter::Segmenter.new(text: input_string, language: "ja").segment
        end
      end
    end
  end
end
