# frozen_string_literal: true

require "tty-progressbar"

module Rokujo
  module Extractor
    module Filters
      # A filter to select Japanese sentences
      class JapaneseSelector
        def initialize; end

        # @param sentences [Array<String>] The sentences to filter.
        # @param bar [TTY::ProgressBar] Otional progress bar.
        def call(sentences, bar = nil)
          bar&.configure do |config|
            config.total = sentences.count
          end
          selected = sentences.select do |sentence|
            result = ends_with_japanese?(sentence)
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

        def ends_with_japanese?(sentence)
          sentence.strip.match?(/[\p{hiragana}\p{katakana}\p{han}〜ー][\p{P}\p{Pe}]?\z/)
        end
      end
    end
  end
end
