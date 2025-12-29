# frozen_string_literal: true

require "tty-spinner"

module Rokujo
  module Extractor
    # Helpers for Rokujo::Extractor
    module Helpers
      # A Null Object for TTY::Spinner.
      class NilSpinner
        def initialize
          @spinner = TTY::Spinner.new
        end

        def method_missing(name, *args, &block)
          return if @spinner.respond_to?(name)

          super
        end

        def respond_to_missing?(name, include_private = false)
          @spinner.respond_to?(name, include_private) || super
        end
      end

      # Display a spinner while processing a block.
      #
      # @param message [String] The message of the spinner. An example: `[:spinner] Processing ...`
      # @param success_message [String] The message to display when successful. The default is `Done`
      # @param error_message [String] The message to display when unsuccessful. The default is `Failed`.
      # @param spinner [TTY::Spinner] Optional spinner object. Useful to manage multiple spinners with [TTY::Spinner::Multi].
      # @param spinner_opts [Hash] Option to pass to `TTY::Spinner.new`.
      # @example
      #   while_spinning(message: "[:spinner] Doing something ...") do |spinner|
      #     do_something
      #     spinner.pause
      #     spinner.log("Do something else")
      #     spinner.resume
      #     do_something_else
      #   end
      #
      # @yield [spinner] Yields the spinner instance to the block.
      #
      def while_spinning(message: "[:spinner] Doing ...",
                         success_message: "Done",
                         error_message: "Failed",
                         spinner: nil,
                         **spinner_opts)
        spinner ||= ::TTY::Spinner.new(message, spinner_opts)
        spinner = NilSpinner.new if ENV.key? "CI"
        spinner.auto_spin
        result = yield(spinner)
        spinner.success(success_message)
        result
      rescue StandardError => e
        spinner&.error(error_message)
        raise e
      end
    end
  end
end
