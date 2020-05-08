# frozen_string_literal: true

require 'ox'
require 'net/http'
require 'json'
require 'open-uri'
require 'fileutils'

require_relative 'registry/version'
require_relative 'registry/words'
require_relative 'registry/token'
require_relative 'registry/native_type'
require_relative 'registry/group'
require_relative 'registry/enum'
require_relative 'registry/argument'
require_relative 'registry/function'
require_relative 'registry/feature_provider'
require_relative 'registry/feature'
require_relative 'registry/feature_group'
require_relative 'registry/extension'
require_relative 'spec'

##
# Top-level namespace.
#
# @author Eric "ForeverZer0" Freed
module GL

  ##
  # Container for all definitions of the OpenGL registry.
  #
  # @example
  #
  #   # Check if registry XML file is up to data
  #   if GL::Registry.outdated?('gl.xml')
  #     GL::Registry.download('gl.xml')
  #   end
  #
  #   registry = GL::Registry.load('gl.xml')
  #   spec = GL::Spec.new(registry, :gl, 3.3, :core)
  #
  #   # Use "spec" object to enumerate over detailed objects defining each token
  #
  class Registry

    ##
    # An array of OpenGL type names, as symbols.
    GL_TYPES = %i[
      GLenum GLboolean GLbitfield GLvoid GLbyte GLubyte GLshort GLushort GLint
      GLuint GLclampx GLsizei GLfloat GLclampf GLdouble GLclampd
      GLeglClientBufferEXT GLeglImageOES GLchar GLhandleARB GLhalf GLhalfARB
      GLfixed GLintptr GLintptrARB GLsizeiptr GLsizeiptrARB GLint64 GLint64EXT
      GLuint64 GLuint64EXT GLsync struct\ _cl_context struct\ _cl_event
      GLDEBUGPROC GLDEBUGPROCARB GLDEBUGPROCKHR GLDEBUGPROCAMD GLhalfNV
      GLvdpauSurfaceNV GLVULKANPROCNV
    ].freeze
    
    ##
    # @return [Array<Group>] a collection of all enumeration groups defined by OpenGL.
    # @note This is for reference only, and should not be used for building definitions or determining a comprehensive
    #   list of which enum values belong in each group, use the {Enum#groups} property instead.
    attr_reader :groups

    ##
    # @return [Array<Function>] a complete collection of all OpenGL functions.
    attr_reader :functions

    ##
    # @!attribute [r] enums
    #   @return [Array<Enum>] a complete collection of all OpenGL enum values.

    ##
    # @return [Array<FeatureGroup>] a complete collection of all OpenGL feature groups.
    attr_reader :features

    ##
    # @return [Array<Extension>] a complete collection of all OpenGL extensions.
    attr_reader :extensions

    ##
    # Creates a new {Registry} from the specified XML file.
    #
    # @param path [String] The path to the registry file.
    #
    # @return [Registry] a newly created and parsed {Registry}.
    def self.load(path)
      doc = Ox.load_file(path, mode: :generic)
      new(doc.root)
    end

    ##
    # Creates a new {Registry} from the specified XML string.
    #
    # @param xml [String] The OpenGL registry as an XML string.
    #
    # @return [Registry] a newly created and parsed {Registry}.
    def self.parse(xml)
      doc = Ox.load(xml, mode: :generic)
      new(doc.root)
    end

    ##
    # @return [Array<Symbol>] an array of Symbol objects that represent each defined API in the registry.
    def api_names
      # RubyMine warns that the return value is wrong. It lies.
      #noinspection RubyYardReturnMatch
      @features.map(&:api).uniq
    end

    ##
    # Retrieves an array of profiles defined in the registry.
    #
    # @overload profiles
    #
    # @overload profiles(api)
    #   @param api [Symbol] An API to limit results to a specific API.
    #
    # @overload profiles(api, version)
    #   @param api [Symbol] An API to limit results to a specific API.
    #   @param version [String|Float] A version to limit results to.
    #
    # @return [Array<Symbol>] an array of defined profiles.
    def profiles(api = nil, version = '1.0')
      # RubyMine warns that the return value is wrong. It lies.
      if api
        values = @features.find_all { |group| group.api == api && group.version <= version.to_s }
        #noinspection RubyYardReturnMatch
        return values.flat_map(&:additions).map(&:profile).uniq
      end
      #noinspection RubyYardReturnMatch
      @features.flat_map(&:additions).map(&:profile).uniq
    end

    def enums
      #noinspection RubyResolve
      @enums ||= each_enum.to_a
    end

    ##
    # Enumerates through each enum defined in the registry.
    #
    # @overload each_enum
    #   When called without a block, returns an Enumerator.
    #   @return [Enumerator] An enum enumerator.
    #
    # @overload each_enum(&block)
    #   When called with a block, yields each item to the block and returns `nil`.
    #   @yieldparam enum [Enum] Yields an enum to the block.
    #   @return [void]
    def each_enum
      #noinspection RubyYardReturnMatch
      return enum_for(__method__) unless block_given?
      @groups.each do |group|
        group.members.each { |item| yield item }
      end
      nil
    end

    ##
    # Enumerates through each group defined in the registry.
    #
    # @overload each_group
    #   When called without a block, returns an Enumerator.
    #   @return [Enumerator] A group enumerator.
    #
    # @overload each_group(&block)
    #   When called with a block, yields each item to the block and returns `nil`.
    #   @yieldparam group [Group] Yields a group to the block.
    #   @return [void]
    def each_group
      #noinspection RubyYardReturnMatch
      return enum_for(__method__) unless block_given?
      @groups.each { |item| yield item }
      nil
    end

    ##
    # Enumerates through each function defined in the registry.
    #
    # @overload each_function
    #   When called without a block, returns an Enumerator.
    #   @return [Enumerator] A function enumerator.
    #
    # @overload each_function(&block)
    #   When called with a block, yields each item to the block and returns `nil`.
    #   @yieldparam enum [Function] Yields a function to the block.
    #   @return [void]
    def each_function
      #noinspection RubyYardReturnMatch
      return enum_for(__method__) unless block_given?
      @functions.each { |item| yield item }
      nil
    end

    ##
    # Enumerates through each feature group defined in the registry.
    #
    # @overload each_feature
    #   When called without a block, returns an Enumerator.
    #   @return [Enumerator] A feature group enumerator.
    #
    # @overload each_feature(&block)
    #   When called with a block, yields each item to the block and returns `nil`.
    #   @yieldparam enum [FeatureGroup] Yields a group to the block.
    #   @return [void]
    def each_feature
      #noinspection RubyYardReturnMatch
      return enum_for(__method__) unless block_given?
      @features.each { |item| yield item }
      nil
    end

    ##
    # Enumerates through each extension defined in the registry.
    #
    # @overload each_enum
    #   When called without a block, returns an Enumerator.
    #   @return [Enumerator] An extension enumerator.
    #
    # @overload each_enum(&block)
    #   When called with a block, yields each item to the block and returns `nil`.
    #   @yieldparam enum [Extension] Yields an extension to the block.
    #   @return [void]
    def each_extension
      #noinspection RubyYardReturnMatch
      return enum_for(__method__) unless block_given?
      @extensions.each { |item| yield item }
      nil
    end

    ##
    # Download the latest version of the OpenGL registry to the specified file.
    #
    # @param path [String] The path where the file will be saved.
    #
    # @return [Boolean] `true` on success, otherwise `false` if an error occurred.
    def self.download(path)
      begin
        URI.open('https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/master/xml/gl.xml') do |io|
          FileUtils.mv(io.path, path)
        end
        return true
      rescue
        return false
      end
    end

    ##
    # Compares the registry at the specified path to the current registry version and returns value indicating if there
    # is a newer version available.
    #
    # @param path [String] The path to a registry file to test.
    #
    # @return [Boolean] `true` if a newer version is available, otherwise `false` if file is current and/or an error
    #   occurred.
    #
    # @note This method is not guaranteed to be accurate, it only uses the timestamps in the file's metadata, which
    #   could be inaccurate due to file copying, system time changes, creating from different source, etc.
    def self.outdated?(path)

      return false unless path && File.exist?(path)

      begin
        uri = URI('https://api.github.com/repos/KhronosGroup/OpenGL-Registry/commits?path=xml/gl.xml')
        Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 3, read_timeout: 5) do |http|

          req = Net::HTTP::Get.new(uri)
          response = http.request(req)

          if response.code == '200'
            json = JSON.parse(response.body, symbolize_names: true)
            commit = DateTime.parse(json.first[:commit][:author][:date]).to_time
            return File.mtime(path) < commit
          end

        end
      rescue
        warn('failed to query current registry version')
        return false
      end
    end

    private

    def initialize(root)
      raise ArgumentError, 'root cannot be nil' unless root

      @groups = []
      root.locate('enums').each do |enum|
        next unless enum.is_a?(Ox::Element)
        @groups << Group.new(enum)
      end

      @functions = []
      root.locate('commands/command').each do |function|
        next unless function.is_a?(Ox::Element)
        @functions << Function.new(function)
      end

      @features = []
      root.locate('feature').each do |feature|
        next unless feature.is_a?(Ox::Element)
        @features << FeatureGroup.new(feature)
      end

      @extensions = []
      root.locate('extensions/extension').each do |extension|
        next unless extension.is_a?(Ox::Element)
        @extensions << Extension.new(extension)
      end
    end
  end
end

registry = GL::Registry.load('/code/ruby/khronos-temp/gl.xml')
spec = GL::Spec.new(registry, :gl, 4.3, :compatibility)

p spec.enums.size
