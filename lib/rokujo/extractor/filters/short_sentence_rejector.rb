# frozen_string_literal: true

module Rokujo
  module Extractor
    module Filters
      # A filter to reject short sentences.
      class ShortSentenceRejector
        MIN_CHAR_LEN = 10

        # @param min [Integer] The minimum character length. The default is MIN_CHAR_LEN
        def initialize(min: MIN_CHAR_LEN)
          @min = min
        end

        # @param sentences [Array<String>] The sentence to filter.
        # @return [Array<String>] Filtered Array of String.
        def call(sentences)
          sentences.select { |sentence| sentence.length >= @min }
        end
      end
    end
  end
end
