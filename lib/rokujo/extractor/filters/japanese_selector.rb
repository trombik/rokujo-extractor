# frozen_string_literal: true

require "tty-progressbar"

module Rokujo
  module Extractor
    module Filters
      # A filter to select Japanese sentences
      class JapaneseSelector < Base
        # @param sentences [Array<String>] The sentences to filter.
        # @param bar [TTY::ProgressBar] Otional progress bar.
        def call(sentences, bar = nil)
          bar&.configure { |config| config.total = sentences.count * 100 }
          selected = sentences.select do |sentence|
            result = ends_with_japanese?(sentence)
            bar&.advance(100)
            result
          end
          bar&.finish
          selected
        end

        def widget
          widget_bar
        end

        private

        def ends_with_japanese?(sentence)
          sentence.strip.match?(/[\p{hiragana}\p{katakana}\p{han}〜ー][\p{P}\p{Pe}]?\z/)
        end
      end
    end
  end
end
