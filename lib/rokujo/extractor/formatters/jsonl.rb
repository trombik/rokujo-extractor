# frozen_string_literal: true

require "json"

module Rokujo
  module Extractor
    module Formatters
      # A formatter for JSONL output.
      class JSONL < Base
        def call(sentences, widget_enable: true)
          self.widget_enable = widget_enable
          with_progress(count: sentences.count) do |bar|
            result = sentences.map do |sentence|
              json = sentence.to_json
              bar&.advance
              json
            end
            bar&.finish
            result.join("\n")
          end
        end

        def widget
          widget_bar
        end
      end
    end
  end
end
