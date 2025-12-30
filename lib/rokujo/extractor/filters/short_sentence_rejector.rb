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
        # @param bar [TTY::ProgressBar] Otional progress bar.
        def call(sentences, bar = nil)
          bar&.configure do |config|
            config.total = sentences.count
          end
          selected = sentences.select do |sentence|
            result = sentence.length >= @min
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

        def base_class_name
          self.class.name.split("::").last
        end
      end
    end
  end
end
