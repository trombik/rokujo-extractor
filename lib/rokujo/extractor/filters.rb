# frozen_string_literal: true

Dir[File.join(__dir__, "filters/**/*.rb")].each { |file| require file }
