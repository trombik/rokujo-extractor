# frozen_string_literal: true

require "json"

module Rokujo
  module Extractor
    module Metadata
      # The base class for Metadata.
      class Base
        include Rokujo::Extractor::Errors
        include Rokujo::Extractor::Concerns::Identifiable

        attr_reader :opts, :location

        # @param location [String] The location of the resource.
        # @param ops [Hash] Optional options.
        def initialize(location, opts = {})
          @location = location
          @opts = opts
        end

        # The title, e.g., the content of <title> tag in HTML.
        def title
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        # The author of the resource. Not necessarily an individual, e.g., an
        # organization.
        def author
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        # The URI of the resource.
        def uri
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        # The ISO 8601 timestamp of when the resource was created.
        def created_at
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        # The ISO 8601 timestamp of when the resource was updated.
        def updated_at
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        # The ISO 8601 timestamp of when the resource was acquired.
        def acquired_at
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        # Returns metadata as a Hash
        def to_h
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        # Returns metadata as a JSON string.
        #
        # @param args [Array] Optional argument for `JSON#generate`.
        def to_json(*args)
          JSON.generate(to_h, *args)
        end
      end
    end
  end
end
