# frozen_string_literal: true

module Rokujo
  module Extractor
    module Filters
      # A filter to remove bullets and section numbers.
      #
      # The bullets include, but not limited to:
      #
      # - "・foo"
      # - "1. foo"
      # - "1.2.3 foo"
      # - "※ foo"
      #
      class BulletRemover < Base
        def call(sentences, widget_enable: true)
          self.widget_enable = widget_enable
          with_progress(total: sentences.count * 512) do |bar|
            results = sentences.map do |sentence|
              result = sentence.gsub(bullet_pattern, "")
              bar&.advance(512)
              result
            end
            results.compact
          end
        end

        private

        # the method returns a complicated regexp and some elements are
        # intentionally duplicated.
        def bullet_pattern
          # see https://docs.ruby-lang.org/en/master/Regexp.html for details
          # about unicode properties.
          /\A # the beginning of the sentence
          (?:

           # section numbers, e.g., match "1. foo bar ..."
           # XXX does not match "1 foo bar" because "1" might be part of
           # unit, e.g., "1 kg"
           \d+\.\s |

           # section numbers, e.g., match "1.2.3 foo bar ..." but not "1.2 foo bar ..."
           # XXX no reasonable way to remove "1.2" from "1.2 foo" because "1.2" might be a decimal
           \d+(?:\.\d+){2,} |
           \p{Pd}\s | # dashes with a trailing space
           \p{No} | # other numbers, such as U+2460, or circled numbers
           [\u00B7\u0387\u2022\u2219\u22C5\u30FB\uFF65] | # various middle dots
           [●✕◯※*] # other common bullets used in Japanse texts
          )
          /x
        end
      end
    end
  end
end
