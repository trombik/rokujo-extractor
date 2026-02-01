# frozen_string_literal: true

require_relative "file_item"

module Rokujo
  module Extractor
    module Items
      # ArticleItem for PDF files
      class PdfItem < FileItem
        def initialize(location, opts = {})
          super
        end

        def acquired_time
          info[:AcquiredTime] || Time.now.utc.iso8601
        end

        def author
          info[:Author]
        end

        def description
          info[:SourceDescription] || ""
        end

        def kind
          "document"
        end

        def modified_time
          info[:ModDate]
        end

        def published_time
          info[:CreationDate]
        end

        def site_name
          info[:SourceSiteName]
        end

        def title
          info[:Title]
        end

        def url
          info[:FileURL] || super
        end

        # FileItem specific
        def filename
          info[:OriginalFilename] || super
        end

        # source
        def source
          @source ||= {
            title: info[:SourceTitle],
            url: info[:SourceURL],
            site_name: info[:SourceSiteName],
            description: info[:SourceDescription]
          }
        end

        private

        def info
          @info ||= doc.info
        end

        def doc
          @doc ||= ::PDF::Reader.new(@location)
        end
      end
    end
  end
end
