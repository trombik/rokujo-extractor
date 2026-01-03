# frozen_string_literal: true

module Rokujo
  module Extractor
    module Filters
      # A filter to reject short sentences.
      class ShortSentenceRejector < Base
        MIN_CHAR_LEN = 10

        # @param min [Integer] The minimum character length. The default is MIN_CHAR_LEN
        def initialize(min: MIN_CHAR_LEN)
          @min = min
          super()
        end

        # @param sentences [Array<String>] The sentence to filter.
        # @return [Array<String>] Filtered Array of String.
        # @param bar [TTY::ProgressBar] Otional progress bar.
        def call(sentences, widget_enable: true)
          self.widget_enable = widget_enable
          with_progress(total: sentences.count * 512) do |bar|
            selected = sentences.select do |sentence|
              result = sentence.length >= @min
              bar&.advance(512)
              result
            end
            bar&.finish
            selected
          end
        end
      end
    end
  end
end
