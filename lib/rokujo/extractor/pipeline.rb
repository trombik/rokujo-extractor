# frozen_string_literal: true

module Rokujo
  module Extractor
    # A pipeline to process steps of classes
    class Pipeline
      # @param steps [Array] Array of filters that implements #call and
      #                      returns a result. The result is apssed to the
      #                      next filter as input.
      # @param opts [Hash] Hash of optional options.
      def initialize(*steps, **opts)
        @steps = steps
        @widget_enable = opts.fetch(:widget_enable, true)
      end

      # Runs the pipeline by calling a step's `#call` with input and optional
      # widget.
      def run(input)
        @steps.reduce(input) do |data, step|
          step.call(data, widget_enable: @widget_enable)
        end
      end
    end
  end
end
