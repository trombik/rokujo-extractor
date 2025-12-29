# frozen_string_literal: true

module Rokujo
  module Extractor
    module Filters
      # A filter to select Japanese sentences
      class JapaneseSelector
        # @param progress_bar [TTY::ProgressBar] Otional progress bar.
        def initialize(progress_bar: nil)
          @bar = progress_bar
        end

        # @param sentences [Array<String>] The sentences to filter.
        def call(sentences)
          sentences.select do |sentence|
            result = ends_with_japanese?(sentence)
            @bar&.advance
            result
          end
        end

        private

        def ends_with_japanese?(sentence)
          sentence.strip.match?(/[\p{hiragana}\p{katakana}\p{han}〜ー][\p{P}\p{Pe}]?\z/)
        end
      end
    end
  end
end
