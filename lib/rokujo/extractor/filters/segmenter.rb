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
      class Segmenter < Base
        # @param input_string [String] The text string to analyze.
        # @return [Array<String>] Array of segmented sentences.
        # @param spinner [TTY::Spinner] Otional spinner
        def call(input, widget_enable: true)
          self.widget_enable = widget_enable
          items = Array(input)

          with_spinner do |spinner|
            # use flat_map as PragmaticSegmenter::Segmenter returns an Array.
            result = items.flat_map do |text|
              PragmaticSegmenter::Segmenter.new(text: text, language: "ja").segment
            end
            spinner&.success("Done")
            result
          end
        end
      end
    end
  end
end
