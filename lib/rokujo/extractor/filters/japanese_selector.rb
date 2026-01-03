# frozen_string_literal: true

module Rokujo
  module Extractor
    module Filters
      # A filter to select Japanese sentences
      class JapaneseSelector < Base
        # @param sentences [Array<String>] The sentences to filter.
        # @param bar [TTY::ProgressBar] Otional progress bar.
        def call(sentences, widget_enable: true)
          self.widget_enable = widget_enable
          with_progress(total: sentences.count * 512) do |bar|
            selected = sentences.select do |sentence|
              result = ends_with_japanese?(sentence)
              bar&.advance(512)
              result
            end
            bar&.finish
            selected
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
