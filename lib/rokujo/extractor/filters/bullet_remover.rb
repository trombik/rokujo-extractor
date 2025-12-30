# frozen_string_literal: true

require "tty-progressbar"

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
      class BulletRemover
        def call(sentences, bar = nil)
          bar&.configure do |config|
            config.total = sentences.count
          end
          results = sentences.map do |sentence|
            sentence.gsub(bullet_pattern, "")
          end
          bar&.advance
          results.compact
        end

        def widget
          ::TTY::ProgressBar.new("#{base_class_name} [:bar]")
        end

        private

        def base_class_name
          self.class.name.split("::").last
        end

        # rubocop:disable Metrics/MethodLength, Lint/DuplicateRegexpCharacterClassElement
        #
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
           [
             \u00B7
             \u0387
             \u2022
             \u2219
             \u22C5
             \u30FB
             \uFF65
           ] | # various middle dots
           [●✕◯※*] # other common bullets used in Japanse texts
          )
          /x
        end
        # rubocop:enable Metrics/MethodLength, Lint/DuplicateRegexpCharacterClassElement
      end
    end
  end
end
