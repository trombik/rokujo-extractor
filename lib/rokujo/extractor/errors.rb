# frozen_string_literal: true

module Rokujo
  module Extractor
    module Errors
      # The base class of Rokujo::Extractor
      class Base < StandardError; end

      # An error that signals an exception has happened due to a missing
      # method that must be implemented.
      class NotImplementedError < Base
        def initialize(message)
          message = "BUG: the subclass does not implement a mandatory method.\n#{message}"
          super
        end
      end
    end
  end
end
