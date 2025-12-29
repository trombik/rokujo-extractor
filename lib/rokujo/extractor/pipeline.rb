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
          step.call(data)
        end
      end
    end
  end
end
