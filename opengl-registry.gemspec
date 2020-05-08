# frozen_string_literal: true

require_relative 'lib/opengl/registry/version'

Gem::Specification.new do |spec|
  spec.name          = 'opengl-registry'
  spec.version       = GL::Registry::VERSION
  spec.authors       = ['ForeverZer0']
  spec.email         = ['efreed09@gmail.com']

  spec.summary      = 'OpenGL Registry parser for generating API specifications'
  spec.description  = <<-EOS
  Parses the Khronos OpenGL registry into a standardized and user-friendly data structure that can be walked through,
  providing an essential need for tools that generate code to create an OpenGL wrapper/bindings, for any language. Given
  an API name, version, and profile, is capable of filtering and grouping data structures that cover that specific
  subset of definitions, using a typical Ruby object-oriented approach.
  EOS
  spec.homepage     = 'https://github.com/ForeverZer0/opengl-registry'
  spec.license      = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ForeverZer0/opengl-registry'
  spec.metadata['changelog_uri']   = 'https://github.com/ForeverZer0/opengl-registry/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_runtime_dependency 'ox', '~> 2.13'
end
