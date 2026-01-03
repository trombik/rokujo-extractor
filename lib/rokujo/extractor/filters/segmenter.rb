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
        def call(input_string, spinner = nil)
          spinner&.auto_spin
          result = PragmaticSegmenter::Segmenter.new(text: input_string, language: "ja").segment
          spinner&.success("Done")
          result
        end

        def widget
          ::TTY::Spinner.new("[:spinner] #{base_class_name} Processing ... ",
                             success_mark: pastel.green("✔"))
        end
      end
    end
  end
end
