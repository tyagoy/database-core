# frozen_string_literal: true

require_relative "lib/database-core/version"

Gem::Specification.new do |spec|
  spec.name = "database-core"
  spec.version = DatabaseCore::VERSION
  spec.authors = ["Tiago da Silva"]
  spec.email = ["tyagoy@gmail.com"]

  spec.summary = "A simple Ruby library for database abstraction and management."
  spec.description = "A comprehensive Ruby library providing database abstraction and management features, making it easier to interact with various databases."
  spec.homepage = "https://github.com/tyagoy/database-core"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/tyagoy/database-core"
  spec.metadata["changelog_uri"] = "https://github.com/tyagoy/database-core/blob/main/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 7.0", "< 9.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
