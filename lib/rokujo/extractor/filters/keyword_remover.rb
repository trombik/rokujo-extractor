# frozen_string_literal: true

module Rokujo
  module Extractor
    module Filters
      # A filter that removes specific keyword noises.
      class KeywordRemover < Base
        KEYWORDS_RE = /
                       (?:
                         \[全?(?:画像|動画)\] |
                         \[.*動画でわかる\] |
                         \[全?(?:画像|動画)を[み見]る\]
                       )
                      /x
        def call(sentences, widget_enable: true)
          self.widget_enable = widget_enable
          with_progress(total: sentences.count * 512) do |bar|
            results = sentences.map do |sentence|
              result = remove_keyword(sentence)
              bar.advance(512)
              result
            end
            results.compact
          end
        end

        private

        def remove_keyword(sentence)
          sentence.gsub(KEYWORDS_RE, "")
        end
      end
    end
  end
end
