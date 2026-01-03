# frozen_string_literal: true

module Rokujo
  module Extractor
    module Filters
      # A filter to remove special strings
      class StringCleaner < Base
        # rubocop:disable Lint/DuplicateRegexpCharacterClassElement
        INVISIBLE_CHARS_RE = /[
          \u200B-\u200D # Zero Width Space
          \uFEFF        # BOM
          \u00A0        # NBSP
        ]/x

        # rubocop:enable Lint/DuplicateRegexpCharacterClassElement
        def call(sentences, widget_enable: true)
          self.widget_enable = widget_enable
          with_progress(total: sentences.count * 512) do |bar|
            sentences.map do |sentence|
              result = sentence.gsub(INVISIBLE_CHARS_RE, "").strip
              bar.advance(512)
              result
            end
          end
        end
      end
    end
  end
end
