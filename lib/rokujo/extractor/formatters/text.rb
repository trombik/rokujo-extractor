# frozen_string_literal: true

module Rokujo
  module Extractor
    module Formatters
      # A formatter that simply outputs a plain text. Each line contains the
      # text only.
      class Text < Base
        def call(sentences, widget_enable: true)
          self.widget_enable = widget_enable
          with_progress(count: sentences.count) do |bar|
            result = sentences.map do |s|
              bar.advance
              s[:content]
            end
            bar.finish
            result.join("\n")
          end
        end
      end
    end
  end
end
