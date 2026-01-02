# frozen_string_literal: true

require "nokogiri"
require "docx"

module Rokujo
  module Extractor
    module Metadata
      # Metadata for text file on local file system.
      class Docx < Base
        attr_reader :location

        include Rokujo::Extractor::Concerns::Identifiable

        # The title of the docx. When `dc:title` is not defined (e.g., the
        # author did not set any title in the file's property), falls back to
        # file's basename.
        #
        # @return [String]
        def title
          property_at("dc:title")
        end

        def file_basename
          location.basename(".*").to_s
        end

        # Returns the content of `core.xml`.
        #
        # @return [String]
        def core_xml_content
          entry = zip.get_entry("docProps/core.xml")
          entry.get_input_stream.read
        rescue Errno::ENOENT
          nil
        end

        # Returns parsed Nokogiri XML doc.
        #
        # @return [Nokogiri::XML::Document]
        def core_xml_doc
          doc = Nokogiri::XML.parse(core_xml_content)
          unless doc.errors.empty?
            doc.errors.each do |err|
              warn err.message
            end
          end
          doc
        end

        # Returns the text value of `tag` from `docProps/core.xml`.
        #
        # @param tag {String] CSSS expression of the tag to search
        # @return [String]
        def property_at(tag)
          core_xml_doc.at_css(tag)&.text&.strip || ""
        end

        def author
          property_at_at("dc|creator")
        end

        def uri
          URI::File.build([nil, location.realpath]).to_s
        end

        def created_at
          property_at("dcterms|created")
        end

        def updated_at
          property_at("dcterms|modified")
        end

        def acquired_at
          @acquired_at ||= Time.now.utc.iso8601
        end

        def docx
          @docx ||= ::Docx::Document.open(location)
          acquired_at
          @docx
        end

        def zip
          docx.zip
        end
      end
    end
  end
end
