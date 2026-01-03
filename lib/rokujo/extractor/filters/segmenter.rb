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
        def call(input_string, widget_enable: true)
          self.widget_enable = widget_enable
          with_spinner do |spinner|
            result = PragmaticSegmenter::Segmenter.new(text: input_string, language: "ja").segment
            spinner&.success("Done")
            result
          end
        end
      end
    end
  end
end
