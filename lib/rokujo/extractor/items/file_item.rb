# frozen_string_literal: true

require_relative "article_item"

module Rokujo
  module Extractor
    module Items
      # An Item class for files
      class FileItem < ArticleItem
        attr_accessor :source

        def initialize(location, opts = {})
          super
        end

        def filename
          location.basename
        end

        def url
          URI::File.build([nil, location.realpath.to_s])
        end

        def to_h
          hash = super
          hash[:filename] = filename
          hash[:source] = source
          hash
        end
      end
    end
  end
end
