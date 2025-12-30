# frozen_string_literal: true

module Rokujo
  module Extractor
    # A pipeline to process steps of classes
    class Pipeline
      def initialize(*steps)
        @steps = steps
      end

      def run(input)
        @steps.reduce(input) do |data, step|
          widget = step.widget if step.respond_to? :widget
          step.call(data, widget)
        end
      end
    end
  end
end
