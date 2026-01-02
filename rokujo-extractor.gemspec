# frozen_string_literal: true

require_relative "lib/rokujo/extractor/version"

Gem::Specification.new do |spec|
  spec.name = "rokujo-extractor"
  spec.version = Rokujo::Extractor::VERSION
  spec.authors = ["Tomoyuki Sakurai"]
  spec.email = ["y@trombik.org"]

  spec.summary = "Sentence extractor with line-merging logic"
  spec.description = <<~TEXT
    Extracts clean Japanese sentences from various document formats. Includes
    logic to join fragmented lines and determine file types via MIME when
    extensions are missing.
  TEXT
  spec.homepage = "https://github.com/trombik/rokujo-extractor"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = ""
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/trombik/rokujo-extractor"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "docx"

  # Workaround a missing dependency in pycall. fiddle used to be loaded from
  # the standard library, but is not part of the default gems since Ruby
  # 4.0.0.
  spec.add_dependency "csv"
  spec.add_dependency "fiddle"
  spec.add_dependency "marcel"
  spec.add_dependency "pdf-reader"
  spec.add_dependency "pragmatic_segmenter"
  spec.add_dependency "ruby-spacy"
  spec.add_dependency "thor"
  spec.add_dependency "tty-progressbar"
  spec.add_dependency "tty-spinner"
  spec.add_dependency "uuid7"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
