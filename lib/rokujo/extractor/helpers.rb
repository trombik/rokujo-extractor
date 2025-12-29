# frozen_string_literal: true

require "tty-spinner"
require "tty-progressbar"

module Rokujo
  module Extractor
    # Helpers for Rokujo::Extractor
    module Helpers
      # Display a spinner while processing a block.
      #
      # @param message [String] The message of the spinner. An example: `[:spinner] Processing ...`
      # @param success_message [String] The message to display when successful. The default is `Done`
      # @param error_message [String] The message to display when unsuccessful. The default is `Failed`.
      # @param spinner [TTY::Spinner] Optional spinner object. Useful to manage multiple spinners with [TTY::Spinner::Multi].
      # @param spinner_opts [Hash] Option to pass to `TTY::Spinner.new`.
      # @example
      #   with_spinner(message: "[:spinner] Doing something ...") do |spinner|
      #     do_something
      #     spinner.pause
      #     spinner.log("Do something else")
      #     spinner.resume
      #     do_something_else
      #   end
      #
      # @yield [spinner] Yields the spinner instance to the block.
      #
      def with_spinner(message: "[:spinner] Doing ...",
                         success_message: "Done",
                         error_message: "Failed",
                         spinner: nil,
                         **spinner_opts)
        spinner ||= ::TTY::Spinner.new(message, spinner_opts)
        spinner.auto_spin
        result = yield(spinner)
        spinner.success(success_message)
        result
      rescue StandardError => e
        spinner&.error(error_message)
        raise e
      end

      # Display a progress bar while processing a block.
      #
      # @param message [String] The message/format of the progress bar. An example: `[:bar] :percent`
      # @param total [Integer] The total number of steps to completion.
      # @param success_message [String] The message to display when successful.
      # @param progress_bar [TTY::ProgressBar] Optional progress bar object.
      # @param bar_opts [Hash] Options to pass to `TTY::ProgressBar.new`.
      #
      # @yield [bar] Yields the progress bar instance to the block.
      # @yieldparam bar [TTY::ProgressBar] The active progress bar object.
      #
      # @example
      #   with_progress(message: "Downloading [:bar]", total: 100) do |bar|
      #     items.each do |item|
      #       process(item)
      #       bar.advance(1)
      #     end
      #   end
      #
      def with_progress(message: "Processing [:bar] :percent",
                        total: 100,
                        progress_bar: nil,
                        **bar_opts)
        bar = progress_bar || ::TTY::ProgressBar.new(message, bar_opts.merge({ total: total }))
        result = yield(bar)
        bar.finish
        result
      rescue StandardError => e
        bar&.stop
        raise e
      end
    end
  end
end
