# frozen_string_literal: true

require "csv"

module Rokujo
  module Extractor
    module Formatters
      # A formatter for CSV output.
      class CSV < Base
        def call(sentences, widget_enable: true)
          self.widget_enable = widget_enable
          with_progress(total: sentences.count * 512) do |bar|
            result = ::CSV.generate(converters: :integer) do |csv|
              sentences.each do |sentence|
                csv << [
                  sentence[:text],
                  sentence[:meta][:line_number],
                  sentence[:meta][:uuid]
                ]
              end
              bar.advance(512)
            end
            result
          end
        end
      end
    end
  end
end
