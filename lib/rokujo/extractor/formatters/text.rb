# frozen_string_literal: true

module Rokujo
  module Extractor
    module Formatters
      # A formatter that simply outputs a plain text. Each line contains the
      # text only.
      class Text < Base
        def call(sentences, bar = nil)
          bar&.configure { |config| config.total = sentences.count }
          result = sentences.map do |s|
            bar&.advance
            s[:content]
          end
          bar&.finish
          result.join("\n")
        end

        def widget
          ::TTY::ProgressBar.new("#{base_class_name} [:bar]")
        end
      end
    end
  end
end
