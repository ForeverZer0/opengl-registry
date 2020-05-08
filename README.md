# OpenGL Registry

Parses the Khronos OpenGL registry into a standardized and user-friendly data structure that can be walked through, providing an essential need for tools that generate code to create an OpenGL wrapper/bindings, for any language. Given an API name, version, and profile, is capable of filtering and grouping data structures that cover that specific subset of definitions, using a typical Ruby object-oriented approach.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'opengl-registry'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install opengl-registry

## Usage

#### Get the OpenGL Registry from Khronos

You can either download the latest copy of [gl.xml](https://github.com/KhronosGroup/OpenGL-Registry/blob/master/xml/gl.xml) directly from the [Khronos repo](https://github.com/KhronosGroup/OpenGL-Registry/tree/master/), or fetch it through the API.

```ruby
require 'opengl-registry'

GL::Registry.download('/path/to/save/gl.xml')
```

For successive runs, you can simply check that the version you have is up to date.
```ruby
if GL::Registry.outdated?('/path/to/gl.xml')
  # Download updated copy
end
```

#### Create a Registry instance

First step is to create the registry, which is essentially a container that stores every definition defined for OpenGL, OpenGLES (Embedded Systems), and OpenGLSC (Security Critical).

```ruby
registry = GL::Registry.load('/path/to/gl.xml')
```

Alternatively, if you have the XML as a string...
```ruby
registry = GL::Registry.parse(xml_string)
```

#### Create the OpenGL specification you wish to target

In order to filter results and definitions by a subset of the API, version, profile, etc, create a new spec.

```ruby
extensions = ['GL_ARB_get_program_binary', 'GL_ARB_texture_storage']
spec = GL::Spec.new(registry, :gl, 3.3, :core, extensions)
```

The created `spec` object can be then used to enumerate through every definition that this subset defines. The data will automatically be filtered and sorted, allowing for easy inspection of each entity.

```ruby
spec.functions.each do |function|
  # Print out the function name and return type
  puts "#{function.name} (#{function.type})"
    
  # Loop through argument definitions
  function.arguments.each do |argument|
    puts "  #{argument.name} (#{argument.type})"
  end
end

spec.enums.each do |enum|
  # Enums also define "groups" for creating C-style enumeration types, etc
  puts "#{enum.name} = #{enum.value}"
end
```

There are many helper functions throughout for detailed filtering, and retrieving any relevant information that might be required, such as generating bindings for a particular language, etc. See the [documentation](https://www.rubydoc.info/gems/opengl-registry/1.0.0) for more details.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
