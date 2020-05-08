module GL

  ##
  # Describes a specific subset of the OpenGL registry, targeting an API, version, profile, etc.
  # 
  # Automatically filters all results bu the specified criteria, only returning results that are
  # used in the specification.
  class Spec

    ##
    # @return [Registry] the registry instance the specification uses for reference.
    attr_accessor :registry

    ##
    # @return [Symbol] the OpenGL API name.
    attr_reader :api

    ##
    # @return [String] the OpenGL version number for the specification.
    attr_reader :version

    ##
    # @return [Symbol] the OpenGL profile name for the specification.
    attr_reader :profile

    ##
    # @return [Array<String>] an array of extension names.
    attr_reader :extensions

    ##
    # Creates a new instance of the {Spec} class.
    #
    # @param registry [Registry] An registry instance to use for definition referencing.
    # @param api [Symbol,String] The OpenGL API name.
    # @param version [String,Float] The OpenGL version number for the specification.
    # @param profile [Symbol,String] The OpenGL profile name for the specification.
    # @param extensions [Array<String>] Names of extensions name to include definitions for.
    def initialize(registry, api, version, profile, *extensions)
      @registry = registry
      @api = api.to_sym
      @profile = profile.to_sym
      @version = Float(version).to_s
      @extensions = extensions&.uniq || []
    end

    ##
    # Retrieves a complete list of all OpenGL types that this specification must have defined. Any type not included
    # here does not need to be mapped.
    #
    # @param groups [Boolean] `true` to include group (enumeration) names, otherwise `false`
    #
    # @return [Array<Symbol>] a collection of OpenGL types.
    # @note The values are re-calculated each time this method is invoked, so consider caching the result if reusing.
    def types(groups = false)

      values = {}
      functions.each do |func|

        values[func.type.base] = true
        values[func.type.group] = true if groups && func.type.group

        func.arguments.each do |arg|
          values[arg.type.base] = true
          values[arg.type.group] = true if groups && arg.type.group
        end
      end

      #noinspection RubyYardReturnMatch
      values.keys.map(&:to_sym)
    end

    ##
    # Retrieves a complete list of all OpenGL functions that this specification defines.
    #
    # @return [Array<Registry::Function>] a collection of {Registry::Function} instances.
    # @note The values are re-calculated each time this method is invoked, so consider caching the result if reusing.
    def functions
      items(:function, @registry.functions)
    end

    ##
    # Retrieves a complete list of all OpenGL enumeration values that this specification defines.
    #
    # @return [Array<Registry::Enum>] a collection of {Registry::Enum} instances.
    # @note The values are re-calculated each time this method is invoked, so consider caching the result if reusing.
    def enums
      items(:enum, @registry.enums)
    end

    ##
    # Retrieves a complete list of all OpenGL group names that this specification uses.
    #
    # @return [Array<String>] a collection of group (enumeration) names.
    # @note The values are re-calculated each time this method is invoked, so consider caching the result if reusing.
    def used_groups

      names = {}
      functions.each do |func|

        names[func.type.group] = true if func.type.group
        func.arguments.each do |arg|
          group = arg.type.group
          next unless group

          names[group] = true
        end
      end
      names.keys
    end

    ##
    # @return [String] the string representation of this object.
    def to_s
      if profile != :none
        return "Open#{@api.to_s.upcase} #{@version} (#{@profile} profile)"
      end
      "Open#{@api.to_s.upcase} #{@version}"
    end

    private

    def items(type, definitions)
      raise 'registry is nil' unless @registry

      values = []

      # Enumerate through each feature group
      @registry.features.each do |group|

        # Skip unless this group implements the specified API and version
        next if group.api != @api
        next if group.version > @version

        # Enumerator through item this group implements
        group.additions.each do |feature|
          # Skip if this is not the specified type of not within the profile
          next if feature.type != type
          next unless feature.profile == :none || feature.profile == @profile

          # Add the definition this feature represents
          values << definitions.find { |item| item.name == feature.name }
        end

        # Enumerate through any "removed item" for this group
        group.removals.each do |feature|
          # Skip if this is not the specified type of not within the profile
          next unless feature.type == type
          next unless feature.profile == :none || feature.profile == @profile

          # Remove the definition this feature represents
          values.delete_if { |item| item.name == feature.name }
        end
      end

      # Enumerate through each extension
      @extensions.each do |name|
        # Find the extension definition, skipping unless supported by the API
        ext = @registry.extensions.find { |e| e.name == name }
        next unless ext && ext.supported.include?(@api)

        # Enumerate through each feature this extension implements
        ext.additions.each do |feature|
          # Skip if this is not the specified type of not within the profile
          next if feature.type != type
          next unless feature.profile == :none || feature.profile == @profile

          # Add the definition this feature represents
          values << definitions.find { |item| item.name == feature.name }
        end
      end

      # Return results
      values
    end
  end
end